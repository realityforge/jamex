module Buildr
  module OSGi
    class Bundle
      attr_reader :artifact_spec
      attr_reader :run_level

      def initialize(artifact_spec, run_level)
        @artifact_spec, @run_level = artifact_spec, run_level
        @artifact_specs = {}
      end
    end

    class Feature
      attr_reader :feature_key
      attr_accessor :bundles

      def initialize(feature_key)
        @feature_key = feature_key
        @bundles = []
      end
    end
  end
end

