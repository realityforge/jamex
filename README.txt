Install Notes
-------------

Need to do following after have run pax-provision

mvn install:install-file -DgroupId=org.eclipse -DartifactId=osgi -Dversion=3.5.1.R35x_v20090827 -Dpackaging=jar -Dfile=runner/bundles/org.eclipse.osgi_3.5.1.R35x_v20090827.jar


TODO
----

* SubscribingServiceListener
  - add DMQ property that if specified will send an excepting message to DMQ
  - add properties that define the type of session; transacted or not, ack mode
* Add integration test for SubscribingServiceListener to see if messages are delivered using Pax-Exam
* Install Pax-Logging
* Add/use configuration service 
