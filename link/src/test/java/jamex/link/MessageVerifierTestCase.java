package jamex.link;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;
import java.util.regex.Pattern;
import static org.junit.Assert.*;
import org.junit.Test;

public class MessageVerifierTestCase
{
  @Test
  public void regexVerifier()
    throws Exception
  {
    final TestTextMessage message = new TestTextMessage( "1", "myMessage" );
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
      assertEquals( "e.getMessage()", "Message with ID = 1 failed to match pattern \"Not.*Message\".", e.getMessage() );
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

    final URL url = createURLForContent( xsd, "xsd" );
    try
    {
      final TestTextMessage message = new TestTextMessage( "1", "<a orderid=\"x\"/>" );
      MessageVerifier.newXSDVerifier( url ).verifyMessage( message );
    }
    catch( final Exception e )
    {
      e.printStackTrace();
      fail( "Expected to be able to verify message but got " + e );
    }

    try
    {
      final TestTextMessage message = new TestTextMessage( "1", "<a xorderid=\"x\"/>" );
      MessageVerifier.newXSDVerifier( url ).verifyMessage( message );
      fail( "Expected to not be able to verify message" );
    }
    catch( final Exception e )
    {
      assertEquals( "e.getMessage()",
                    "Message with ID = 1 failed to match XSD loaded from " + url + ".",
                    e.getMessage() );
    }
  }

  private URL createURLForContent( final String content, final String suffix )
    throws IOException
  {
    final File file = File.createTempFile( MessageVerifier.class.getName() + "Test-", "." + suffix );
    final FileOutputStream output = new FileOutputStream( file );
    output.write( content.getBytes( "UTF-8" ) );
    output.close();
    return file.toURI().toURL();
  }
}
