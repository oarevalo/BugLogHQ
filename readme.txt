/**************************************************************/	
/* BugLogHQ  (v1.2 beta)										  */
/* http://buglogHQ.riaforge.org
/**************************************************************/	

/*
  Copyright 2007 - Oscar Arevalo (http://www.oscararevalo.com)

  Licensed under the Apache License, Version 2.0 (the "License"); 
  you may not use this file except in compliance with the License. 
  You may obtain a copy of the License at 

	http://www.apache.org/licenses/LICENSE-2.0 

  Unless required by applicable law or agreed to in writing, software 
  distributed under the License is distributed on an "AS IS" BASIS, 
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
  See the License for the specific language governing permissions and 
  limitations under the License. 

*/ 

About BugLogHQ
-----------------------------------------------------------------------
BugLogHQ is a tool to centralize the handling of automated bug reports from 
multiple applications. BugLogHQ provides a unified view of error messages
sent from any number of applications, allowing the developer to search,
graph, forward, and explore the bug reports submitted by the applications. 
All bug reports received by BugLogHQ are stored on a normalized database, thus 
providing the option to the developers to further extend the application
to leverage this information.


New in 1.2
-----------------------------------------------------------------------
* Support for a configurable and extensible rules system. Rules are processes that are applied
to each bug report as it is received. Rules can be defined for tasks such as sending notifications
when a bug of given conditions is received; when the amount of bugs received in 
a given timeframe is greater than a defined threshold, etc. The rules system is
extensible in the sense that each rule is implemented as a CFC with a common interface.
For more info on rules see:
http://www.oscararevalo.com/index.cfm/2007/10/2/BugLogHQ-New-Rules-feature



Integrating BugLogHQ into your Applications
-----------------------------------------------------------------------
Applications can send bug reports to BugLogHQ via three different ways:
* webservice call
* http post
* direct CFC call

BugLogHQ provides a CFC that can be used to send the bug reports. This CFC is 
located in /bugLog/client/bugLogService.cfc. This is the only file that needs
to be distributed with any application that wants to submit reports to BugLogHQ.

You may instantiate and keep the instance of this CFC in some a scope
such as Application and then just call the "notifyService" method in it whenever
the application needs to submit a bug report.

To initialize the bugLogService, call the Init method. This method takes three
parameters:
* bugLogListener:	The location of the listener where to send the bug reports
* bugEmailRecipients:  A comma-delimited list of email addresses to which send the 
						bug reports in case there is an error submitting the report
						to the bugLog listener.
* bugEmailSender:	The sender address to use when sending the emails mentioned above.

The bugLogListener parameter can be any of:
* WSDL pointing to /bugLog/listeners/bugLogListenerWS.cfc (to submit the report using a webservice), 
* Full URL pointing to /bugLog/listeners/bugLogListenerREST.cfm (to submit as an http post)
* path to /bugLog/listeners/bugLogListenerWS.cfc in dot notation (i.e. bugLog.listeners.bugLogListenerWS)

If an error occurs while submitting the report to the listener, then bugLogService will automatically
send the same information as an email to the addresses provided in the Init() method.



BugLogHQ Interface
-----------------------------------------------------------------------
To access the BugLogHQ interface, go to /bugLog/ on your bugLog server; the interface is
password protected. The default username and password is: admin / admin.
From here you can have an overview of every bug report that has been received. Everything
is pretty self-explanatory, and there are lots of things you can click to visualize the
data in different ways.



Installation and Usage Notes:
--------------------------------------------------------------------------------------
* To install BugLog just unpack the zip file into the root of your webserver. BugLogHQ assumes it will be
installed on a directory or mapping named /bugLog.

* Run the corresponding SQL script for your database. The script can be found in the /install directory. This 
will create the necessary tables.

* By default bugLogHQ uses a datasource named "bugLog" with no password, to change this go to:
		/bugLog/components/db/DAOFactory.cfc (lines 3-5)

* To access the bugLogHQ interface, go to /bugLog. The default username/password is:
		username: admin
		password: admin
	IMPORTANT: To change the admin password, you must edit the bl_Users table directly.

* You may also want to setup proper email addresses for sending bug reports when things do not work as they should: 
		/bugLog/hq/Application.cfc (lines 13-14)
		/bugLog/hq/config/config.xml (lines 5-6)


Supported Databases:
--------------------------------------------------------------------------------------
Currently BugLogHQ supports the following databases:
* MySQL
* Microsoft SQL Server 2000
* Microsoft SQL Server 2005
* Microsoft Access


Acknowledgements / Thanks / Credits
---------------------------------------------------------------------------
* BugLogHQ uses rss.cfc by Raymond Camden (http://cfrss.riaforge.org/)
* Lots of icons from the "Silk" icon set by Mark James (http://www.famfamfam.com/)
* Thanks to Tom DeManincor for creating the SQL script for MSSQL
* Thanks to Chuck Weidler for updating and providing the SQL scripts for Access, MS SQL Server 2000, MSSQL Server 2005

Bugs, suggestions, criticisms, well-wishes, good vibrations, etc
---------------------------------------------------------------------------
Please send to oarevalo@gmail.com or share them on the forum at http://bugloghq.riaforge.org/







