module Buildr
  module OSGi
    OSGI_CORE = 'org.apache.felix:org.osgi.core:jar:1.4.0'
    OSGI_COMPENDIUM = 'org.apache.felix:org.osgi.compendium:jar:1.4.0'

    class PaxLoggingFeature < Feature
      def initialize(runtime)
        super(:pax_logging)
        self.bundles << Bundle.new('org.ops4j.pax.logging:pax-logging-api:jar:1.3.0', 2) # Support all the vaious logging apis .. hopefully
        self.bundles << Bundle.new('org.ops4j.pax.logging:pax-logging-service:jar:1.3.0', 2) # Support for OSGI Compendium Logging interface
        # Setup logging properties to avoid an error on first access
        self.system_properties["java.util.logging.properties"] = "#{runtime.container.configuration_dir}/java.util.logging.properties"
        # Log level when the pax-logging service is not available
        # This level will only be used while the pax-logging service bundle is not fully available.
        # To change log levels, please refer to the org.ops4j.pax.logging.cfg file
        # instead.
        self.system_properties["org.ops4j.pax.logging.DefaultServiceLog.level"] = "ERROR"
      end
    end

    class Runtime
      protected

      def define_osgi_core_bundles
        [
            Bundle.new(OSGI_CORE, 1)
        ]
      end

      def define_osgi_compendium_bundles
        [
            Bundle.new(OSGI_COMPENDIUM, 1)
        ]
      end

      def define_pax_logging_feature
        PaxLoggingFeature.new(self)
      end

      def define_pax_confman_bundles
        [
            Bundle.new('org.apache.felix:org.apache.felix.configadmin:jar:1.0.4', 3), # Service for providing config data
            Bundle.new('org.ops4j.pax.confman:pax-confman-propsloader:jar:0.2.2', 3) # Component that loads configuration data off the file system
        ]
      end

      def define_felix_tui_shell_bundles
        [
            Bundle.new("org.apache.felix:org.apache.felix.shell:jar:1.4.2", 10),
            Bundle.new("org.apache.felix:org.apache.felix.shell.tui:jar:1.4.1", 10)
        ]
      end

      def define_osgi_jmx_bundles
        [
            Bundle.new('org.osgi:org.osgi.impl.bundle.jmx:jar:4.2.0.200907080519', 50)
        ]
      end

      def define_maexo_jmx_bundles
        # The following dependencies are used as part of the JMX management interface.
        # * Unsure on the minimal set.
        # * Perhaps should be replaced by RFC-139 (JMX Control of OSGi) when it is finalized.
        [
            Bundle.new("com.buschmais.maexo.modules.framework:maexo-framework.switchboard:jar:1.0.0", 60),
            Bundle.new("com.buschmais.maexo.modules.framework:maexo-framework.commons.mbean:jar:1.0.0", 60),
            Bundle.new("com.buschmais.maexo.modules.mbeans:maexo-mbeans.osgi.core:jar:1.0.0", 60),
            Bundle.new("com.buschmais.maexo.modules.server:maexo-server.factory:jar:1.0.0", 60),
            Bundle.new("com.buschmais.maexo.modules.server:maexo-server.platform:jar:1.0.0", 60),
        ]
      end

      def define_jee_bundles
        [
            Bundle.new("org.ow2.spec.ee:ow2-ejb-3.0-spec:jar:1.0.3", 45),
            Bundle.new("org.ow2.spec.ee:ow2-ejb-3.1-spec:jar:1.0.3", 45),
            Bundle.new("org.ow2.spec.ee:ow2-jpa-1.0-spec:jar:1.0.3", 45),
            Bundle.new("org.ow2.spec.ee:ow2-jpa-2.0-spec:jar:1.0.3", 45),
            Bundle.new("org.ow2.spec.ee:ow2-jta-1.1-spec:jar:1.0.3", 45),
            Bundle.new("org.ow2.spec.ee:ow2-connector-1.5-spec:jar:1.0.3", 45),
            Bundle.new("org.ow2.spec.ee:ow2-jsr77-1.1-spec:jar:1.0.3", 45),
            Bundle.new("org.apache.geronimo.specs:geronimo-jacc_1.1_spec:jar:1.0-M2", 45),
            Bundle.new("org.apache.tomcat:servlet-api:jar:6.0.13", 45),
            Bundle.new("javax.activation:activation:jar:1.1", 45),
            Bundle.new("javax.mail:mail:jar:1.4", 45),
            #Bundle.new("javax.xml.bind:jar:jaxb-api:2.0", 45),
            Bundle.new("org.apache.geronimo.specs:geronimo-jms_1.1_spec:jar:1.1", 45),
            Bundle.new("org.apache.geronimo.specs:geronimo-jaxrpc_1.1_spec:jar:1.1", 45),
#            Bundle.new('javax.ejb:com.springsource.javax.ejb:jar:3.0.0', 45),
#            Bundle.new('javax.activation:com.springsource.javax.activation:jar:1.1.1', 45),
#            Bundle.new('javax.xml.soap:com.springsource.javax.xml.soap:jar:1.3.0', 45),
#            Bundle.new('javax.servlet:com.springsource.javax.servlet:jar:2.5.0', 45),
#            Bundle.new('javax.xml.rpc:com.springsource.javax.xml.rpc:jar:1.1.0', 45),
#            Bundle.new('org.apache.geronimo.specs:com.springsource.javax.management.j2ee:jar:1.2.0', 45),

        ]
      end

      def define_easybeans_bundles
        [
            Bundle.new('org.ow2.easybeans.osgi:easybeans-core:jar:1.1.0', 55),
            Bundle.new('org.ow2.easybeans.osgi:easybeans-agent:jar:1.1.0', 55),
            Bundle.new('org.ow2.easybeans.osgi:easybeans-component-carol:jar:1.1.0', 55),
            Bundle.new('org.ow2.easybeans.osgi:easybeans-component-event:jar:1.1.0', 55),
            Bundle.new('org.ow2.easybeans.osgi:easybeans-component-hsqldb:jar:1.1.0', 55),
            Bundle.new('org.ow2.easybeans.osgi:easybeans-component-jdbcpool:jar:1.1.0', 55),
            Bundle.new('org.ow2.easybeans.osgi:easybeans-component-jmx:jar:1.1.0', 55),
            Bundle.new('org.ow2.easybeans.osgi:easybeans-component-joram:jar:1.1.0', 55),
            Bundle.new('org.ow2.easybeans.osgi:easybeans-component-jotm:jar:1.1.0', 55),
            Bundle.new('org.ow2.easybeans.osgi:easybeans-component-quartz:jar:1.1.0', 55),
            Bundle.new('org.ow2.easybeans.osgi:easybeans-component-statistic:jar:1.1.0', 55),

            Bundle.new('org.apache.felix:org.apache.felix.dependencymanager:jar:2.0.1', 55),
            Bundle.new('org.apache.felix:org.apache.felix.scr:jar:1.0.8', 55),


            Bundle.new('org.ow2.bundles:ow2-bundles-externals-commons-modeler:jar:1.0.18', 55),
            Bundle.new('org.ow2.bundles:ow2-util-i18n:jar:1.0.18', 55),
            Bundle.new('org.ow2.bundles:ow2-util-log:jar:1.0.18', 55),
            Bundle.new('org.ow2.bundles:ow2-util-event-api:jar:1.0.18', 55),
            Bundle.new('org.ow2.bundles:ow2-util-event-impl:jar:1.0.18', 55),
            Bundle.new('org.ow2.bundles:ow2-util-jmx-api:jar:1.0.18', 55),
            Bundle.new('org.ow2.bundles:ow2-util-jmx-impl:jar:1.0.18', 55),
        ]
      end
    end
  end
end

