Gem::Specification.new do |spec|
  spec.name           = 'buildr-osgi-assembler'
  spec.version        = `git describe`.strip.split('-').first
  spec.authors        = ['Peter Donald']
  spec.email          = ["peter@realityforge.org"]
  spec.homepage       = "http://github.com/realityforge/buildr-osgi-assembler"
  spec.summary        = "Buildr extension for assembling OSGi applications"
  spec.description    = <<-TEXT
This is a buildr extension for assembling OSGi applications from a collection of bundles and a runtime. 
  TEXT
  spec.files          = Dir['{lib,spec}/**/*', '*.gemspec'] +
                        ['LICENSE', 'README.rdoc', 'CHANGELOG', 'Rakefile']
  spec.require_paths  = ['lib']

  spec.has_rdoc         = true
  spec.extra_rdoc_files = 'README.rdoc', 'LICENSE', 'CHANGELOG'
  spec.rdoc_options     = '--title', "#{spec.name} #{spec.version}", '--main', 'README.rdoc'
end
