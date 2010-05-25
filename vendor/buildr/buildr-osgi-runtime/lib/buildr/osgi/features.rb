module Buildr
  module OSGi
    OSGI_CORE = 'org.apache.felix:org.osgi.core:jar:1.4.0'
    OSGI_COMPENDIUM = 'org.apache.felix:org.osgi.compendium:jar:1.4.0'

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
        f = Feature.new(:pax_logging)
        f.bundles << Bundle.new('org.ops4j.pax.logging:pax-logging-api:jar:1.3.0', 2) # Support all the vaious logging apis .. hopefully
        f.bundles << Bundle.new('org.ops4j.pax.logging:pax-logging-service:jar:1.3.0', 2) # Support for OSGI Compendium Logging interface
        # Setup logging properties to avoid an error on first access
        f.system_properties["java.util.logging.properties"] = "conf/java.util.logging.properties"
        # Log level when the pax-logging service is not available
        # This level will only be used while the pax-logging service bundle is not fully available.
        # To change log levels, please refer to the org.ops4j.pax.logging.cfg file
        # instead.
        f.system_properties["org.ops4j.pax.logging.DefaultServiceLog.level"] = "ERROR"
        f
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
    end
  end
end

