module Buildr
  module OSGi

    class Runtime
      attr_accessor :features
      attr_accessor :container_type
      attr_reader :project

      def initialize(project)
        @project = project
        @features = {}
        @container_type = :felix
      end

      def container
        unless @container
          container_factory_method = "create_#{container_type}_container".to_sym
          raise "Container type #{container_type} not supported" unless self.respond_to? container_factory_method
          @container = self.send container_factory_method  
        end
        @container
      end

    end


  end
end
