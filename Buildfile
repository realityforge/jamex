gem "buildr", "~>1.3"

#repositories.local = '/home/peter/.m2/repository'
repositories.remote << 'file:///usr/share/maven-repo'
repositories.remote << 'https://repository.apache.org/content/repositories/releases'
repositories.remote << 'http://repository.ops4j.org/maven2' # Pax-*
repositories.remote << 'http://download.java.net/maven/2' # OpenMQ
repositories.remote << 'http://repository.buschmais.com/releases' # Maexo
repositories.remote << 'http://www.aQute.biz/repo' # Bnd
repositories.remote << 'http://www.ibiblio.org/maven2'
repositories.remote << 'http://repository.springsource.com/maven/bundles/external'

JMS = 'org.apache.geronimo.specs:geronimo-jms_1.1_spec:jar:1.1.1'
IMQ = 'com.sun.messaging.mq:imq:jar:4.4'
OSGI_CORE = 'org.apache.felix:org.osgi.core:jar:1.4.0'
# logging and config services
OSGI_COMPENDIUM = 'org.apache.felix:org.osgi.compendium:jar:1.4.0'
# all the logging support needed ... hopefully
PAX_LOGGING = 'org.ops4j.pax.logging:pax-logging-api:jar:1.3.0'
# SUpport for OSGI Compendium Logging interface
PAX_LOGGING_SERVICE = 'org.ops4j.pax.logging:pax-logging-service:jar:1.3.0'
# Service for providing config data
CONFIG_ADMIN_SERVICE = 'org.apache.felix:org.apache.felix.configadmin:jar:1.0.4'
# Component that loads configuration data off the file system
PAX_CONFMAN = 'org.ops4j.pax.confman:pax-confman-propsloader:jar:0.2.2'

# For generating scr descriptor from annotations
BND_ANNOTATIONS = 'biz.aQute:annotation:jar:0.0.384'

# The following dependencies are used as part of the JMX management interface.
# * Unsure on the minimal set.
# * Perhaps should be replaced by RFC-139 (JMX Control of OSGi) when it is finalized.
MAEXO = [
    "com.buschmais.maexo.modules.framework:maexo-framework.switchboard:jar:1.0.0",
    "com.buschmais.maexo.modules.framework:maexo-framework.commons.mbean:jar:1.0.0",
    "com.buschmais.maexo.modules.mbeans:maexo-mbeans.osgi.core:jar:1.0.0",
    "com.buschmais.maexo.modules.server:maexo-server.factory:jar:1.0.0",
    "com.buschmais.maexo.modules.server:maexo-server.platform:jar:1.0.0",
]

PAX_RUNNER = "org.ops4j.pax.runner:pax-runner:jar:1.4.0"

EQUINOX = [
    "org.eclipse:osgi:jar:3.5.1.R35x_v20090827",
    "org.eclipse.osgi:util:jar:3.1.200-v20070605",
    "org.eclipse.osgi:services:jar:3.1.200-v20070605"
]

class CentralLayout < Layout::Default
  def initialize(key, top_level = false)
    super()
    prefix = top_level ? '' : '../'
    self[:target] = "#{prefix}target/#{key}"
    self[:target, :main] = "#{prefix}target/#{key}"
  end
end

desc 'An OSGi based JMS router in its infancy'
define 'jamex', :layout => CentralLayout.new('jamex', true) do
  project.version = '0.1.1-SNAPSHOT'
  project.group = 'jamex'
  manifest['Copyright'] = 'Peter Donald (C) 2010'
  compile.options.source = '1.6'
  compile.options.target = '1.6'
  compile.options.lint = 'all'

  desc 'Bundle of jms utility classes'
  define 'link', :layout => CentralLayout.new('link') do
    bnd['Export-Package'] = "#{group}.#{leaf_project_name}.*;version=#{version}"

    package :bundle
    compile.with JMS
  end

  desc 'OSGi bundle for OpenMQ provider client library'
  define 'com.sun.messaging.mq.imq', :layout => CentralLayout.new('com.sun.messaging.mq.imq') do
    bnd['Import-Package'] = "*;resolution:=optional"
    #bnd['Private-Package'] = "!*"
    bnd['Export-Package'] = "com.sun.messaging.*;version=#{version}"
    package :bundle
    compile.with IMQ
  end

  desc 'OSGi JMS ConnectionFactory component'
  define 'connection', :layout => CentralLayout.new('connection') do
    bnd['Export-Package'] = "#{group}.#{leaf_project_name}.*;version=#{version}"
    bnd['Bundle-Activator'] = "#{group}.#{leaf_project_name}.Activator"

    package :bundle
    compile.with JMS, OSGI_CORE, projects('com.sun.messaging.mq.imq')
  end

  desc 'Test OSGi component that registers routes between destinations'
  define 'routes', :layout => CentralLayout.new('routes') do
    bnd['Export-Package'] = "#{group}.#{leaf_project_name}.*;version=#{version}"
    bnd['Bundle-Activator'] = "#{group}.#{leaf_project_name}.Activator"

    package :bundle
    compile.with JMS, OSGI_CORE, OSGI_COMPENDIUM, BND_ANNOTATIONS, projects('link')
  end

  desc 'The distribution project'
  define 'dist', :layout => CentralLayout.new('dist') do
    package(:zip).tap do |zip|
      prefix = "#{id}-#{version}"
      zip.include( Buildr.artifacts([PAX_RUNNER]).each(&:invoke), :path => "#{prefix}/bin")
      zip.include( Buildr.artifacts(EQUINOX).each(&:invoke), :path => "#{prefix}/equinox")

      to_deploy = [OSGI_CORE, OSGI_COMPENDIUM, PAX_LOGGING, PAX_LOGGING_SERVICE, CONFIG_ADMIN_SERVICE, PAX_CONFMAN] +
          [BND_ANNOTATIONS, JMS] + projects('link', 'connection', 'com.sun.messaging.mq.imq', 'routes')

      zip.include( Buildr.artifacts(to_deploy).each(&:invoke), :path => "#{prefix}/lib")
      zip.include( _('src/main/etc/*'), :path => "#{prefix}")
    end
  end
end
