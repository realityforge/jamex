require File.expand_path(File.dirname(__FILE__) + '/vendor/buildr/buildr-iidea/lib/buildr_iidea')
require File.expand_path(File.dirname(__FILE__) + '/vendor/buildr/buildr-bnd/lib/buildr_bnd')
require File.expand_path(File.dirname(__FILE__) + '/vendor/buildr/buildr-osgi-runtime/lib/buildr_osgi_runtime')

repositories.remote << 'https://repository.apache.org/content/repositories/releases'
repositories.remote << 'http://repository.ops4j.org/maven2' # Pax-*
repositories.remote << 'http://download.java.net/maven/2' # OpenMQ
repositories.remote << 'http://repository.buschmais.com/releases' # Maexo
repositories.remote << 'http://www.aQute.biz/repo' # Bnd
repositories.remote << 'http://www.ibiblio.org/maven2'
repositories.remote << 'http://repository.springsource.com/maven/bundles/external'
repositories.remote << 'http://repository.code-house.org/content/repositories/release' # OSGi - jmx RI

JMS = 'org.apache.geronimo.specs:geronimo-jms_1.1_spec:jar:1.1.1'
IMQ = 'com.sun.messaging.mq:imq:jar:4.4'

OSGI_CORE = Realityforge::OSGi::Runtime::Features.osgi_core
OSGI_COMPENDIUM = Realityforge::OSGi::Runtime::Features.osgi_compendium

# For generating scr descriptor from annotations
BND_ANNOTATIONS = 'biz.aQute:annotation:jar:0.0.384'

def leaf_project_name(project)
  project.name.split(":").last
end

class CentralLayout < Layout::Default
  def initialize(key, top_level = false)
    super()
    prefix = top_level ? '' : '../'
    self[:target] = "#{prefix}target/#{key}"
    self[:target, :main] = "#{prefix}target/#{key}"
  end
end

def define_with_central_layout(name, &block)
  define(name, :layout => CentralLayout.new(name, name == 'jamex'), &block)
end

desc 'An OSGi based JMS router in its infancy'
define_with_central_layout 'jamex' do
  project.version = '0.1.1-SNAPSHOT'
  project.group = 'jamex'
  compile.options.source = '1.6'
  compile.options.target = '1.6'
  compile.options.lint = 'all'

  ipr.suffix = ''
  ipr.template = _('vendor/buildr/project-template.ipr')
  iml.suffix = ''
  iml.local_repository_env_override = nil

  desc 'Bundle of jms utility classes'
  define_with_central_layout 'link' do
    compile.with JMS
    package(:bundle).tap do |bnd|
      bnd['Export-Package'] = "#{group}.#{leaf_project_name(project)}.*;version=#{version}"
    end
  end

  desc 'OSGi bundle for OpenMQ provider client library'
  define_with_central_layout 'com.sun.messaging.mq.imq' do
    compile.with IMQ
    package(:bundle).tap do |bnd|
      bnd['Import-Package'] = "*;resolution:=optional"
      bnd['Export-Package'] = "com.sun.messaging.*;version=#{version}"
    end
  end

  desc 'OSGi JMS ConnectionFactory component'
  define_with_central_layout 'connection' do
    compile.with JMS, OSGI_CORE, projects('com.sun.messaging.mq.imq')
    package(:bundle).tap do |bnd|
      bnd['Export-Package'] = "#{group}.#{leaf_project_name(project)}.*;version=#{version}"
      bnd['Bundle-Activator'] = "#{group}.#{leaf_project_name(project)}.Activator"
    end
  end

  desc 'Test OSGi component that registers routes between destinations'
  define_with_central_layout 'routes' do
    compile.with JMS, OSGI_CORE, OSGI_COMPENDIUM, BND_ANNOTATIONS, projects('link')
    package(:bundle).tap do |bnd|
      bnd['Export-Package'] = "#{group}.#{leaf_project_name(project)}.*;version=#{version}"
      bnd['Bundle-Activator'] = "#{group}.#{leaf_project_name(project)}.Activator"
    end
  end

  desc 'The distribution project'
  define_with_central_layout 'dist' do
    package(:zip).tap do |zip|
      prefix = "#{id}-#{version}"

      framework = Realityforge::OSGi::Runtime::Felix
      features = Realityforge::OSGi::Runtime::Features

      system_bundle_repository = "#{prefix}/#{framework.system_bundle_repository}"
      include_artifacts_in_zip(zip, features.osgi_core, system_bundle_repository, false)
      include_artifacts_in_zip(zip, features.osgi_compendium, system_bundle_repository, false)
      include_artifacts_in_zip(zip, [framework.runner], system_bundle_repository, false)
      include_artifacts_in_zip(zip, features.felix_tui_shell, system_bundle_repository, false)
      include_artifacts_in_zip(zip, features.pax_confman, system_bundle_repository, false)
      include_artifacts_in_zip(zip, features.pax_logging, system_bundle_repository, false)
      #include_artifacts_in_zip(zip, features.osgi_jmx, system_bundle_repository, false)
      include_artifacts_in_zip(zip, features.maexo_jmx, system_bundle_repository, false)

      bundle_dir = "#{prefix}/#{framework.bundle_dir}"
      include_artifacts_in_zip(zip, [BND_ANNOTATIONS, JMS], bundle_dir)
      include_projects_in_zip(zip, ['link', 'connection', 'com.sun.messaging.mq.imq', 'routes'], bundle_dir)

      zip.include( _('src/main/etc/*'), :path => "#{prefix}")
    end
  end
end
