package jamex.common;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Annotate a type or method as being an "entry point".
 *
 * Mainly used so that IDEA can identify dynamically accessed classes as
 * entry points and not mark them as unused.
 */
@Retention( RetentionPolicy.CLASS )
@Target( { ElementType.TYPE, ElementType.METHOD } )
public @interface EntryPoint
{
}
