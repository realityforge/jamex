package jamex.link;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.runner.RunWith;
import org.junit.runners.Suite;

@RunWith( Suite.class )
@Suite.SuiteClasses
  (
    {
      MessageTransformerTestCase.class,
      MessageVerifierTestCase.class,
      MessageLinkTestCase.class
    }
  )
public class LinkSuite
{
  /** this ensures that there is one broker for the full suite */
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
}
