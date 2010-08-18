package jamex.connection;

import javax.jms.Connection;
import javax.jms.ConnectionFactory;
import javax.jms.JMSException;
import org.apache.felix.ipojo.annotations.Component;
import org.apache.felix.ipojo.annotations.Invalidate;
import org.apache.felix.ipojo.annotations.PostRegistration;
import org.apache.felix.ipojo.annotations.PostUnregistration;
import org.apache.felix.ipojo.annotations.Provides;
import org.apache.felix.ipojo.annotations.ServiceController;
import org.apache.felix.ipojo.annotations.Validate;
import org.osgi.framework.ServiceReference;

@Component( architecture = true, name = "OMQConnectionFactory", managedservice = "OMQConnectionFactory" )
@Provides
public final class JmsConnectionFactory
  implements ConnectionFactory
{
  private static final String MQ_ADDRESS_LIST = "localhost:7676";
  private static final String USERNAME = "admin";
  private static final String PASSWORD = "admin";
  private static final String CLIENT_ID = "MyClient";

  private int connectionCount;

  private ConnectionFactory m_factory;

  @ServiceController
  private boolean m_valid;

  @PostRegistration
  public void PostRegistration( ServiceReference ref )
  {
    System.out.println( "JmsConnectionFactory.PostRegistration" );
  }

  @PostUnregistration
  public void PostUnregistration( ServiceReference ref )
  {
    System.out.println( "JmsConnectionFactory.PostUnregistration" );
  }

  @Validate
  public void init()
  {
    System.out.println( "JmsConnectionFactory.init" );
    try
    {
      final com.sun.messaging.ConnectionFactory factory = new com.sun.messaging.ConnectionFactory();
      factory.setProperty( com.sun.messaging.ConnectionConfiguration.imqAddressList, MQ_ADDRESS_LIST );
      m_factory = factory;
      m_valid = true;
    }
    catch( final JMSException jme )
    {
      m_valid = false;
    }
  }

  @Invalidate
  public void dispose()
  {
    System.out.println( "JmsConnectionFactory.dispose" );
    m_factory = null;
    m_valid = false;
  }

  @Override
  public Connection createConnection() throws JMSException
  {
    System.out.println( "JmsConnectionFactory.createConnection" );
    final Connection connection = m_factory.createConnection( USERNAME, PASSWORD );
    connection.setClientID( CLIENT_ID + "-" + System.identityHashCode( this ) + "-" + ( ++connectionCount ) );
    //connection.setExceptionListener( new MyExceptionListener() );
    return connection;
  }

  @Override
  public Connection createConnection( final String userName,
                                      final String password )
    throws JMSException
  {
    throw new JMSException( "Not supported" );
  }
}
