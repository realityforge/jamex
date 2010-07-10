package jamex.link;

import java.net.URL;
import javax.jms.Connection;
import javax.jms.Message;
import javax.jms.Session;
import javax.jms.TextMessage;
import org.junit.AfterClass;
import static org.junit.Assert.*;
import org.junit.BeforeClass;
import org.junit.Test;

public class MessageTransformerTestCase
{
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

  @Test
  public void xsltTransformer()
    throws Exception
  {
    // Create the connection.
    final Connection connection = TestHelper.createConnection();
    connection.start();

    // Create the session
    final Session session = connection.createSession( false, Session.AUTO_ACKNOWLEDGE );

    final String xsl = "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n" +
                       "<xsl:stylesheet version=\"1.0\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\">\n" +
                       "<xsl:output method=\"xml\" indent=\"no\" omit-xml-declaration=\"yes\" standalone=\"no\"/>\n" +
                       "<xsl:template match=\"document\">\n" +
                       "  <ace><xsl:value-of select=\"title\"/></ace>\n" +
                       "</xsl:template>\n" +
                       "</xsl:stylesheet>\n";

    final URL url = TestHelper.createURLForContent( MessageTransformerTestCase.class, xsl, "xsl" );
    Message result = null;
    try
    {
      final TextMessage message = session.createTextMessage( "<document><title>X</title></document>" );
      result = MessageTransformer.newXSLTransformer( url ).transformMessage( session, message );
    }
    catch( final Exception e )
    {
      e.printStackTrace();
      fail( "Expected to be able to verify message but got " + e );
    }
    assertEquals( "result.getText()",
                  "<ace>X</ace>",
                  ( (TextMessage)result ).getText() );

    session.close();
    connection.stop();
  }
}