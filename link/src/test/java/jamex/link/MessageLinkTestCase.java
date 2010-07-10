package jamex.link;

import javax.jms.DeliveryMode;
import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageConsumer;
import javax.jms.MessageProducer;
import javax.jms.Session;
import org.junit.Test;

public class MessageLinkTestCase
  extends AbstractBrokerBasedTestCase
{
  static final String HEADER_KEY = "MyHeader";

  @Test
  public void transfersFromInputQueueToOutputQueue()
    throws Exception
  {
    // Setup listener for results
    final MessageCollector collector = collectResults( TestHelper.QUEUE_2_NAME, false );

    final MessageLink link = new MessageLink();
    link.setDmqName( TestHelper.DMQ_NAME );
    link.setInputQueue( TestHelper.QUEUE_1_NAME, null );
    link.setOutputQueue( TestHelper.QUEUE_2_NAME );
    link.setName( "TestLink" );

    link.start( createSession() );

    produceMessages( TestHelper.QUEUE_1_NAME, false, 5 );

    collector.expectMessageCount( 5 );

    //link.setInputVerifier( MessageVerifier.newXSDVerifier( Main.class.getResource( "catalog.xsd" ) ) );
    //createLink.setOutputVerifier( MessageVerifier.newXSDVerifier( Main.class.getResource( "catalog.xsd" ) ) );
    // link.setTransformer( MessageTransformer.newXSLTransformer( Main.class.getResource( "transform.xsl" ) ) );
    link.stop();
  }

  private static void publishMessage( final Session session,
                                      final Destination destination,
                                      final String messageContent,
                                      final Object headerValue )
    throws Exception
  {
    final MessageProducer producer = session.createProducer( destination );
    final Message message = session.createTextMessage( messageContent );
    message.setObjectProperty( HEADER_KEY, headerValue );

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

  private void produceMessages( final String channelName, final boolean topic, final int messageCount )
    throws Exception
  {
    final Session session = createSession();
    final Destination destination = createDestination( session, channelName, topic );
    for( int i = 0; i < messageCount; i++ )
    {
      publishMessage( session, destination, "Message-" + i, String.valueOf( i ) );
    }
  }

  private MessageCollector collectResults( final String channelName, final boolean topic )
    throws Exception
  {
    final Session session = createSession();
    final Destination destination = createDestination( session, channelName, topic );
    final MessageConsumer consumer = session.createConsumer( destination );
    final MessageCollector collector = new MessageCollector();
    consumer.setMessageListener( collector );
    return collector;
  }

  private Destination createDestination( final Session session, final String channelName, final boolean topic )
    throws JMSException
  {
    return topic ? session.createTopic( channelName ) : session.createQueue( channelName );
  }
}
