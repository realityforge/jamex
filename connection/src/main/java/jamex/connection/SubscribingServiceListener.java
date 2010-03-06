package jamex.connection;

import java.util.HashMap;
import java.util.Map;
import javax.jms.Connection;
import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.MessageConsumer;
import javax.jms.MessageListener;
import javax.jms.Session;
import javax.jms.Topic;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceEvent;
import org.osgi.framework.ServiceListener;
import org.osgi.framework.ServiceReference;

/**
 * Subscriber any services published with appropriate key to
 * JMS connections.
 */
public class SubscribingServiceListener
    implements ServiceListener
{
  private static class Registration
  {
    final Session session;
    final MessageConsumer consumer;

    private Registration( final Session session, final MessageConsumer consumer )
    {
      this.session = session;
      this.consumer = consumer;
    }
  }

  private final Map<ServiceReference, Registration> registrations = new HashMap<ServiceReference, Registration>();
  private final BundleContext context;
  private final Connection connection;

  public SubscribingServiceListener( final BundleContext context,
                                     final Connection connection )
  {
    this.context = context;
    this.connection = connection;
  }

  @Override
  public void serviceChanged( final ServiceEvent event )
  {
    final ServiceReference reference = event.getServiceReference();
    final int type = event.getType();

    String errorHeader = "";
    try
    {
      if( ServiceEvent.REGISTERED == type )
      {
        errorHeader = "REGISTERED";
        subscribe( reference );
      }
      else if( ServiceEvent.MODIFIED == type )
      {
        errorHeader = "MODIFIED";
        unsubscribe( reference );
        subscribe( reference );
      }
      else //ServiceEvent.UNREGISTERING:
      {
        errorHeader = "UNREGISTERING";
        unsubscribe( reference );
      }
    }
    catch( final Exception e )
    {
      synchronized( System.out )
      {
        System.out.println( "Error processing " + errorHeader + " event for " + reference );
        e.printStackTrace( System.out );
      }
    }
  }

  private void unsubscribe( final ServiceReference reference )
      throws Exception
  {
    System.out.println( "unsubscribe(" + reference + ")" );
    final Registration registration = registrations.get( reference );
    if( null == registration )
    {
      final String message = "Unable to un-subscribe as missing registration.";
      throw new Exception( message );
    }
    else
    {
      try
      {
        registration.consumer.close();
      }
      catch( final JMSException e )
      {
        final String message = "Problem un-subscribing listener.";
        throw new Exception( message, e );
      }
      finally
      {
        try
        {
          registration.session.close();
        }
        catch( final JMSException e )
        {
          final String message = "Problem un-subscribing listener.";
          throw new Exception( message, e );
        }
      }
    }
  }

  private void subscribe( final ServiceReference reference )
      throws Exception
  {
    System.out.println( "subscribe(" + reference + ")" );
    final MessageListener service = toMessageListener( reference );

    final Map<String, Object> properties = propertiesToMap( reference );

    final String queueName = getProperty( properties, "queue", String.class, false );
    final String topicName = getProperty( properties, "topic", String.class, false );
    if( ( null == queueName && null == topicName ) ||
        ( null != queueName && null != topicName ) )
    {
      final String message = "One and only one of the 'queue' or 'topic' properties must be defined.";
      throw new IllegalArgumentException( message );
    }

    final String subscriptionName = getProperty( properties, "subscription", String.class, false );
    if( null == topicName && null != subscriptionName )
    {
      final String message = "The 'subscription' property is only valid when 'topic' property is specified.";
      throw new IllegalArgumentException( message );
    }

    final String selector = getProperty( properties, "selector", String.class, false );

    final Boolean noLocal = getProperty( properties, "noLocal", Boolean.class, false, Boolean.FALSE );

    final Session session = connection.createSession( false, Session.AUTO_ACKNOWLEDGE );
    final Destination destination;
    if( null != queueName )
    {
      destination = session.createQueue( queueName );
    }
    else
    {
      destination = session.createTopic( topicName );
    }

    final MessageConsumer consumer;
    if( null == subscriptionName )
    {
      consumer = session.createConsumer( destination, selector, noLocal );
    }
    else
    {
      consumer = session.createDurableSubscriber( (Topic)destination, subscriptionName, selector, noLocal );
    }
    boolean success = false;
    try
    {
      consumer.setMessageListener( service );
      success = true;
    }
    finally
    {
      try
      {
        if( !success ) consumer.close();
      }
      catch( final JMSException e )
      {
        //ignore
      }
    }
    registrations.put( reference, new Registration( session, consumer ) );
  }

  private <T> T getProperty( final Map<String, Object> properties,
                             final String key,
                             final Class<T> type,
                             final boolean required )
  {
    return getProperty( properties, key, type, required, null );
  }

  private <T> T getProperty( final Map<String, Object> properties,
                             final String key,
                             final Class<T> type,
                             final boolean required,
                             final Object defaultValue )
  {
    final Object value = properties.remove( key );
    if( required && null == value )
    {
      throw new IllegalArgumentException( "Property named '" + key + "' is missing" );
    }
    else if( null == value )
    {
      return this.<T>cast( defaultValue );
    }
    else if( type.isInstance( value ) )
    {
      return this.<T>cast( value );
    }
    else
    {
      throw new IllegalArgumentException( "Property named '" + key + "' is of type '" +
                                          value.getClass().getName() + " instead of the " +
                                          "expected " + type.getName() );
    }
  }

  private HashMap<String, Object> propertiesToMap( final ServiceReference reference )
  {
    final HashMap<String, Object> result = new HashMap<String, Object>();
    for( final String key : reference.getPropertyKeys() )
    {
      result.put( key, reference.getProperty( key ) );
    }
    return result;
  }

  private MessageListener toMessageListener( final ServiceReference reference )
  {
    final Object o = context.getService( reference );
    if( null == o || !( o instanceof MessageListener ) )
    {
      final String message = "ServiceReference '" + reference + "' expected to reference active MessageListener";
      throw new IllegalArgumentException( message );
    }
    return (MessageListener)o;
  }

  @SuppressWarnings( { "unchecked" } )
  public <T> T cast( final Object message )
  {
    return (T)message;
  }
}
