module Buildr
  module OSGi
    module Features
      class PaxLogging < Feature
        attr_reader :runtime

        def initialize(runtime)
          @runtime = runtime
          super(:pax_logging)
          self.bundles << Bundle.new('org.ops4j.pax.logging:pax-logging-api:jar:1.3.0', 2) # Support all the vaious logging apis .. hopefully
          self.bundles << Bundle.new('org.ops4j.pax.logging:pax-logging-service:jar:1.3.0', 2) # Support for OSGI Compendium Logging interface
          self.system_properties["#java.util.logging.properties"] = "Setup logging properties to avoid an error on first access"
          self.system_properties["java.util.logging.properties"] = "#{runtime.container.configuration_dir}/java.util.logging.properties"
          self.system_properties["#org.ops4j.pax.logging.DefaultServiceLog.level"] = <<DOC
Log level when the pax-logging service is not available
This level will only be used while the pax-logging service bundle is not fully available.
To change log levels, please refer to the org.ops4j.pax.logging configuration file instead.
DOC
          self.system_properties["org.ops4j.pax.logging.DefaultServiceLog.level"] = "ERROR"
        end

        def generate_to(control_task, path)
          filename = "#{path}/#{self.system_properties["java.util.logging.properties"]}"
          dirname = File.dirname(filename)
          directory(dirname)
          gen_task = runtime.project.file(filename => [Buildr.application.buildfile, dirname]) do
            File.open(filename, "w") do |f|
              f.write <<CONFIG
# Empty java.util.logging.properties to prevent the log to stderr, so that
# all logs will be delegated to pax logging JUL handler only
CONFIG
            end
          end

          control_task.enhance [ gen_task ]
        end
      end
    end

    class Runtime
      protected

      def define_pax_logging_feature
        Features::PaxLogging.new(self)
      end
    end
  end
end

