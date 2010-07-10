package jamex.link;

import java.net.URL;
import java.util.regex.Pattern;
import javax.jms.TextMessage;
import javax.xml.XMLConstants;
import static org.junit.Assert.*;
import org.junit.Test;

public class MessageVerifierTestCase
  extends AbstractBrokerBasedTestCase
{
  @Test
  public void regexVerifier()
    throws Exception
  {
    final TextMessage message = createSession().createTextMessage( "myMessage" );
    try
    {
      MessageVerifier.newRegexVerifier( Pattern.compile( ".*Message" ) ).verifyMessage( message );
    }
    catch( final Exception e )
    {
      e.printStackTrace();
      fail( "Expected to be able to verify message but got " + e );
    }

    try
    {
      MessageVerifier.newRegexVerifier( Pattern.compile( "Not.*Message" ) ).verifyMessage( message );
      fail( "Expected to not be able to verify message" );
    }
    catch( final Exception e )
    {
      assertEquals( "e.getMessage()",
                    "Message with ID = " + message.getJMSMessageID() + " failed to match pattern \"Not.*Message\".",
                    e.getMessage() );
    }
  }

  @Test
  public void xsdVerifier()
    throws Exception
  {
    final String xsd = "<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?>\n" +
                       "<xs:schema xmlns:xs=\"http://www.w3.org/2001/XMLSchema\">\n" +
                       "  <xs:element name=\"a\">\n" +
                       "    <xs:complexType>\n" +
                       "      <xs:attribute name=\"orderid\" type=\"xs:string\" use=\"required\"/>\n" +
                       "    </xs:complexType>" +
                       "  </xs:element>\n" +
                       "</xs:schema>\n";

    final URL url = TestHelper.createURLForContent( MessageVerifierTestCase.class, xsd, "xsd" );
    TextMessage message = null;
    try
    {
      message = createSession().createTextMessage( "<a orderid=\"x\"/>" );
      MessageVerifier.newXSDVerifier( url ).verifyMessage( message );
    }
    catch( final Exception e )
    {
      e.printStackTrace();
      fail( "Expected to be able to verify message but got " + e );
    }

    try
    {
      message = createSession().createTextMessage( "<a orderid=\"x\"/>" );
      MessageVerifier.newSchemaBasedVerifier( XMLConstants.W3C_XML_SCHEMA_NS_URI, url ).verifyMessage( message );
    }
    catch( final Exception e )
    {
      e.printStackTrace();
      fail( "Expected to be able to verify message but got " + e );
    }

    try
    {
      message = createSession().createTextMessage( "<a xorderid=\"x\"/>" );
      MessageVerifier.newXSDVerifier( url ).verifyMessage( message );
      fail( "Expected to not be able to verify message" );
    }
    catch( final Exception e )
    {
      assertEquals( "e.getMessage()",
                    "Message with ID = " + message.getJMSMessageID() +
                    " failed to match XSD loaded from " + url + ".",
                    e.getMessage() );
    }

    try
    {
      message = createSession().createTextMessage( "<a xorderid=\"x\"/>" );
      MessageVerifier.newSchemaBasedVerifier( XMLConstants.W3C_XML_SCHEMA_NS_URI, url ).verifyMessage( message );
      fail( "Expected to not be able to verify message" );
    }
    catch( final Exception e )
    {
      assertEquals( "e.getMessage()",
                    "Message with ID = " + message.getJMSMessageID() +
                    " failed to match Schema loaded from " + url + ".",
                    e.getMessage() );
    }
  }
}
