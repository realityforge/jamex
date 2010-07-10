package jamex.link;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.jms.Connection;
import javax.jms.JMSException;
import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.activemq.broker.BrokerService;
import org.apache.activemq.command.ActiveMQDestination;
import org.apache.activemq.command.ActiveMQQueue;
import org.apache.activemq.command.ActiveMQTopic;

final class TestHelper
{
  private static final String BROKER_NAME = "MQ";
  static final String DMQ_NAME = "DeadMessageQueue";
  static final String TOPIC_1_NAME = "TOPIC_1";
  static final String TOPIC_2_NAME = "TOPIC_2";
  static final String QUEUE_1_NAME = "QUEUE_1";
  static final String QUEUE_2_NAME = "QUEUE_2";
  private static BrokerService c_broker;
  private static int c_initDepth;

  static URL createURLForContent( final Class<?> type, final String content, final String suffix )
    throws IOException
  {
    final File file = File.createTempFile( type.getName() + "Test-", "." + suffix );
    file.deleteOnExit();
    final FileOutputStream output = new FileOutputStream( file );
    output.write( content.getBytes( "UTF-8" ) );
    output.close();
    return file.toURI().toURL();
  }

  static void startupBroker()
    throws Exception
  {
    verifyState();
    if( 0 == c_initDepth )
    {
      final ActiveMQDestination[] destinations =
        {
          new ActiveMQQueue( DMQ_NAME ),
          new ActiveMQTopic( TOPIC_1_NAME ),
          new ActiveMQTopic( TOPIC_2_NAME ),
          new ActiveMQQueue( QUEUE_1_NAME ),
          new ActiveMQQueue( QUEUE_2_NAME ),
        };
      final BrokerService broker = new BrokerService();
      broker.setBrokerName( BROKER_NAME );
      broker.setCacheTempDestinations( false );
      broker.setDestinations( destinations );
      broker.setPersistent( false );
      broker.setUseJmx( false );
      broker.setUseShutdownHook( false );
      Logger.getLogger( "org.apache.activemq.broker" ).setLevel( Level.WARNING );
      broker.start();
      c_broker = broker;
    }
    c_initDepth++;
  }

  static void shutdownBroker()
    throws Exception
  {
    verifyState();
    if( 0 == c_initDepth )
    {
      final BrokerService broker = c_broker;
      c_broker = null;
      broker.stop();
    }
    c_initDepth--;
  }

  static Connection createConnection()
    throws JMSException
  {
    final Connection connection =
      new ActiveMQConnectionFactory( "vm://" + BROKER_NAME + "?create=false" ).createConnection();
    connection.setClientID( "TestClient" );
    return connection;
  }

  private static void verifyState()
  {
    if( 0 > c_initDepth ) throw new IllegalStateException( "0 > c_initDepth" );
    if( 0 < c_initDepth && null == c_broker ) throw new IllegalStateException( "0 < c_initDepth && null == c_broker" );
  }
}
