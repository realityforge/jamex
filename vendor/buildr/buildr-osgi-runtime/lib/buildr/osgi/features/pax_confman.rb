module Buildr
  module OSGi
    module Features
      class PaxConfman < Feature
        def initialize(runtime)
          super(:pax_confman)
          self.bundles << Bundle.new('org.apache.felix:org.apache.felix.configadmin:jar:1.0.4', 3) # Service for providing config data
          self.bundles << Bundle.new('org.ops4j.pax.confman:pax-confman-propsloader:jar:0.2.2', 3) # Component that loads configuration data off the file system
          self.system_properties["#bundles.configuration.location"] = "Location of configuration data for PaxConfman"
          self.system_properties["bundles.configuration.location"] = runtime.container.configuration_dir
        end

        def generate_to(control_task, path)
          config_dir = "#{path}/#{self.system_properties["bundles.configuration.location"]}"
          services_dir = "#{config_dir}/services"
          factories_dir = "#{config_dir}/factories"
          directory(services_dir)
          directory(factories_dir)
          control_task.enhance [ services_dir, factories_dir ]
        end
      end
    end

    class Runtime
      protected

      def define_pax_confman_feature
        Features::PaxConfman.new(self)
      end
    end
  end
end

