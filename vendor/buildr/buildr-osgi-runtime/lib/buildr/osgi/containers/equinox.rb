module Buildr
  module OSGi
    module Containers
      class Equinox < Container
        FRAMEWORK = "org.eclipse:osgi:jar:3.5.1.R35x_v20090827"
        
        def bundles
          [
              Bundle.new(FRAMEWORK, 0),
          ]
        end

        def generate_to(control_task, path)
          directory("#{path}/tmp")
          directory("#{path}/var/log")
          control_task.enhance [ config_file_task(path),
                                 sh_startup_file_task(path),
                                 bat_startup_file_task(path),
                                 "#{path}/tmp",
                                 "#{path}/var/log" ]
        end

        protected

        def startup_jar_path
          self.runtime.bundle_path(bundles[0])
        end

        def bat_startup_file_task(path)
          file_generate_task("#{path}/run.bat") do |f|
            f.write "java -jar #{startup_jar_path} -configuration #{configuration_dir} %*\n"
          end
        end

        def sh_startup_file_task(path)
          file_generate_task("#{path}/run.sh") do |f|
            f.write "java -jar #{startup_jar_path} -configuration #{configuration_dir} $*\n"
          end
        end

        def config_file_task(path)
          properties_file("#{path}/#{configuration_dir}/config.ini", to_config)
        end

        def to_config
          params = OrderedHash.new
          params['eclipse.product'] = runtime.project.name
          params['eclipse.ignoreApp'] = true
          params['osgi.clean'] = 'true'
          params['osgi.syspath'] = '.'
          params['osgi.startLevel'] = Bundle::MAX_RUN_LEVEL
          params['osgi.bundles.defaultStartLevel'] = Bundle::DEFAULT_RUN_LEVEL
          params['org.osgi.framework.executionenvironment'] = "J2SE-1.2,J2SE-1.3,J2SE-1.4,J2SE-1.5,JRE-1.1,JavaSE-1.6,OSGi/Minimum-1.0,OSGi/Minimum-1.1,OSGi/Minimum-1.2"
          params['org.osgi.framework.bootdelegation'] = 'java.*'
          params['org.osgi.framework.system.packages'] = 'javax.accessibility,javax.activation,javax.activity,javax.annotation,javax.annotation.processing,javax.crypto,javax.crypto.interfaces,javax.crypto.spec,javax.imageio,javax.imageio.event,javax.imageio.metadata,javax.imageio.plugins.bmp,javax.imageio.plugins.jpeg,javax.imageio.spi,javax.imageio.stream,javax.jws,javax.jws.soap,javax.lang.model,javax.lang.model.element,javax.lang.model.type,javax.lang.model.util,javax.management,javax.management.loading,javax.management.modelmbean,javax.management.monitor,javax.management.openmbean,javax.management.relation,javax.management.remote,javax.management.remote.rmi,javax.management.timer,javax.naming,javax.naming.directory,javax.naming.event,javax.naming.ldap,javax.naming.spi,javax.net,javax.net.ssl,javax.print,javax.print.attribute,javax.print.attribute.standard,javax.print.event,javax.rmi,javax.rmi.CORBA,javax.rmi.ssl,javax.script,javax.security.auth,javax.security.auth.callback,javax.security.auth.kerberos,javax.security.auth.login,javax.security.auth.spi,javax.security.auth.x500,javax.security.cert,javax.security.sasl,javax.sound.midi,javax.sound.midi.spi,javax.sound.sampled,javax.sound.sampled.spi,javax.sql,javax.sql.rowset,javax.sql.rowset.serial,javax.sql.rowset.spi,javax.swing,javax.swing.border,javax.swing.colorchooser,javax.swing.event,javax.swing.filechooser,javax.swing.plaf,javax.swing.plaf.basic,javax.swing.plaf.metal,javax.swing.plaf.multi,javax.swing.plaf.synth,javax.swing.table,javax.swing.text,javax.swing.text.html,javax.swing.text.html.parser,javax.swing.text.rtf,javax.swing.tree,javax.swing.undo,javax.tools,javax.transaction,javax.transaction.xa,javax.xml,javax.xml.bind,javax.xml.bind.annotation,javax.xml.bind.annotation.adapters,javax.xml.bind.attachment,javax.xml.bind.helpers,javax.xml.bind.util,javax.xml.crypto,javax.xml.crypto.dom,javax.xml.crypto.dsig,javax.xml.crypto.dsig.dom,javax.xml.crypto.dsig.keyinfo,javax.xml.crypto.dsig.spec,javax.xml.datatype,javax.xml.namespace,javax.xml.parsers,javax.xml.soap,javax.xml.stream,javax.xml.stream.events,javax.xml.stream.util,javax.xml.transform,javax.xml.transform.dom,javax.xml.transform.sax,javax.xml.transform.stax,javax.xml.transform.stream,javax.xml.validation,javax.xml.ws,javax.xml.ws.handler,javax.xml.ws.handler.soap,javax.xml.ws.http,javax.xml.ws.soap,javax.xml.ws.spi,javax.xml.xpath,org.ietf.jgss,org.omg.CORBA,org.omg.CORBA.DynAnyPackage,org.omg.CORBA.ORBPackage,org.omg.CORBA.TypeCodePackage,org.omg.CORBA.portable,org.omg.CORBA_2_3,org.omg.CORBA_2_3.portable,org.omg.CosNaming,org.omg.CosNaming.NamingContextExtPackage,org.omg.CosNaming.NamingContextPackage,org.omg.Dynamic,org.omg.DynamicAny,org.omg.DynamicAny.DynAnyFactoryPackage,org.omg.DynamicAny.DynAnyPackage,org.omg.IOP,org.omg.IOP.CodecFactoryPackage,org.omg.IOP.CodecPackage,org.omg.Messaging,org.omg.PortableInterceptor,org.omg.PortableInterceptor.ORBInitInfoPackage,org.omg.PortableServer,org.omg.PortableServer.CurrentPackage,org.omg.PortableServer.POAManagerPackage,org.omg.PortableServer.POAPackage,org.omg.PortableServer.ServantLocatorPackage,org.omg.PortableServer.portable,org.omg.SendingContext,org.omg.stub.java.rmi,org.w3c.dom,org.w3c.dom.bootstrap,org.w3c.dom.css,org.w3c.dom.events,org.w3c.dom.html,org.w3c.dom.ls,org.w3c.dom.ranges,org.w3c.dom.stylesheets,org.w3c.dom.traversal,org.w3c.dom.views ,org.xml.sax,org.xml.sax.ext,org.xml.sax.helpers'
          #params['osgi.requiredJavaVersion'] = '1.6'
          params['osgi.resolverMode'] = 'strict'
          params['java.io.tmpdir'] = 'tmp'

          enabled_bundles = self.runtime.bundles.select{|b| b.enable?}

          params['osgi.bundles'] = enabled_bundles.collect do |bundle|
            "reference:file:#{self.runtime.bundle_path(bundle)}@#{bundle.run_level}:start"
          end.join(", \\\n")

          self.runtime.features.each do |feature|
            params.update(feature.system_properties)
          end

          params.update(parameters)
          params.update(system_properties)
          params.update(runtime.system_properties)
        end
      end
    end

    class Runtime
      protected

      def create_equinox_container
        Containers::Equinox.new(self)
      end
    end
  end
end