package jamex.connection;

import javax.jms.Connection;
import javax.jms.ConnectionFactory;
import javax.jms.JMSException;

final class JmsConnectionFactory
    implements ConnectionFactory
{
  private static final String MQ_ADDRESS_LIST = "localhost:7676";
  private static final String USERNAME = "admin";
  private static final String PASSWORD = "admin";
  private static final String CLIENT_ID = "MyClient";

  @Override
  public Connection createConnection() throws JMSException
  {

    final ConnectionFactory factory = setupConnectionFactory();
    final Connection connection = factory.createConnection( USERNAME, PASSWORD );
    connection.setClientID( CLIENT_ID );
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

  private static ConnectionFactory setupConnectionFactory()
      throws JMSException
  {
    final com.sun.messaging.ConnectionFactory factory = new com.sun.messaging.ConnectionFactory();
    factory.setProperty( com.sun.messaging.ConnectionConfiguration.imqAddressList, MQ_ADDRESS_LIST );
    return factory;
  }
}
