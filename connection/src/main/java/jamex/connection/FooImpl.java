package jamex.connection;

import org.apache.felix.ipojo.annotations.Component;
import org.apache.felix.ipojo.annotations.Instantiate;
import org.apache.felix.ipojo.annotations.PostRegistration;
import org.apache.felix.ipojo.annotations.PostUnregistration;
import org.apache.felix.ipojo.annotations.Provides;
import org.apache.felix.ipojo.annotations.Requires;
import org.apache.felix.ipojo.annotations.Validate;

@Component(immediate = true)
@Provides( specifications = {Foo.class})
@Instantiate(name = "X")
public class FooImpl
  implements Foo
{
  @Requires
  javax.management.DynamicMBean m_mythingie;

  public FooImpl()
  {
    System.out.println( "FooImpl.FooImpl" );
  }

  @PostUnregistration
  public void postUnregister()
  {
    System.out.println( "FooImpl.postUnregister " + m_mythingie );
  }

  @PostRegistration
  public void postRegister()
  {
    System.out.println( "FooImpl.postRegister " + m_mythingie );
  }

  @Validate
  public void validate()
  {
    System.out.println( "FooImpl.validate " + m_mythingie );
  }
}
