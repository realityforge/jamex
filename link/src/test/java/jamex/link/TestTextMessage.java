package jamex.link;

import java.util.Enumeration;
import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.TextMessage;

final class TestTextMessage
    implements TextMessage
{
  private final String m_id;
  private final String m_text;

  TestTextMessage( final String id, final String text )
  {
    m_id = id;
    m_text = text;
  }

  @Override
  public void setText( final String string ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public String getText() throws JMSException
  {
    return m_text;
  }

  @Override
  public String getJMSMessageID() throws JMSException
  {
    return m_id;
  }

  @Override
  public void setJMSMessageID( final String id ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public long getJMSTimestamp() throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void setJMSTimestamp( final long timestamp ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public byte[] getJMSCorrelationIDAsBytes() throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void setJMSCorrelationIDAsBytes( final byte[] correlationID ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void setJMSCorrelationID( final String correlationID ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public String getJMSCorrelationID() throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public Destination getJMSReplyTo() throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void setJMSReplyTo( final Destination replyTo ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public Destination getJMSDestination() throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void setJMSDestination( final Destination destination ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public int getJMSDeliveryMode() throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void setJMSDeliveryMode( final int deliveryMode ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public boolean getJMSRedelivered() throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void setJMSRedelivered( final boolean redelivered ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public String getJMSType() throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void setJMSType( final String type ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public long getJMSExpiration() throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void setJMSExpiration( final long expiration ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public int getJMSPriority() throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void setJMSPriority( final int priority ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void clearProperties() throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public boolean propertyExists( final String name ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public boolean getBooleanProperty( final String name ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public byte getByteProperty( final String name ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public short getShortProperty( final String name ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public int getIntProperty( final String name ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public long getLongProperty( final String name ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public float getFloatProperty( final String name ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public double getDoubleProperty( final String name ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public String getStringProperty( final String name ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public Object getObjectProperty( final String name ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public Enumeration getPropertyNames() throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void setBooleanProperty( final String name, final boolean value ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void setByteProperty( final String name, final byte value ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void setShortProperty( final String name, final short value ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void setIntProperty( final String name, final int value ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void setLongProperty( final String name, final long value ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void setFloatProperty( final String name, final float value ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void setDoubleProperty( final String name, final double value ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void setStringProperty( final String name, final String value ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void setObjectProperty( final String name, final Object value ) throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void acknowledge() throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public void clearBody() throws JMSException
  {
    throw new UnsupportedOperationException();
  }

  @Override
  public String toString()
  {
    return "TextMessage[ID=" + m_id + "]";
  }
}
