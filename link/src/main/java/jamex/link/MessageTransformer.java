package jamex.link;

import java.io.ByteArrayOutputStream;
import java.io.StringReader;
import java.net.URL;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.Session;
import javax.jms.TextMessage;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

/**
 * Abstract class for services that transform one messages.
 * Instances of this class should be idempotent and thread-safe.
 */
public abstract class MessageTransformer
{
  /**
   * Return the message passed in parameter with the transformation applied.
   *
   * @param session the session associated with the message.
   * @param message the message to transform.
   * @return the transformed message.
   * @throws Exception if there is a problem transforming message.
   */
  public abstract Message transformMessage( final Session session, final Message message )
    throws Exception;

  /**
   * Create a transformer that expects an XML formatted TextMessage and attempts to
   * apply an XSLT transform. Uses the underlying javax.xml.transform API. 
   *
   * @param url the url of XSLT sheet
   */
  public static MessageTransformer newXSLTransformer( final URL url )
    throws Exception
  {
    if( null == url ) throw new NullPointerException( "url" );
    final Source source = new StreamSource( url.openStream() );
    final TransformerFactory factory = TransformerFactory.newInstance();
    final Transformer transformer = factory.newTransformer( source );
    return new XslMessageTransformer( transformer );
  }

  private static class XslMessageTransformer
    extends MessageTransformer
  {
    private final Transformer m_transformer;

    private XslMessageTransformer( final Transformer transformer )
    {
      m_transformer = transformer;
    }

    @Override
    public Message transformMessage( final Session session, final Message message )
      throws Exception
    {
      final TextMessage textMessage = MessageUtil.castToType( message, TextMessage.class );
      final String text = transformText( textMessage );

      final TextMessage result = session.createTextMessage( text );
      MessageUtil.copyMessageHeaders( textMessage, result );

      return result;
    }

    private String transformText( final TextMessage textMessage )
      throws JMSException, TransformerException
    {
      final Source xmlSource = new StreamSource( new StringReader( textMessage.getText() ) );
      final ByteArrayOutputStream baos = new ByteArrayOutputStream();
      final Result result = new StreamResult( baos );
      m_transformer.transform( xmlSource, result );
      return baos.toString();
    }
  }
}