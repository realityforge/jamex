package jamex.routes;

import javax.jms.Connection;
import javax.jms.ConnectionFactory;
import javax.jms.DeliveryMode;
import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.MessageProducer;
import javax.jms.Session;
import jml.MessageLink;
import org.apache.felix.ipojo.annotations.Component;
import org.apache.felix.ipojo.annotations.Invalidate;
import org.apache.felix.ipojo.annotations.Provides;
import org.apache.felix.ipojo.annotations.Requires;
import org.apache.felix.ipojo.annotations.ServiceProperty;
import org.apache.felix.ipojo.annotations.Validate;
import org.apache.felix.ipojo.handlers.jmx.Config;
import org.apache.felix.ipojo.handlers.jmx.Method;
import org.apache.felix.ipojo.handlers.jmx.Property;

@Component( name = "BasicRoutes", managedservice = "XXXXX", immediate = true )
@Config( domain = "my-domain", usesMOSGi = false )
@Provides
public final class BasicRoutes
  implements MessageListener
{
  private static final String DMQ_NAME = "DeadMessageQueue";
  private static final String CHANNEL_1_NAME = "CHANNEL_1";
  private static final String CHANNEL_2_NAME = "CHANNEL_2";
  private MessageLink link;
  private Session producerSession;
  private Connection connection;
  @Requires
  private ConnectionFactory factory;

  public BasicRoutes()
  {
    System.out.println( "BasicRoutes.BasicRoutes" );
  }

  @ServiceProperty(name = "queue", value = CHANNEL_2_NAME)
  private String m_queue = CHANNEL_2_NAME;

  // Field published in the MBean
  @Property( name = "message", notification = true, rights = "w" )
  private String m_message = "MyMessage";

  @Method( description = "Says hello" )
  public void sayHello()
  {
    System.out.println( "BasicRoutes.sayHello(" + m_message + ")" );
  }

  /**
   * Called whenever the OSGi framework starts our bundle
   */
  @Validate
  public void start() throws Exception
  {
    try
    {
      System.out.println( "BasicRoutes.start" );
      connection = factory.createConnection();

      link = createLink();
      link.start( connection.createSession( false, Session.AUTO_ACKNOWLEDGE ) );

      producerSession = connection.createSession( false, Session.AUTO_ACKNOWLEDGE );
      for( int i = 0; i < 5; i++ )
      {
        publish( producerSession, getMessage() );
      }

      connection.start();
    }
    catch( final Exception e )
    {
      stop();
      throw e;
    }
  }

  /**
   * Called whenever the OSGi framework stops our bundle
   */
  @Invalidate
  public void stop()
  {
    System.out.println( "BasicRoutes.stop" );
    try
    {
      if( null != link ) link.stop();
    }
    catch( final Exception e )
    {
      e.printStackTrace();
    }
    try
    {
      if( null != producerSession ) producerSession.close();
    }
    catch( final Exception e )
    {
      e.printStackTrace();
    }
    try
    {
      if( null != connection ) connection.close();
    }
    catch( final Exception e )
    {
      e.printStackTrace();
    }
  }

  private String getMessage()
    throws Exception
  {
    return m_message;
  }

  private MessageLink createLink()
    throws Exception
  {
    log( "createLink()" );
    final MessageLink link = new MessageLink();
    link.setDmqName( DMQ_NAME );
    link.setInputChannel( "queue://" + CHANNEL_1_NAME, null, null );
    link.setOutputChannel( "queue://" + m_queue );
    link.setName( "MrLink" );

    return link;
  }

  private static void publish( final Session session, final String messageContent )
  {
    log( "publish()" );
    try
    {
      final Destination destination = session.createQueue( CHANNEL_1_NAME );
      final MessageProducer producer = session.createProducer( destination );
      final Message message = session.createTextMessage( messageContent );

      // Disable generation of ids as we don't care about them
      // (Actually ignored by OMQ)
      producer.setDisableMessageID( true );
      // Disable generation of approximate transmit timestamps as we don't care about them
      producer.setDisableMessageTimestamp( true );
      producer.setPriority( 1 );
      producer.setDeliveryMode( DeliveryMode.NON_PERSISTENT );
      producer.send( message );
      producer.close();
    }
    catch( final JMSException e )
    {
      e.printStackTrace();
    }
  }

  static void log( final String message )
  {
    synchronized( System.out )
    {
      System.out.println( message );
    }
  }

  static void log( final Throwable t )
  {
    synchronized( System.out )
    {
      t.printStackTrace( System.out );
    }
  }

  public void onMessage( final Message message )
  {
    try
    {
      log( "onMessage() received => " + message.getJMSMessageID() );
    }
    catch( final JMSException e )
    {
      log( e );
      e.printStackTrace();
    }
  }
}

