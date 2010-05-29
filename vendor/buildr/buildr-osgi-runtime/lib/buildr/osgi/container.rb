module Buildr
  module OSGi
    class Container
      attr_reader :runtime
      attr_reader :parameters
      attr_reader :system_properties
      attr_accessor :configuration_dir
      
      def initialize(runtime)
        @runtime = runtime
        @parameters = OrderedHash.new
        @system_properties = OrderedHash.new
        @configuration_dir = "configuration"
      end

      def []=(key, value)
        @parameters[key] = value
      end

      def [](key)
        @parameters[key]
      end

      def bundles
        raise "bundles should be overidden"
      end

      # Tell the container about location which it can generate files to.
      # The control_task should depend on any generation tasks
      def generate_to(control_task, path)
        raise "generate_to should be overidden"
      end

      protected

      def properties_file(filename, properties)
        keys = properties.keys.reject {|k| k =~ /^#.*/}
        file_generate_task(filename) do |f|
          keys.each do |k|
            doc = properties["##{k}"]
            if doc
              lines = doc.split("\n")
              lines.each do |line|
                f.write "# #{line}\n"
              end
            end
            f.write "#{k}=#{properties[k]}\n\n"
          end
        end
      end

      def file_generate_task(filename)
        dirname = File.dirname(filename)
        directory(dirname)
        runtime.project.file(filename => [Buildr.application.buildfile, dirname]) do
          File.open(filename, "w") do |f|
            yield f
          end
        end
      end
    end
  end
end