
puts "WARNING: This buildr is completely untested and may not even parse. A WIP"

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
OSGI_COMPENDIUM = 'org.apache.felix:org.osgi.compendium:jar:1.4.0'
PAX_LOGGING = 'org.ops4j.pax.logging:pax-logging-api:jar:1.3.0'

# For generating scr descriptor from annotations
BND_ANNOTATIONS = 'biz.aQute:annotation:jar:0.0.384'


desc 'An OSGi based JMS router in its infancy'
define 'jamex' do
  project.version = '0.0.1-SNAPSHOT'
  project.group = 'jamex'
  manifest['Copyright'] = 'Peter Donald (C) 2010'
  compile.options.source = '1.6'
  compile.options.target = '1.6'
  compile.options.lint = 'all'

  desc 'Bundle of jms utility classes'
  define 'link' do
    package :jar
    compile.with JMS
    # Bnd:
    #  Export-Package: ${bundle.namespace}.*;version="${pom.version}
    #  <Bundle-SymbolicName>${bundle.symbolicName}</Bundle-SymbolicName>
    #  <Bundle-Version>${pom.version}</Bundle-Version>
  end

  desc 'OSGi bundle for OpenMQ provider client library'
  define 'com.sun.messaging.mq.imq' do
    package :jar
    compile.with IMQ
    # TODO: Do not set license/copyright/etc unless sucked from original jar
    # BnD:
    #  <_exportcontents>*</_exportcontents>
    #  <Private-Package>!*</Private-Package>
    #  Embed-Dependency: *;scope=compile|runtime;type=!pom;inline=true
    #  Import-Package: *;resolution:=optional
  end

  desc 'OSGi JMS ConnectionFactory component'
  define 'connection' do
    package :jar
    compile.with JMS, OSGI_CORE, IMQ
    # Bnd:
    #  Bundle-Activator: ${bundle.namespace}.Activator
    #  Export-Package: ${bundle.namespace}.*;version="${pom.version}
    #  <Bundle-SymbolicName>${bundle.symbolicName}</Bundle-SymbolicName>
    #  <Bundle-Version>${pom.version}</Bundle-Version>
  end

  desc 'Test OSGi component that registers routes between destinations'
  define 'routes' do
    package :jar
    compile.with JMS, OSGI_CORE, OSGI_COMPENDIUM, BND_ANNOTATIONS, projects('link')
    # Bnd:
    #  Bundle-Activator: ${bundle.namespace}.Activator
    #  Export-Package: ${bundle.namespace}.*;version="${pom.version}
    #  <Bundle-SymbolicName>${bundle.symbolicName}</Bundle-SymbolicName>
    #  <Bundle-Version>${pom.version}</Bundle-Version>
  end


end
