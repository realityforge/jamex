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

      # Tell the feature about location which it can generate files to.
      # The control_task should depend on any generation tasks
      def generate_to(control_task, path)
      end
    end
  end
end

