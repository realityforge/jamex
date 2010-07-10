package jamex.link;

import javax.jms.Connection;
import javax.jms.Session;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;

public class AbstractBrokerBasedTestCase
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

  protected final Session getSession()
  {
    return m_session;
  }
}