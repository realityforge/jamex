package jamex.connection;

import java.util.Properties;

import javax.jms.ConnectionFactory;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

public final class Activator
    implements BundleActivator
{
    public void start( BundleContext bc )
        throws Exception
    {
        bc.registerService( ConnectionFactory.class.getName(), 
                            new JmsConnectionFactory(),
                            new Properties( ) );
    }

    /**
     * Called whenever the OSGi framework stops our bundle
     */
    public void stop( BundleContext bc )
        throws Exception
    {

    }
}

