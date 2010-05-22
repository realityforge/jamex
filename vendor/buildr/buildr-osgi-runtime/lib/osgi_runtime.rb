module Realityforge
  module OSGi
    module Runtime
      module Features
        def self.osgi_core
          [
              'org.apache.felix:org.osgi.core:jar:1.4.0'
          ]
        end

        def self.osgi_compendium
          [
              'org.apache.felix:org.osgi.compendium:jar:1.4.0'
          ]
        end

        def self.felix_tui_shell
          [
              "org.apache.felix:org.apache.felix.shell:jar:1.4.2",
              "org.apache.felix:org.apache.felix.shell.tui:jar:1.4.1"
          ]
        end

        def self.pax_confman
          [
              'org.apache.felix:org.apache.felix.configadmin:jar:1.0.4', # Service for providing config data
              'org.ops4j.pax.confman:pax-confman-propsloader:jar:0.2.2' # Component that loads configuration data off the file system
          ]

        end

        def self.pax_logging
          [
              'org.ops4j.pax.logging:pax-logging-api:jar:1.3.0', # Support all the vaious logging apis .. hopefully
              'org.ops4j.pax.logging:pax-logging-service:jar:1.3.0' # Support for OSGI Compendium Logging interface
          ]
        end

        def self.osgi_jmx
          [
              'org.osgi:org.osgi.impl.bundle.jmx:jar:4.2.0.200907080519'
          ]
        end

        def self.maexo_jmx
          # The following dependencies are used as part of the JMX management interface.
          # * Unsure on the minimal set.
          # * Perhaps should be replaced by RFC-139 (JMX Control of OSGi) when it is finalized.
          [
              "com.buschmais.maexo.modules.framework:maexo-framework.switchboard:jar:1.0.0",
              "com.buschmais.maexo.modules.framework:maexo-framework.commons.mbean:jar:1.0.0",
              "com.buschmais.maexo.modules.mbeans:maexo-mbeans.osgi.core:jar:1.0.0",
              "com.buschmais.maexo.modules.server:maexo-server.factory:jar:1.0.0",
              "com.buschmais.maexo.modules.server:maexo-server.platform:jar:1.0.0",
          ]

        end
      end
    end
  end
end
