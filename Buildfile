require File.expand_path(File.dirname(__FILE__) + '/../buildr-osgi-assembler/lib/buildr_osgi_assembler')

gem 'buildr-bnd', :version => '0.0.3'
gem 'buildr-iidea', :version => '0.0.4'

require 'buildr_bnd'
require 'buildr_iidea'

repositories.remote << 'https://repository.apache.org/content/repositories/releases'
repositories.remote << 'http://repository.ops4j.org/maven2' # Pax-*
repositories.remote << 'http://download.java.net/maven/2' # OpenMQ
repositories.remote << 'http://repository.buschmais.com/releases' # Maexo
repositories.remote << 'http://www.ibiblio.org/maven2'
repositories.remote << 'http://repository.springsource.com/maven/bundles/external'
repositories.remote << 'http://repository.code-house.org/content/repositories/release' # OSGi - jmx RI

repositories.remote << Buildr::Bnd.remote_repository

JMS = 'org.apache.geronimo.specs:geronimo-jms_1.1_spec:jar:1.1.1'
IMQ = 'com.sun.messaging.mq:imq:jar:4.4'

OSGI_CORE = Buildr::OSGi::OSGI_CORE
OSGI_COMPENDIUM = Buildr::OSGi::OSGI_COMPENDIUM

# For generating scr descriptor from annotations
BND_ANNOTATIONS = 'biz.aQute:annotation:jar:0.0.384'

class CentralLayout < Layout::Default
  def initialize(key, top_level = false)
    super()
    prefix = top_level ? '' : '../'
    self[:target] = "#{prefix}target/#{key}"
    self[:target, :main] = "#{prefix}target/#{key}"
  end
end

def define_with_central_layout(name, top_level = false, &block)
  define(name, :layout => CentralLayout.new(name, top_level), &block)
end

desc 'OSGi bundle for OpenMQ provider client library'
define_with_central_layout('com.sun.messaging.mq.imq', true) do
  project.version = '4.4'
  project.group = 'jamex'
  compile.options.source = '1.6'
  compile.options.target = '1.6'
  compile.options.lint = 'all'
  project.no_ipr
  iml.local_repository_env_override = nil
  compile.with IMQ
  package(:bundle).tap do |bnd|
    bnd['Import-Package'] = "*;resolution:=optional"
    bnd['Export-Package'] = "com.sun.messaging.*;version=#{version}"
  end
end

desc 'An OSGi based JMS router in its infancy'
define_with_central_layout('jamex', true) do
  project.version = '0.1.1-SNAPSHOT'
  project.group = 'jamex'
  compile.options.source = '1.6'
  compile.options.target = '1.6'
  compile.options.lint = 'all'

  ipr.extra_modules << 'com.sun.messaging.mq.imq.iml'
  ipr.template = _('etc/project-template.ipr')
  iml.local_repository_env_override = nil

  desc 'Bundle of jms utility classes'
  define_with_central_layout 'link' do
    compile.with JMS
    package(:bundle).tap do |bnd|
      bnd['Export-Package'] = "jamex.link.*;version=#{version}"
    end
  end

  desc 'OSGi JMS ConnectionFactory component'
  define_with_central_layout 'connection' do
    compile.with JMS, OSGI_CORE, projects('com.sun.messaging.mq.imq')
    package(:bundle).tap do |bnd|
      bnd['Export-Package'] = "jamex.connection.*;version=#{version}"
      bnd['Bundle-Activator'] = "jamex.connection.Activator"
    end
  end

  desc 'Test OSGi component that registers routes between destinations'
  define_with_central_layout 'routes' do
    compile.with JMS, OSGI_CORE, OSGI_COMPENDIUM, BND_ANNOTATIONS, projects('link')
    package(:bundle).tap do |bnd|
      bnd['Export-Package'] = "jamex.routes.*;version=#{version}"
      bnd['Bundle-Activator'] = "jamex.routes.Activator"
    end
  end

  desc 'The distribution project'
  define_with_central_layout 'dist' do
    project.osgi.tap do |osgi|
      osgi.container_type = :equinox
      osgi.enable_feature :osgi_core
      osgi.enable_feature :osgi_compendium
      #osgi.enable_feature :felix_tui_shell
      osgi.enable_feature :pax_confman
      osgi.enable_feature :pax_logging
      osgi.enable_feature :maexo_jmx

      osgi.include_bundles BND_ANNOTATIONS, JMS, :run_level => 50
      osgi.include_bundles projects('link', 'connection', 'com.sun.messaging.mq.imq', 'routes')

      osgi.include _('src/main/etc/*') 
    end

    package(:zip).path("#{id}-#{version}").tap do |zip|
      project.osgi.add_runtime_to_archive(zip)
    end
  end
end
