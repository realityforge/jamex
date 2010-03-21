module Realityforge
  module OSGi
    module Runtime

      module Felix
        def self.runner
          "org.apache.felix:org.apache.felix.main:jar:2.0.4"
        end

        def self.bin_dir
          "bin"
        end

        def self.configuration_dir
          "conf"
        end

        def self.bundle_dir
          "bundle"
        end
      end

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


      include Buildr::Extension

#      def include_runtime(zip, runtime, options = {})
#        actual_method = "include_#{runtime}_runtime".to_sym
#        raise "Runtime #{runtime} not supported" unless self.respond_to? actual_method
#        self.send actual_method, zip, options
#      end
#      def include_felix_runtime(zip, options)
#        rake_check_options options, :features, :prefix
#        prefix = options[:prefix] | ""
#        include_artifacts_in_zip(zip, ["org.apache.felix:felix:jar:2.0.4"], "#{prefix}bin")
#      end

      def include_generated_file_in_zip(zip, file, path)
        # Make the zip depend on the file so it is built/downloaded/etc
        zip.enhance [file]
        # Actually include the file in zip
        zip.include file, :path => path
      end

      def include_artifacts_in_zip(zip, artifact_specs, path)
        artifact_specs.map { |spec| artifact(spec) }.each do |a|
          include_generated_file_in_zip(zip, a, path)
        end
      end

      def include_projects_in_zip(zip, project_names, path)
        projects(project_names).map(&:packages).each do |file|
          include_generated_file_in_zip(zip, file, path)
        end
      end


    end
  end
end

class Buildr::Project
  include Realityforge::OSGi::Runtime
end