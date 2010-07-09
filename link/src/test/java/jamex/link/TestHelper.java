package jamex.link;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;

final class TestHelper
{
  static URL createURLForContent( final Class<?> type, final String content, final String suffix )
    throws IOException
  {
    final File file = File.createTempFile( type.getName() + "Test-", "." + suffix );
    final FileOutputStream output = new FileOutputStream( file );
    output.write( content.getBytes( "UTF-8" ) );
    output.close();
    return file.toURI().toURL();
  }
}
