require File.expand_path(File.dirname(__FILE__) + '/vendor/buildr/buildr-osgi-runtime/lib/buildr_osgi_runtime')

gem 'buildr-bnd', :version => '0.0.2'
gem 'buildr-iidea', :version => '0.0.3'

require 'buildr_bnd'
require 'buildr_iidea'

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

# TODO: Rehook these back into buildr plugin
OSGI_CORE = 'org.apache.felix:org.osgi.core:jar:1.4.0'
OSGI_COMPENDIUM = 'org.apache.felix:org.osgi.compendium:jar:1.4.0'

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

  ipr.template = _('vendor/buildr/project-template.ipr')
  iml.local_repository_env_override = nil

  desc 'Bundle of common utility'
  define_with_central_layout 'common' do
    package(:bundle).tap do |bnd|
      bnd['Export-Package'] = "#{group}.#{leaf_project_name(project)}.*;version=#{version}"
    end
  end

  desc 'Bundle of jms utility classes'
  define_with_central_layout 'link' do
    compile.with JMS, projects('common')
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
    compile.with JMS, OSGI_CORE, projects('com.sun.messaging.mq.imq','common')
    package(:bundle).tap do |bnd|
      bnd['Export-Package'] = "#{group}.#{leaf_project_name(project)}.*;version=#{version}"
      bnd['Bundle-Activator'] = "#{group}.#{leaf_project_name(project)}.Activator"
    end
  end

  desc 'Test OSGi component that registers routes between destinations'
  define_with_central_layout 'routes' do
    compile.with JMS, OSGI_CORE, OSGI_COMPENDIUM, BND_ANNOTATIONS, projects('link','common')
    package(:bundle).tap do |bnd|
      bnd['Export-Package'] = "#{group}.#{leaf_project_name(project)}.*;version=#{version}"
      bnd['Bundle-Activator'] = "#{group}.#{leaf_project_name(project)}.Activator"
    end
  end

  desc 'The distribution project'
  define_with_central_layout 'dist' do
    project.osgi.tap do |osgi|
      osgi.enable_feature :osgi_core
      osgi.enable_feature :osgi_compendium
      osgi.enable_feature :felix_tui_shell
      osgi.enable_feature :pax_confman
      osgi.enable_feature :pax_logging
      osgi.enable_feature :maexo_jmx
    end

    package(:zip).tap do |zip|
      prefix = "#{id}-#{version}"

      framework = project.osgi.container
      zip.path("#{prefix}/var/log")
      zip.path("#{prefix}/tmp")
      system_bundle_repository = "#{prefix}/#{framework.system_bundle_repository}"
      include_artifacts_in_zip(zip, [framework.runner], system_bundle_repository, false)

      system_artifacts = project.osgi.features.collect {|f| f.bundles }.flatten.collect{|b| b.artifact_spec}
      include_artifacts_in_zip(zip, system_artifacts, system_bundle_repository, false)

      bundle_dir = "#{prefix}/#{framework.bundle_dir}"
      include_artifacts_in_zip(zip, [BND_ANNOTATIONS, JMS], bundle_dir)
      include_projects_in_zip(zip, ['link', 'connection', 'com.sun.messaging.mq.imq', 'routes'], bundle_dir)

      zip.include( _('src/main/etc/*'), :path => "#{prefix}")
    end
  end
end
