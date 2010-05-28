require 'buildr'

require File.expand_path(File.dirname(__FILE__) + '/buildr/osgi/ordered_hash.rb')
require File.expand_path(File.dirname(__FILE__) + '/buildr/osgi/bundle.rb')
require File.expand_path(File.dirname(__FILE__) + '/buildr/osgi/feature.rb')
require File.expand_path(File.dirname(__FILE__) + '/buildr/osgi/container.rb')
require File.expand_path(File.dirname(__FILE__) + '/buildr/osgi/runtime.rb')
require File.expand_path(File.dirname(__FILE__) + '/buildr/osgi/project_extension.rb')

# The following list the various extensions to the core plugin
require File.expand_path(File.dirname(__FILE__) + '/buildr/osgi/felix.rb')
require File.expand_path(File.dirname(__FILE__) + '/buildr/osgi/equinox.rb')

# Features
require File.expand_path(File.dirname(__FILE__) + '/buildr/osgi/features.rb')
require File.expand_path(File.dirname(__FILE__) + '/buildr/osgi/features/pax_confman.rb')
require File.expand_path(File.dirname(__FILE__) + '/buildr/osgi/features/pax_logging.rb')