package jamex.link;

import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageConsumer;
import javax.jms.MessageListener;
import javax.jms.MessageProducer;
import javax.jms.Session;
import javax.jms.Topic;

public final class MessageLink
{
  private String m_name;
  private String m_sourceName;
  private String m_subscriptionName;
  private String m_selector;
  private boolean m_isSourceTopic;
  private MessageVerifier m_inputVerifier;

  private String m_destinationName;
  private boolean m_isDestinationTopic;
  private MessageVerifier m_outputVerifier;

  private String m_dmqName;
  private MessageTransformer m_transformer;

  private boolean m_isFrozen;

  private Session m_session;
  private MessageConsumer m_inConsumer;
  private MessageProducer m_outProducer;
  private MessageProducer m_dmqProducer;

  public void setName( final String name )
  {
    ensureEditable();
    m_name = name;
  }

  public void setInputQueue( final String name, final String selector )
  {
    ensureEditable();
    m_sourceName = name;
    m_isSourceTopic = false;
    m_subscriptionName = null;
    m_selector = selector;
  }

  public void setInputTopic( final String name, final String subscription, final String selector )
  {
    ensureEditable();
    if( null == name ) throw new NullPointerException( "name" );
    m_sourceName = name;
    m_isSourceTopic = true;
    m_subscriptionName = subscription;
    m_selector = selector;
  }

  public void setOutputQueue( final String name )
  {
    ensureEditable();
    if( null == name ) throw new NullPointerException( "name" );
    m_destinationName = name;
    m_isDestinationTopic = false;
  }

  public void setOutputTopic( final String name )
  {
    ensureEditable();
    m_destinationName = name;
    m_isDestinationTopic = true;
  }

  public void setDmqName( final String dmqName )
  {
    ensureEditable();
    m_dmqName = dmqName;
  }

  public void setInputVerifier( final MessageVerifier inputVerifier )
  {
    ensureEditable();
    m_inputVerifier = inputVerifier;
  }

  public void setOutputVerifier( final MessageVerifier outputVerifier )
  {
    ensureEditable();
    m_outputVerifier = outputVerifier;
  }

  public void setTransformer( final MessageTransformer transformer )
  {
    ensureEditable();
    m_transformer = transformer;
  }

  public void start( final Session session )
      throws Exception
  {
    if( null == session ) throw invalid( "session must not be null" );
    m_isFrozen = true;
    try
    {
      ensureValidConfig();

      m_session = session;

      final Destination inChannel =
          m_isSourceTopic ? m_session.createTopic( m_sourceName ) : m_session.createQueue( m_sourceName );
      final Destination outChannel =
          m_isDestinationTopic ? m_session.createTopic( m_destinationName ) : m_session.createQueue( m_destinationName );
      final Destination dmq = ( null != m_dmqName ) ? m_session.createQueue( m_dmqName ) : null;

      m_outProducer = m_session.createProducer( outChannel );
      m_dmqProducer = ( null != dmq ) ? m_session.createProducer( dmq ) : null;

      if( null != m_subscriptionName )
      {
        m_inConsumer = m_session.createDurableSubscriber( (Topic)inChannel, m_subscriptionName, m_selector, true );
      }
      else
      {
        m_inConsumer = m_session.createConsumer( inChannel, m_selector );
      }
      m_inConsumer.setMessageListener( new LinkMessageListener() );
    }
    catch( final JMSException e )
    {
      m_isFrozen = false;
      log( "Error starting MessageLink", e );
      stop();
      throw e;
    }
  }

  public void stop()
      throws Exception
  {
    try
    {
      if( null != m_inConsumer ) m_inConsumer.close();
    }
    catch( final JMSException e )
    {
      log( "Closing consumer", e );
    }
    m_inConsumer = null;

    try
    {
      if( null != m_outProducer ) m_outProducer.close();
    }
    catch( final JMSException e )
    {
      log( "Closing producer", e );
    }
    m_outProducer = null;

    try
    {
      if( null != m_dmqProducer ) m_dmqProducer.close();
    }
    catch( final JMSException e )
    {
      log( "Closing producer for dmq", e );
    }
    m_dmqProducer = null;

    try
    {
      if( null != m_session ) m_session.close();
    }
    catch( final JMSException e )
    {
      log( "Closing session", e );
    }
    m_session = null;

    m_isFrozen = false;
  }

  private void doMessage( final Message message )
  {
    try
    {
      if( null != m_inputVerifier ) m_inputVerifier.verifyMessage( message );
    }
    catch( final Exception e )
    {
      handleFailure( message, "Incoming message failed precondition check. Error: " + e, e );
      return;
    }

    final Message output;
    try
    {
      if( null != m_transformer ) output = m_transformer.transformMessage( m_session, message );
      else output = message;
    }
    catch( final Exception e )
    {
      handleFailure( message, "Incoming message failed during message transformation step. Error: " + e, e );
      return;
    }
    if( null != output )
    {
      send( message, output );
    }
  }

  private void handleFailure( final Message inMessage,
                              final String reason,
                              final Throwable t )
  {
    log( reason, t );
    if( null == m_dmqProducer )
    {
      final String message = "Unable to handle message and no DMQ to send message to. Message: " + inMessage;
      throw new IllegalStateException( message );
    }
    final Message message = inMessage;
    try
    {
      message.setStringProperty( "JMLMessageLink", m_name );
      message.setStringProperty( "JMLFailureReason", reason );
      message.setStringProperty( "JMLInChannelName", m_sourceName );
      message.setStringProperty( "JMLInChannelType", m_isSourceTopic ? "Topic" : "Queue" );
      if( null != m_subscriptionName )
      {
        message.setStringProperty( "JMLInSubscriptionName", m_subscriptionName );
      }
      message.setStringProperty( "JMLOutChannelName", m_destinationName );
      message.setStringProperty( "JMLOutChannelType", m_isDestinationTopic ? "Topic" : "Queue" );
      m_dmqProducer.send( message,
                        message.getJMSDeliveryMode(),
                        message.getJMSPriority(),
                        message.getJMSExpiration() );
    }
    catch( final Exception e )
    {
      log( "Failed to send message to DMQ. Error: " + e, e );
      throw new IllegalStateException( "Failed to send message to DMQ. Message: " + inMessage, t );

    }
  }

  private void send( final Message inMessage, final Message outMessage )
  {
    try
    {
      if( null != m_outputVerifier ) m_outputVerifier.verifyMessage( outMessage );
    }
    catch( final Exception e )
    {
      handleFailure( inMessage, "Generated message failed send precondition check. Error: " + e, e );
    }
    try
    {
      m_outProducer.send( outMessage,
                        outMessage.getJMSDeliveryMode(),
                        outMessage.getJMSPriority(),
                        outMessage.getJMSExpiration() );
    }
    catch( final Exception e )
    {
      handleFailure( inMessage, "Failed to send generated message to destination. Error: " + e, e );
    }
  }

  private void ensureValidConfig()
      throws Exception
  {
    if( null == m_sourceName ) throw invalid( "sourceName not specified" );
    else if( null == m_destinationName ) throw invalid( "sourceName not specified" );
    else if( null != m_subscriptionName && !m_isSourceTopic )
    {
      throw invalid( "subscriptionName should only be specified for topics" );
    }
  }

  private Exception invalid( final String message )
  {
    return new IllegalStateException( "MessageLink (" + m_name + ") invalid. Reason: " + message );
  }

  private void log( final String message, final Throwable t )
  {
    synchronized( System.out )
    {
      System.out.println( "MessageLink (" + m_name + ") Error: " + message );
      if( null != t ) t.printStackTrace( System.out );
    }
  }

  private void ensureEditable()
  {
    if( m_isFrozen )
    {
      final String message = "Attempting to edit active MessageLink";
      log( message, null );
      throw new IllegalStateException( "MessageLink (" + m_name + "). " + message );
    }
  }

  private class LinkMessageListener implements MessageListener
  {
    public void onMessage( final Message message )
    {
      doMessage( message );
    }
  }
}
