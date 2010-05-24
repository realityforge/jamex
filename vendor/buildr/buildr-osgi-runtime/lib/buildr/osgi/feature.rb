module Buildr
  module OSGi
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

