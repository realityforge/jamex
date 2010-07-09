package jamex.link;

import java.util.regex.Pattern;
import org.junit.Test;
import static org.junit.Assert.*;

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
      fail( "Expected to be able to verify message" );
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
}
