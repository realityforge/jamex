package jamex.connection;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;
import javax.jms.Connection;
import javax.jms.ConnectionFactory;
import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.MessageConsumer;
import javax.jms.MessageListener;
import javax.jms.Session;
import javax.jms.Topic;
import org.apache.felix.ipojo.annotations.Component;
import org.apache.felix.ipojo.annotations.Invalidate;
import org.apache.felix.ipojo.annotations.Requires;
import org.apache.felix.ipojo.annotations.Validate;
import org.apache.felix.ipojo.handlers.jmx.Config;
import org.apache.felix.ipojo.whiteboard.Wbp;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceReference;

/**
 * Subscriber any services published with appropriate key to
 * JMS connections.
 */
@Component( name = "SubscribingServiceListener", immediate = true, managedservice = "SubscribingServiceListener" )
@Wbp( filter = "(|(queue=*)(topic=*))",
      onArrival = "onArrival",
      onDeparture = "onDeparture",
      onModification = "onModification" )
@Config( domain = "my-domain", usesMOSGi = false )
public class SubscribingServiceListener
{
  private static class Registration
  {
    final MessageListener listener;
    final Map<String, Object> properties;
    final Session session;
    final MessageConsumer consumer;

    private Registration( final MessageListener listener,
                          final Map<String, Object> properties,
                          final Session session,
                          final MessageConsumer consumer )
    {
      this.listener = listener;
      this.properties = properties;
      this.session = session;
      this.consumer = consumer;
    }
  }

  private final LinkedList<Registration> registrations = new LinkedList<Registration>();
  private Connection connection;
  private BundleContext bundleContext;

  @Requires
  private ConnectionFactory m_factory;

  public SubscribingServiceListener( final BundleContext bundleContext )
  {
    System.out.println( "SubscribingServiceListener.SubscribingServiceListener" );
    this.bundleContext = bundleContext;
  }

  @SuppressWarnings( { "UnusedDeclaration" } )
  public void onArrival( final ServiceReference reference )
    throws Exception
  {
    System.out.println( "SubscribingServiceListener.onArrival" );
    subscribe( (MessageListener)bundleContext.getService( reference ),
               propertiesToMap( reference ) );
  }

  @SuppressWarnings( { "UnusedDeclaration" } )
  public void onDeparture( final ServiceReference reference )
    throws Exception
  {
    System.out.println( "SubscribingServiceListener.onDeparture" );
    unsubscribe( (MessageListener)bundleContext.getService( reference ) );
  }

  @SuppressWarnings( { "UnusedDeclaration" } )
  public void onModification( final ServiceReference reference )
    throws Exception
  {
    System.out.println( "SubscribingServiceListener.onModification" );
    final MessageListener listener = (MessageListener)bundleContext.getService( reference );
    unsubscribe( listener );
    subscribe( listener, propertiesToMap( reference ) );
  }

  @Validate
  public void start()
    throws Exception
  {
    System.out.println( "SubscribingServiceListener.start" );
    connection = m_factory.createConnection();
    connection.start();
  }

  @Invalidate
  public void stop()
  {
    System.out.println( "SubscribingServiceListener.stop" );
    if( null != connection )
    {
      try
      {
        connection.close();
      }
      catch( JMSException e )
      {
        e.printStackTrace();
      }
    }
  }

  private void unsubscribe( final MessageListener listener )
    throws Exception
  {
    System.out.println( "unsubscribe(" + listener + ")" );
    Registration registration = null;
    for( final Registration candidate : registrations )
    {
      if( candidate.listener == listener )
      {
        registration = candidate;
        break;
      }
    }
    if( null == registration )
    {
      final String message = "Unable to un-subscribe as missing registration.";
      throw new Exception( message );
    }
    else
    {
      performUnsubscribe( registration );
    }
  }

  private void performUnsubscribe( final Registration registration )
    throws Exception
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

  private void subscribe( final MessageListener service, final Map<String, Object> properties )
    throws JMSException
  {
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
    registrations.add( new Registration( service, properties, session, consumer ) );
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
      return type.cast( defaultValue );
    }
    else if( type.isInstance( value ) )
    {
      return type.cast( value );
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
}
