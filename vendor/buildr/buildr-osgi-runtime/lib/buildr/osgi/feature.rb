module Buildr
  module OSGi
    class Feature
      attr_reader :feature_key
      attr_accessor :bundles
      attr_reader :system_properties

      def initialize(feature_key)
        @feature_key = feature_key
        @bundles = []
        @system_properties = OrderedHash.new
      end
    end
  end
end

