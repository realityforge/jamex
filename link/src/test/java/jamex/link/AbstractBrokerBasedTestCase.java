package jamex.link;

import java.util.LinkedList;
import javax.jms.Connection;
import javax.jms.Session;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;

public class AbstractBrokerBasedTestCase
{
  private Connection m_connection;
  private final LinkedList<Session> m_sessions = new LinkedList<Session>();

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
  public void initConnection()
    throws Exception
  {
    m_connection = TestHelper.createConnection();
    m_connection.start();
  }

  @After
  public void shutdownConnection()
    throws Exception
  {
    for( final Session session : m_sessions )
    {
      session.close();
    }
    m_sessions.clear();
    if( null != m_connection )
    {
      m_connection.stop();
      m_connection.close();
      m_connection = null;
    }
  }

  final Session createSession()
    throws Exception
  {
    return createSession( false, Session.AUTO_ACKNOWLEDGE );
  }

  final Session createSession( final boolean transacted, final int acknowledgeMode )
    throws Exception
  {
    final Session session = getConnection().createSession( transacted, acknowledgeMode );
    m_sessions.add( session );
    return session;
  }

  final Connection getConnection()
  {
    if( null == m_connection )
    {
      throw new IllegalStateException( "null == m_connection" );
    }
    return m_connection;
  }
}