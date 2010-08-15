module Buildr
  module Ipojo
    class Version
      MAJOR = "0"
      MINOR = "0"
      MICRO = "1"

      STRING = "#{MAJOR}.#{MINOR}.#{MICRO}"
    end

    class << self

      def ipojo_version
        @ipojo_version ||= '1.6.2'
      end

      def ipojo_version=(ipojo_version)
        @ipojo_version = ipojo_version
      end

      def annotation_artifact
        "org.apache.felix:org.apache.felix.ipojo.annotations:jar:#{self.ipojo_version}"
      end

      # The specs for requirements
      def requires
        [
          self.annotation_artifact,
          "org.apache.felix:org.apache.felix.ipojo.metadata:jar:1.4.0",
          "org.apache.felix:org.apache.felix.ipojo.manipulator:jar:#{self.ipojo_version}",
          'asm:asm-all:jar:3.0'
        ]
      end

      # Repositories containing the requirements
      def remote_repository
        'https://repository.apache.org/content/repositories/releases'
      end

      def pojoize(input_filename, output_filename, metadata_filename)
        pojoizer = Java.org.apache.felix.ipojo.manipulator.Pojoization.new
        pojoizer.setUseLocalXSD()
        pojoizer.pojoization(Java.java.io.File.new(input_filename),
                             Java.java.io.File.new(output_filename),
                             Java.java.io.FileInputStream.new(metadata_filename))
        #pojoizer.getWarnings()
        #for (int i = 0; i < pojo.getWarnings().size(); i++) {
        #    log((String) pojo.getWarnings().get(i), Project.MSG_WARN);
        #}
      end
    end

    module ProjectExtension
      include Extension

      attr_accessor :ipojo_metadata

      def ipojo?
        !@ipojo_metadata.nil?
      end

      after_define do |project|
        if project.ipojo?
          # Add artifacts to java classpath
          Buildr::Ipojo.requires.each do |spec|
            a = Buildr.artifact(spec)
            a.invoke
            Java.classpath << a.to_s
          end
          project.packages.each do |pkg|
            if pkg.respond_to?(:to_hash) && pkg.to_hash[:type] == :jar
              pkg.enhance do
                #puts "Enhancing #{pkg.to_s}"
                begin
                  tmp_filename = pkg.to_s + ".out"
                  Buildr::Ipojo.pojoize(pkg.to_s, tmp_filename, project.ipojo_metadata)
                  FileUtils.mv tmp_filename, pkg.to_s
                rescue => e
                  FileUtils.rm_rf pkg.to_s
                  raise e
                end
              end
            end
          end
        end
      end
    end
  end
end

class Buildr::Project
  include Buildr::Ipojo::ProjectExtension
end