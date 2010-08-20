require File.expand_path(File.dirname(__FILE__) + '/../buildr-osgi-assembler/lib/buildr_osgi_assembler')

gem 'buildr-bnd', :version => '0.0.5'
gem 'buildr-iidea', :version => '0.0.7'

require 'buildr_bnd'
require 'buildr_iidea'

require File.expand_path(File.dirname(__FILE__) + '/etc/ipojo_extension')

repositories.remote << 'https://repository.apache.org/content/repositories/releases'
repositories.remote << 'http://repository.ops4j.org/maven2' # Pax-*
repositories.remote << 'http://download.java.net/maven/2' # OpenMQ
repositories.remote << 'http://repository.buschmais.com/releases' # Maexo
repositories.remote << 'http://www.ibiblio.org/maven2'
repositories.remote << 'http://repository.springsource.com/maven/bundles/external'
repositories.remote << 'http://repository.code-house.org/content/repositories/release' # OSGi - jmx RI

repositories.remote << Buildr::Bnd.remote_repository
repositories.remote << Buildr::Ipojo.remote_repository

JMS = 'org.apache.geronimo.specs:geronimo-jms_1.1_spec:jar:1.1.1'
IMQ = 'com.sun.messaging.mq:imq:jar:4.4'
AMQ = ['org.apache.activemq:activemq-core:jar:5.3.2', 'commons-logging:commons-logging:jar:1.1', 'org.apache.geronimo.specs:geronimo-j2ee-management_1.0_spec:jar:1.0']

IPOJO_ANNOTATIONS = Buildr::Ipojo.annotation_artifact

OSGI_CORE = Buildr::OSGi::OSGI_CORE
OSGI_COMPENDIUM = Buildr::OSGi::OSGI_COMPENDIUM

JML = 'realityforge:jml:jar:0.0.2'

class CentralLayout < Layout::Default
  def initialize(key, top_level, use_subdir)
    super()
    prefix = top_level ? '' : '../'
    subdir = use_subdir ? "/#{key}" : ''
    self[:target] = "#{prefix}target#{subdir}"
    self[:target, :main] = "#{prefix}target#{subdir}"
    self[:reports] = "#{prefix}reports#{subdir}"
  end
end

def define_with_central_layout(name, top_level = false, use_subdir = true, & block)
  define(name, :layout => CentralLayout.new(name, top_level, use_subdir), & block)
end

desc 'OSGi bundle for OpenMQ provider client library'
define_with_central_layout('com.sun.messaging.mq.imq', true) do
  project.version = '4.4'
  project.group = 'jamex'
  compile.options.source = '1.6'
  compile.options.target = '1.6'
  compile.options.lint = 'all'
  project.no_ipr
  iml.skip_content!
  compile.with IMQ
  package(:bundle).tap do |bnd|
    bnd['Import-Package'] = "*;resolution:=optional"
    bnd['Export-Package'] = "com.sun.messaging.*;version=#{version}"
  end
end

desc 'JAva Message EXchange is an osgi based jms router in it''s infancy'
define_with_central_layout('jamex', true, false) do
  project.version = '0.1.1-SNAPSHOT'
  project.group = 'jamex'
  compile.options.source = '1.6'
  compile.options.target = '1.6'
  compile.options.lint = 'all'

  ipr.extra_modules << 'com.sun.messaging.mq.imq.iml'
  ipr.template = _('etc/project-template.ipr')

  desc 'OSGi JMS ConnectionFactory component'
  define_with_central_layout 'connection' do
    compile.with JMS, OSGI_CORE, IPOJO_ANNOTATIONS, projects('com.sun.messaging.mq.imq')
    project.ipojo_metadata = _('src/main/config/metadata.xml')

    package(:bundle).tap do |bnd|
      bnd['Export-Package'] = "jamex.connection.*;version=#{version}"
    end
  end

  desc 'Test OSGi component that registers routes between destinations'
  define_with_central_layout 'routes' do
    compile.with JMS, OSGI_CORE, OSGI_COMPENDIUM, IPOJO_ANNOTATIONS, JML
    project.ipojo_metadata = _('src/main/config/metadata.xml')
    package(:bundle).tap do |bnd|
      bnd['Export-Package'] = "jamex.routes.*;version=#{version}"
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
      osgi.enable_feature :ipojo
      osgi.enable_feature :ipojo_jmx
      osgi.enable_feature :ipojo_whiteboard

      osgi.include_bundles JMS, :run_level => 50

      osgi.include_bundles JML,
                           project('connection').package(:bundle),
                           project('com.sun.messaging.mq.imq').package(:bundle),
                           project('routes').package(:bundle)

      osgi.include _('src/main/etc/*')
    end

    package(:zip).path("#{id}-#{version}").tap do |zip|
      project.osgi.add_runtime_to_archive(zip)
    end
  end

  package_with_sources
  package_with_javadoc
end
