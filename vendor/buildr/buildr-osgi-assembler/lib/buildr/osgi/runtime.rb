module Buildr
  module OSGi
    class Runtime
      attr_accessor :container_type
      attr_accessor :bundle_dir
      attr_reader :project
      attr_reader :system_properties

      def initialize(project)
        @project = project
        @features = {}
        @container_type = :felix
        @system_properties = OrderedHash.new
        @bundle_dir = "lib"
      end

      def container
        unless @container
          container_factory_method = "create_#{container_type}_container".to_sym
          raise "Container type #{container_type} not supported" unless self.respond_to? container_factory_method
          @container = self.send(container_factory_method)
        end
        @container
      end

      def enable_feature(feature)
        if feature.is_a? Symbol
          add_feature( create_feature(feature) )
        elsif feature.is_a? Feature
          add_feature(feature)
        else
          raise "Feature must be a symbol or an instance of Feature"
        end
      end

      def features
        @features.values
      end

      def system_bundles
        self.container.bundles + self.features.collect {|f| f.bundles }.flatten
      end

      def application_bundles
        @application_bundles ||= []
      end

      def bundles
        system_bundles + application_bundles 
      end

      def include_bundles(*specs)
        options = {:run_level => Bundle::DEFAULT_RUN_LEVEL}
        options.merge!( specs.pop.dup ) if Hash === specs.last
        Buildr.artifacts(specs).each do |artifact|
          name = artifact.respond_to?(:to_spec) ? artifact.to_spec : artifact.to_s
          self.application_bundles << Bundle.new(name, options[:run_level])
        end
      end

      # List of directories to copy into runtime
      def included_dirs
        @included_dirs ||= []
      end

      def include(dir)
        self.included_dirs << dir
      end

      def add_runtime_to_archive(archive)
        self.bundles.each do |bundle|
          archive.include bundle.artifact, :as => bundle_path(bundle)
        end
        archive.include "#{generation_dir}/**"
        self.included_dirs.each do |included_dir|
          archive.include Dir[included_dir]
        end
        # if path get root else assume that archive is task
        archive_task = (archive.respond_to? :root) ? archive.root : archive
        archive_task.enhance(["osgi:runtime:generate-config","osgi:runtime:bundles:check"])
      end

      def bundle_path(bundle)
        "#{self.bundle_dir}/#{bundle.relative_install_path}"
      end

      # Base directory into which runtime files are generated 
      def generation_dir
        project.path_to(:target, :generated, :osgi_runtime)
      end

      protected

      def add_feature(feature)
        raise "Feature #{feature.feature_key} already defined" if @features[feature.feature_key]
        @features[feature.feature_key] = feature
      end

      def create_feature(feature_key)
        bundles_factory_method = "define_#{feature_key}_bundles".to_sym
        if self.respond_to? bundles_factory_method
          f = Feature.new(feature_key)
          f.bundles = self.send(bundles_factory_method)
          return f
        else
          feature_factory_method = "define_#{feature_key}_feature".to_sym
          raise "Feature #{feature_key} not supported" unless self.respond_to? feature_factory_method
          f = self.send(feature_factory_method)
          if f.feature_key != feature_key
            raise "Factory method #{feature_factory_method} for feature #{feature_key} created a feature with key #{f.feature_key} rather than #{feature_key}"
          end
          return f
        end
      end
    end
  end
end
