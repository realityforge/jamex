require 'buildr/bnd'
require 'buildr_ipojo'
require 'buildr/java/cobertura'

IPOJO_ANNOTATIONS = Buildr::Ipojo.annotation_artifact

KARAF_DIR="/home/peter/apache-karaf-2.0.0/"

class CentralLayout < Layout::Default
  def initialize(key, top_level, use_subdir)
    super()
    prefix = top_level ? '' : '../'
    subdir = use_subdir ? "/#{key}" : ''
    self[:target] = "#{prefix}target#{subdir}"
    self[:target, :main] = "#{prefix}target#{subdir}"
    self[:reports] = "#{prefix}reports#{subdir}"
  end
end

def define_with_central_layout(name, top_level = false, use_subdir = true, & block)
  define(name, :layout => CentralLayout.new(name, top_level, use_subdir), & block)
end

desc 'Jamex: OSGi bundle for OpenMQ provider client library'
define_with_central_layout('com.sun.messaging.mq.imq', true) do
  project.version = '4.4'
  project.group = 'jamex'
  compile.options.source = '1.6'
  compile.options.target = '1.6'
  compile.options.lint = 'all'
  project.no_ipr
  iml.skip_content!
  compile.with :imq
  package(:bundle).tap do |bnd|
    bnd['Import-Package'] = "*;resolution:=optional"
    bnd['Export-Package'] = "com.sun.messaging.*;version=#{version}"
  end
end

desc 'Jamex: An osgi based jms router in it''s infancy'
define_with_central_layout('jamex', true, false) do
  project.version = '0.1.1-SNAPSHOT'
  project.group = 'jamex'
  compile.options.source = '1.6'
  compile.options.target = '1.6'
  compile.options.lint = 'all'

  ipr.extra_modules << 'com.sun.messaging.mq.imq.iml'
  ipr.template = _('etc/project-template.ipr')

  desc 'Jamex: JMS ConnectionFactory'
  define_with_central_layout 'connection' do
    compile.with :jms, :osgi_core, IPOJO_ANNOTATIONS, projects('com.sun.messaging.mq.imq')
    project.ipojoize!

    package(:bundle).tap do |bnd|
      bnd['Export-Package'] = "jamex.connection.*;version=#{version}"
    end
  end

  desc 'Jamex: Simple component that registers routes between destinations'
  define_with_central_layout 'routes' do
    compile.with :jms, :osgi_core, :osgi_compendium, IPOJO_ANNOTATIONS, :jml
    project.ipojoize!
    package(:bundle).tap do |bnd|
      bnd['Export-Package'] = "jamex.routes.*;version=#{version}"
    end
  end

  desc "Deploy files require to run to a Karaf instance"
  task :deploy_to_karaf do
    cp artifacts([JML,
                  project('connection').package(:bundle),
                  project('com.sun.messaging.mq.imq').package(:bundle),
                  project('routes').package(:bundle)]).collect { |a| a.invoke; a.to_s },
       "#{KARAF_DIR}/deploy/"
    cp_r Dir["#{_('etc/dist')}/**"], KARAF_DIR
  end
end
