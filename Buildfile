gem "buildr", "~>1.3"

Dir["#{File.dirname(__FILE__)}/vendor/buildr/*/tasks/*.rake"].each do |file|
  load file
end

#repositories.local = '/home/peter/.m2/repository'
repositories.remote << 'file:///usr/share/maven-repo'
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
  if self.parent
    return project.name[project.parent.name.size + 1, project.name.length]
  else
    return project.name
  end
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

  desc 'Bundle of jms utility classes'
  define_with_central_layout 'link' do
    bnd['Export-Package'] = "#{group}.#{leaf_project_name(project)}.*;version=#{version}"

    package :bundle
    compile.with JMS
  end

  desc 'OSGi bundle for OpenMQ provider client library'
  define_with_central_layout 'com.sun.messaging.mq.imq' do
    bnd['Import-Package'] = "*;resolution:=optional"
    bnd['Export-Package'] = "com.sun.messaging.*;version=#{version}"
    package :bundle
    compile.with IMQ
  end

  desc 'OSGi JMS ConnectionFactory component'
  define_with_central_layout 'connection' do
    bnd['Export-Package'] = "#{group}.#{leaf_project_name(project)}.*;version=#{version}"
    bnd['Bundle-Activator'] = "#{group}.#{leaf_project_name(project)}.Activator"

    package :bundle
    compile.with JMS, OSGI_CORE, projects('com.sun.messaging.mq.imq')
  end

  desc 'Test OSGi component that registers routes between destinations'
  define_with_central_layout 'routes' do
    bnd['Export-Package'] = "#{group}.#{leaf_project_name(project)}.*;version=#{version}"
    bnd['Bundle-Activator'] = "#{group}.#{leaf_project_name(project)}.Activator"

    package :bundle
    compile.with JMS, OSGI_CORE, OSGI_COMPENDIUM, BND_ANNOTATIONS, projects('link')
  end

  desc 'The distribution project'
  define_with_central_layout 'dist' do
    package(:zip).tap do |zip|
      prefix = "#{id}-#{version}"

      framework = Realityforge::OSGi::Runtime::Felix
      features = Realityforge::OSGi::Runtime::Features

      bin_dir = "#{prefix}/#{framework.bin_dir}"
      include_artifacts_in_zip(zip, [framework.runner], bin_dir)

      bundle_dir = "#{prefix}/#{framework.bundle_dir}"
      include_artifacts_in_zip(zip, features.osgi_core, bundle_dir)
      include_artifacts_in_zip(zip, features.osgi_compendium, bundle_dir)
      include_artifacts_in_zip(zip, features.felix_tui_shell, bundle_dir)
      include_artifacts_in_zip(zip, features.pax_confman, bundle_dir)
      include_artifacts_in_zip(zip, features.pax_logging, bundle_dir)
      #include_artifacts_in_zip(zip, features.osgi_jmx, bundle_dir)
      include_artifacts_in_zip(zip, features.maexo_jmx, bundle_dir)

      include_artifacts_in_zip(zip, [BND_ANNOTATIONS, JMS], bundle_dir)
      include_projects_in_zip(zip, ['link', 'connection', 'com.sun.messaging.mq.imq', 'routes'], bundle_dir)

      zip.include( _('src/main/etc/*'), :path => "#{prefix}")
    end
  end
end
