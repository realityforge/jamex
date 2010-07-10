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
  public void transferFromInputQueueToOutputQueue()
    throws Exception
  {
    final MessageCollector collector = collectResults( TestHelper.QUEUE_2_NAME, false );

    final MessageLink link = new MessageLink();
    link.setInputQueue( TestHelper.QUEUE_1_NAME, null );
    link.setOutputQueue( TestHelper.QUEUE_2_NAME );
    link.setName( "TestLink" );
    link.start( createSession() );

    produceMessages( TestHelper.QUEUE_1_NAME, false, 5 );
    collector.expectMessageCount( 5 );
    link.stop();
  }

  @Test
  public void transferFromInputQueueToOutputQueueWithSelector()
    throws Exception
  {
    final MessageCollector collector = collectResults( TestHelper.QUEUE_2_NAME, false );

    final MessageLink link = new MessageLink();
    link.setInputQueue( TestHelper.QUEUE_1_NAME, HEADER_KEY + " <= 2" );
    link.setOutputQueue( TestHelper.QUEUE_2_NAME );
    link.setName( "TestLink" );
    link.start( createSession() );

    produceMessages( TestHelper.QUEUE_1_NAME, false, 5 );
    collector.expectMessageCount( 3 );

    // Ensure that those not matching selector are still in source queue
    collectResults( TestHelper.QUEUE_1_NAME, false ).expectMessageCount( 2 );

    link.stop();
  }

  @Test
  public void transferFromInputQueueToOutputTopic()
    throws Exception
  {
    final MessageCollector collector = collectResults( TestHelper.TOPIC_2_NAME, true );

    final MessageLink link = new MessageLink();
    link.setInputQueue( TestHelper.QUEUE_1_NAME, null );
    link.setOutputTopic( TestHelper.TOPIC_2_NAME );
    link.setName( "TestLink" );
    link.start( createSession() );

    produceMessages( TestHelper.QUEUE_1_NAME, false, 5 );
    collector.expectMessageCount( 5 );
    link.stop();
  }

  @Test
  public void transferFromInputTopicToOutputQueue()
    throws Exception
  {
    final MessageCollector collector = collectResults( TestHelper.QUEUE_2_NAME, false );

    final MessageLink link = new MessageLink();
    link.setInputTopic( TestHelper.TOPIC_1_NAME, null, null );
    link.setOutputQueue( TestHelper.QUEUE_2_NAME );
    link.setName( "TestLink" );
    link.start( createSession() );

    produceMessages( TestHelper.TOPIC_1_NAME, true, 5 );
    collector.expectMessageCount( 5 );
    link.stop();
  }

  @Test
  public void transferFromInputTopicToOutputQueueWithSelector()
    throws Exception
  {
    final MessageCollector collector = collectResults( TestHelper.QUEUE_2_NAME, false );
    final MessageCollector inputCollector = collectResults( TestHelper.TOPIC_1_NAME, true );

    final MessageLink link = new MessageLink();
    link.setInputTopic( TestHelper.TOPIC_1_NAME, null, HEADER_KEY + " <= 2" );
    link.setOutputQueue( TestHelper.QUEUE_2_NAME );
    link.setName( "TestLink" );
    link.start( createSession() );

    produceMessages( TestHelper.TOPIC_1_NAME, true, 5 );
    collector.expectMessageCount( 3 );

    // Check that 5 went through input even if only 3 flowed through
    inputCollector.expectMessageCount( 5 );

    link.stop();
  }

  @Test
  public void transferFromInputTopicToOutputTopic()
    throws Exception
  {
    final MessageCollector collector = collectResults( TestHelper.TOPIC_2_NAME, true );

    final MessageLink link = new MessageLink();
    link.setInputTopic( TestHelper.TOPIC_1_NAME, null, null );
    link.setOutputTopic( TestHelper.TOPIC_2_NAME );
    link.setName( "TestLink" );
    link.start( createSession() );

    produceMessages( TestHelper.TOPIC_1_NAME, true, 5 );
    collector.expectMessageCount( 5 );
    link.stop();
  }

  @Test
  public void transferFromInputTopicToOutputTopicWithDurableSubscription()
    throws Exception
  {
    final MessageLink link = new MessageLink();
    link.setInputTopic( TestHelper.TOPIC_1_NAME, "MySubscriptionName", null );
    link.setOutputTopic( TestHelper.TOPIC_2_NAME );
    link.setName( "TestLink" );

    link.start( createSession() );
    link.stop();

    // Should work fine as durable subscription exists
    createSession().unsubscribe( "MySubscriptionName" );

    try
    {
      createSession().unsubscribe( "MySubscriptionName" );
    }
    catch( Exception e )
    {
      //Should fail as the subscription has already been removed
    }
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
      publishMessage( session, destination, "Message-" + i, i );
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
