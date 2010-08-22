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
* Consider using EasyEJB or some other EJB server to host biz logic
