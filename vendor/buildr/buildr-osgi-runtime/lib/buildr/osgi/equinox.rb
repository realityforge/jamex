module Buildr
  module OSGi
    class Equinox
      def bundles
        [
            Bundle.new("org.eclipse:osgi:jar:3.5.1.R35x_v20090827", 0),
        ]
      end

      def configuration_dir
        "configuration"
      end

      def bundle_dir
        "plugins"
      end

      def system_bundle_repository
        "system"
      end
    end

    class Runtime
      protected

      def create_equinox_container
        Equinox.new
      end
    end
  end
end