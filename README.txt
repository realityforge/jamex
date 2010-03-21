Note that jamex is currently a test project used to evaluate OSGI use in
different contexts. The initial intention had been to setup a real production
JMS router and this may return in time.

TODO
----

* SubscribingServiceListener
  - add DMQ property that if specified will send an excepting message to DMQ
  - add properties that define the type of session; transacted or not, ack mode
* Add integration test for SubscribingServiceListener to see if messages are delivered using Pax-Exam
* Add/use configuration service
* Make use of Declarative Services for everything
* Consider using EasyEJB or some other EJB server to host biz logic

Buildr Modifications:
* zip task
  - [zip.directory "foo"] creates an empty dir named "foo" in zip
* idea extension
  - attempt to guess the scm system
  - disable module creation for certain projects (i.e. wrapped jars)
* buildr-osgi-runtime
  - Make it so that it creates either a dir or zip based on layout directives
  - Possibly enhance so it can deploy equinox
  - make it semi autogenerate config files?? (order of module loading)
