module Buildr
  module OSGi
    module Containers
      class Felix
        def bundles
          [
              Bundle.new("org.apache.felix:org.apache.felix.main:jar:2.0.4", 1)
          ]
        end
      end
    end

    class Runtime
      protected

      def create_felix_container
        Containers::Felix.new
      end
    end
  end
end