module Buildr
  module OSGi
    module ProjectExtension
      include Extension

      def osgi
        @osgi ||= Runtime.new(self)
      end

      # TODO: Remove me!
      def include_artifacts_in_zip(zip, artifact_specs, path, flat = true)
        artifact_specs.map { |spec| artifact(spec) }.each do |a|
          artifact_path = flat ? path : "#{path}/#{a.group.gsub('.','/')}"
          zip.include a, :path => artifact_path
        end
      end

      # TODO: Remove me!
      def include_projects_in_zip(zip, project_names, path)
        projects(project_names).map(&:packages).each do |file|
          zip.include file, :path => path
        end
      end
      
    end
  end
end

class Buildr::Project
  include Buildr::OSGi::ProjectExtension
end
