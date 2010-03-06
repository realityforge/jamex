package jamex.connection;

import java.util.Properties;
import javax.jms.Connection;
import javax.jms.ConnectionFactory;
import javax.jms.MessageListener;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.Constants;

public final class Activator
    implements BundleActivator
{
  private SubscribingServiceListener listener;

  public void start( final BundleContext context )
      throws Exception
  {
    final ConnectionFactory factory = new JmsConnectionFactory();
    final Connection connection = factory.createConnection();
    context.registerService( ConnectionFactory.class.getName(),
                             factory,
                             new Properties() );
    listener = new SubscribingServiceListener( context, connection );
    final String filter = "(" + Constants.OBJECTCLASS + "=" + MessageListener.class.getName() + ")";
    context.addServiceListener( listener, filter );
    connection.start();
  }

  public void stop( final BundleContext context )
      throws Exception
  {
    context.removeServiceListener( listener );
  }
}

