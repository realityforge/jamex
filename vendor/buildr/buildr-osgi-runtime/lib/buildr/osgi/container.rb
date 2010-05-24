module Buildr
  module OSGi
    class Container
      attr_reader :runtime
      attr_reader :parameters

      def initialize(runtime)
        @runtime = runtime
        @parameters = OrderedHash.new
      end

      def []=(key, value)
        @parameters[key] = value
      end

      def [](key)
        @parameters[key]
      end

      def configuration_dir
        File.dirname(configuration_file)
      end

      def bundle_dir
        "lib"
      end

      def bundles
        raise "bundles should be overidden"
      end

      def configuration_file
        raise "configuration_file should be overidden"
      end

      def write_config(file)
        raise "generate_config should be overidden"
      end
    end
  end
end