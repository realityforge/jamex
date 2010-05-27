module Buildr
  module OSGi
    class Container
      attr_reader :runtime
      attr_reader :parameters
      attr_reader :system_properties

      def initialize(runtime)
        @runtime = runtime
        @parameters = OrderedHash.new
        @system_properties = OrderedHash.new
      end

      def []=(key, value)
        @parameters[key] = value
      end

      def [](key)
        @parameters[key]
      end

      def bundle_dir
        "lib"
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

      def file_generate_task(filename)
        runtime.project.file(filename => [Buildr.application.buildfile]) do
          FileUtils.mkdir_p File.dirname(filename)
          File.open(filename, "w") do |f|
            yield f
          end
        end
      end
    end
  end
end