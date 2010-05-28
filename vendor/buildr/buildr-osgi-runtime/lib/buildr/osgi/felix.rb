module Buildr
  module OSGi
    class Felix
      def bundles
        [
            Bundle.new("org.apache.felix:org.apache.felix.main:jar:2.0.4", 1)
        ]        
      end
    end

    class Runtime
      protected

      def create_felix_container
        Felix.new
      end
    end
  end
end