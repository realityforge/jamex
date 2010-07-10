package jamex.link;

import java.net.URL;
import java.util.regex.Pattern;
import javax.jms.Connection;
import javax.jms.Session;
import javax.jms.TextMessage;
import javax.xml.XMLConstants;
import org.junit.After;
import org.junit.AfterClass;
import static org.junit.Assert.*;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class MessageVerifierTestCase
{
  private Connection m_connection;
  private Session m_session;

  @BeforeClass
  public static void startupBroker()
    throws Exception
  {
    TestHelper.startupBroker();
  }

  @AfterClass
  public static void shutdownBroker()
    throws Exception
  {
    TestHelper.shutdownBroker();
  }

  @Before
  public void initSesion()
    throws Exception
  {
    // Create the connection.
    m_connection = TestHelper.createConnection();
    m_connection.start();

    // Create the session
    m_session = m_connection.createSession( false, Session.AUTO_ACKNOWLEDGE );
  }

  @After
  public void shutdownSesion()
    throws Exception
  {
    if( null != m_session )
    {
      m_session.close();
      m_session = null;
    }
    if( null != m_connection )
    {
      m_connection.stop();
      m_connection = null;
    }
  }

  @Test
  public void regexVerifier()
    throws Exception
  {
    final TextMessage message = m_session.createTextMessage( "myMessage" );
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
      message = m_session.createTextMessage( "<a orderid=\"x\"/>" );
      MessageVerifier.newXSDVerifier( url ).verifyMessage( message );
    }
    catch( final Exception e )
    {
      e.printStackTrace();
      fail( "Expected to be able to verify message but got " + e );
    }

    try
    {
      message = m_session.createTextMessage( "<a orderid=\"x\"/>" );
      MessageVerifier.newSchemaBasedVerifier( XMLConstants.W3C_XML_SCHEMA_NS_URI, url ).verifyMessage( message );
    }
    catch( final Exception e )
    {
      e.printStackTrace();
      fail( "Expected to be able to verify message but got " + e );
    }

    try
    {
      message = m_session.createTextMessage( "<a xorderid=\"x\"/>" );
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
      message = m_session.createTextMessage( "<a xorderid=\"x\"/>" );
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
