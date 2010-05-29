module Buildr
  module OSGi
    module ProjectExtension
      include Extension

      first_time do
        desc "Generate runtime specific configuration files"
        Project.local_task "osgi:runtime:generate-config"

        desc "Verify bundles conform"
        Project.local_task "osgi:runtime:bundles:check"

        desc "Create a directory containing the runtime ready to run"
        Project.local_task "osgi:runtime:init"
      end

      before_define do |project|
        project.recursive_task("osgi:runtime:generate-config")
        project.recursive_task("osgi:runtime:init")
        project.recursive_task("osgi:runtime:bundles:check")
      end

      after_define do |project|
        if project.osgi?

          verify_task = project.task("osgi:runtime:bundles:check")

          if Buildr.const_defined?(:Bnd)
            verify_cache_dir = project.path_to(:target, :cache, :verify)
            directory(verify_cache_dir)
            project.osgi.bundles.select{|b| b.enable? }.each do |bundle|
              cache_file = "#{verify_cache_dir}/#{bundle.artifact_spec}"
              bundle_file = bundle.artifact.to_s
              project.file(cache_file => [verify_cache_dir, bundle_file]) do
                bundle.artifact.invoke
                begin
                  trace "Verifying: #{bundle_file}"
                  Buildr::Bnd.bnd_main( "print", "-verify", bundle_file )
                  touch cache_file
                rescue => e
                  warn "Bundle #{bundle.artifact_spec} does not conform to OSGi specifications."
                  raise e
                end
              end
              verify_task.enhance([cache_file])
            end
          end

          gen_task = project.task("osgi:runtime:generate-config")
          project.osgi.container.generate_to( gen_task, project.osgi.generation_dir )
          project.osgi.features.each do |feature|
            feature.generate_to( gen_task, project.osgi.generation_dir )
          end

          project.task("build").enhance(["osgi:runtime:generate-config"])

          project.task("osgi:runtime:init" => [gen_task, verify_task]) do |task|
            runtime_dir = project.path_to(:target, :osgi_runtime)
            mkdir_p runtime_dir
            cp_r Dir["#{project.osgi.generation_dir}/**"], runtime_dir
            project.osgi.included_dirs.each do |included_dir|
              cp_r Dir[included_dir], runtime_dir
            end

            project.osgi.bundles.each do |bundle|
              tofile = "#{runtime_dir}/#{project.osgi.bundle_path(bundle)}"
              FileUtils.mkdir_p File.dirname(tofile)
              bundle.artifact.invoke
              cp bundle.artifact.to_s, tofile
            end
          end
        end
      end

      def osgi
        @osgi ||= Runtime.new(self)
      end

      def osgi?
        !@osgi.nil?
      end
    end
  end
end

class Buildr::Project
  include Buildr::OSGi::ProjectExtension
end
