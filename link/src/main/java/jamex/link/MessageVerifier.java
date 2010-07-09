package jamex.link;

import java.io.ByteArrayInputStream;
import java.net.URL;
import java.util.regex.Pattern;
import javax.jms.Message;
import javax.jms.TextMessage;
import javax.xml.XMLConstants;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;

/**
 * Abstract class used to verify a Message matches a format.
 * Instances of this class should be idempotent and thread-safe.
 */
public abstract class MessageVerifier
{
  /**
   * Verify the message matches a specific format.
   *
   * @throws Exception if message format fails to verify.
   */
  public abstract void verifyMessage( Message message ) throws Exception;

  /**
   * Create a verifier that expects expects a TextMessage with content
   * matching XSD specified at URL.
   */
  public static MessageVerifier newXSDVerifier( final URL url )
    throws Exception
  {
    return newXmlVerifier( "XSD", XMLConstants.W3C_XML_SCHEMA_NS_URI, url );
  }

  /**
   * Create a verifier that expects expects a TextMessage with content
   * matching schema specified at URL. The schema language must be supported
   * the underling java.xml.validation API. The string that specifies the
   * schema is typically one of the name spaces specified in {@link javax.xml.XMLConstants}.
   */
  public static MessageVerifier newSchemaBasedVerifier( final String schemaLanguage,
                                                        final URL url )
    throws Exception
  {
    return newXmlVerifier( "Schema", schemaLanguage, url );
  }

  /**
   * Create a MessageVerifier that expects a TextMessage with content
   * matching specified Pattern.
   */
  public static MessageVerifier newRegexVerifier( final Pattern pattern )
    throws Exception
  {
    return new RegexMessageVerifier( pattern );
  }

  private static MessageVerifier newXmlVerifier( final String schemaLabel,
                                                 final String schemaLanguage,
                                                 final URL url )
    throws Exception
  {
    if( null == schemaLanguage ) throw new NullPointerException( "schemaLanguage" );
    if( null == url ) throw new NullPointerException( "url" );
    final SchemaFactory factory = SchemaFactory.newInstance( schemaLanguage );
    final Schema schema = factory.newSchema( url );
    return new XmlMessageVerifier( schemaLabel + " loaded from " + url, schema.newValidator() );
  }

  private static class XmlMessageVerifier
    extends MessageVerifier
  {
    private final String m_noMatchMessage;
    private final Validator m_validator;

    private XmlMessageVerifier( final String noMatchMessage, final Validator validator )
    {
      m_noMatchMessage = noMatchMessage;
      m_validator = validator;
    }

    public void verifyMessage( final Message message ) throws Exception
    {
      final TextMessage textMessage = MessageUtil.castToType( message, TextMessage.class );
      try
      {
        m_validator.validate( new StreamSource( new ByteArrayInputStream( textMessage.getText().getBytes() ) ) );
      }
      catch( final Exception e )
      {
        final String errorMessage =
          "Message with ID = " + message.getJMSMessageID() + " failed to match " + m_noMatchMessage + ".";
        throw new Exception( errorMessage, e );
      }
    }
  }

  private static class RegexMessageVerifier
    extends MessageVerifier
  {
    private final Pattern pattern;

    private RegexMessageVerifier( final Pattern pattern )
    {
      this.pattern = pattern;
    }

    public void verifyMessage( final Message message ) throws Exception
    {
      final TextMessage textMessage = MessageUtil.castToType( message, TextMessage.class );
      if( !pattern.matcher( textMessage.getText() ).matches() )
      {
        final String errorMessage =
          "Message with ID = " + message.getJMSMessageID() +
          " failed to match pattern \"" + pattern.pattern() + "\".";
        throw new Exception( errorMessage );
      }
    }
  }
}

