package jamex.connection;

import java.util.Properties;
import javax.jms.Connection;
import javax.jms.ConnectionFactory;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

public final class Activator
    implements BundleActivator
{
  private SubscribingServiceListener listener;
  private Connection connection;

  public void start( final BundleContext context )
      throws Exception
  {
    final ConnectionFactory factory = new JmsConnectionFactory();
    connection = factory.createConnection();
    context.registerService( ConnectionFactory.class.getName(),
                             factory,
                             new Properties() );
    listener = new SubscribingServiceListener( context, connection );
    listener.start();
    connection.start();
  }

  public void stop( final BundleContext context )
      throws Exception
  {
    listener.stop();
    connection.stop();
  }
}

