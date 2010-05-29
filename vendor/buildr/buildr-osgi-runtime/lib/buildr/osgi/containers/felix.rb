module Buildr
  module OSGi
    module Containers
      class Felix < Container
        FRAMEWORK = "org.apache.felix:org.apache.felix.main:jar:2.0.4"

        def bundles
          [
              Bundle.new(FRAMEWORK, 0)
          ]
        end

        def generate_to(control_task, path)
          directory("#{path}/tmp")
          directory("#{path}/var/log")
          directory("#{path}/var/cache")
          control_task.enhance [ config_file_task(path),
                                 system_properties_file_task(path),
                                 sh_startup_file_task(path),
                                 bat_startup_file_task(path),
                                 "#{path}/tmp",
                                 "#{path}/var/log",
                                 "#{path}/var/cache" ]
        end

        protected

        def java_command
          "java -Dfelix.system.properties=file:#{configuration_dir}/system.properties -Dfelix.config.properties=file:#{configuration_dir}/config.properties -jar #{self.runtime.bundle_path(bundles[0])}"
        end

        def bat_startup_file_task(path)
          file_generate_task("#{path}/run.bat") do |f|
            f.write "#{java_command} %*\n"
          end
        end

        def sh_startup_file_task(path)
          file_generate_task("#{path}/run.sh") do |f|
            f.write "#{java_command} $*\n"
          end
        end

        def config_file_task(path)
          properties_file("#{path}/#{configuration_dir}/config.properties", to_config)
        end

        def system_properties_file_task(path)
          properties_file("#{path}/#{configuration_dir}/system.properties", to_system_properties)
        end

        def to_system_properties
          params = OrderedHash.new
          params['java.io.tmpdir'] = 'tmp'
          params['#xml.catalog.files']= 'Set this empty property to avoid errors when validating xml documents.'
          params['xml.catalog.files'] = ''
          params['#jline.nobell']= 'Suppress the bell in the console when hitting backspace to many times for example.'
          params['jline.nobell'] = 'true'
          
          self.runtime.features.each do |feature|
            params.update(feature.system_properties)
          end

          params.update(system_properties)
          params.update(runtime.system_properties)
        end

        def to_config
          params = OrderedHash.new
          params['felix.log.level'] = 0
          params['org.osgi.framework.startlevel.beginning'] = Bundle::MAX_RUN_LEVEL
          params['felix.startlevel.bundle'] = Bundle::DEFAULT_RUN_LEVEL

          params['org.osgi.framework.storage.clean'] = 'onFirstInit'
          params['org.osgi.framework.storage'] = 'var/cache'
          params['felix.cache.bufsize']='4096'

          enabled_bundles = self.runtime.bundles.select{|b| b.enable?}
          run_levels = enabled_bundles.collect{|bundle| bundle.run_level}.sort.uniq
          run_levels.each do |run_level|
            bundles_at_run_level = enabled_bundles.select{|bundle| bundle.run_level == run_level}
            params["felix.auto.start.#{run_level}"] = bundles_at_run_level.collect do |bundle|
              "file:#{self.runtime.bundle_path(bundle)}"
            end.join(" ")
          end

          params.update(parameters)
        end
      end
    end

    class Runtime
      protected

      def create_felix_container
        Containers::Felix.new(self)
      end
    end
  end
end