BugLogHQ (v1.8)
===============
https://github.com/oarevalo/BugLogHQ

**BugLogHQ** is a tool to centralize the handling of automated bug reports from multiple applications. BugLogHQ provides a unified view of error messages sent from any number of applications, allowing the developer to search, graph, forward, and explore the bug reports submitted by the applications.


> Copyright 2009-2013 - Oscar Arevalo (http://www.oscararevalo.com)
>
> Licensed under the Apache License, Version 2.0 (the "License"); 
> you may not use this file except in compliance with the License. 
> You may obtain a copy of the License at 
>
> http://www.apache.org/licenses/LICENSE-2.0 
>
> Unless required by applicable law or agreed to in writing, software 
> distributed under the License is distributed on an "AS IS" BASIS, 
> WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
> See the License for the specific language governing permissions and 
> limitations under the License. 


Contents:
-----------------------------------------------------------------------
1. About BugLogHQ
2. Release Notes
3. Integrating BugLogHQ into your Applications
4. BugLogHQ Interface
5. Installation and Usage Notes:
6. Supported Databases
7. Acknowledgements / Thanks / Credits
8. Bugs, suggestions
9. Using BugLog with Non ColdFusion Applications



1. About BugLogHQ
-----------------------------------------------------------------------
BugLogHQ is a tool to centralize the handling of automated bug reports from multiple applications. BugLogHQ provides a unified view of error messages sent from any number of applications, allowing the developer to search,
graph, forward, and explore the bug reports submitted by the applications. All bug reports received by BugLogHQ are stored on a normalized database, thus providing the option to the developers to further extend the application to leverage this information.



2. Release Notes
-----------------------------------------------------------------------

### New in 1.8 (4/2012)
* Users can now be restricted to access only specific applications assigned by the Administrator. Restricted users will only be able to see bug reports for their assigned applications and create rules for those applications.
* CRUD screens to manage Severities, Hosts and Applications. These are accessed through the Settings page and are only accessible to users in Admin role.
* The REST listener can now receive data in the body of the HTTP request encoded as a JSON object
* Checkpoint Tracking. The CFM client now has a checkpoint() method that you can use to track checkpoints or milestones during the page execution. If a bug is sent, then those checkpoints will be displayed on the full bug report.
* Remote Listener. This is a different listener type that allows the BugLog webapp and the Listener endpoint to be on separate servers, while at the same time allowing the webapp to control the listener.
* Individual users can now be assigned their own API keys to submit bug reports
* Added option to toggle on/off the automatic creation of hosts/severities/applications when a new bug report is received.
* Rules changes are now applied immediately without the need to restart the listener service.
* CFM applications using the buglog client can now set the application name explicitly, max depth for cfdumps and toggle logging messages locally.
* Added a basic ANT build script for generating a ZIP file suitable for deployment.

### New in 1.7 (9/2012)
* A new "Dashboard" homepage.
* More granular and finer timespans to view received errors. 
* A log of each time an alert is fired with information on the bug report that triggered the alert.
* Optional HTTP Basic authentication for access to RSS feeds.
* Expose the results of any search criteria as an RSS feed.
* A new client written in JavaScript to allow client-side webapps to report errors to a BugLog server.
* Centralized and standardized display of dates and times, including support for time zone conversion.
* Display additional insights and context for each bug report (timeline, other reports from same user agent, host distribution)
* Allow deletion of bug reports
* Improved listing of current rules to provide a human-readable description of what they actually do.
* Use jQuery and Twitter Bootstrap for the main user interface.


### New in 1.6 (7/2012)
* Support for "Named Instance" deployment. A Named Instance means that you can have multiple instances of BugLog running on the same server at the same time. Each instance have their own configuration and point to their own databases.
* BugLog can now (optionally) run out-of-the-box on any directory (even the webroot).
* Added support for PostgreSQL (contributed by Morgan Dennithorne)

### New in 1.5 (2/2011)
* Extensions are now stored on a database instead of an XML file
* Creating a rule instance is now much more user friendly because application, host and severity codes can be selected via dropdowns; or can also be prepopulated from an existing bug report.
* Added support for defining settings for multiple environments (dev,qa,prod1,prod2,etc). Once the environment is detected buglog can override any setting with custom values.
* Added option to disable editing settings through the UI (useful if you have your config file versioned and only want to configure buglog that way)
* Added the "BugLog Digest" which is a configurable and periodic email summary of all reports received in the last X hours.
* Rewrote the "iphone" UI to be for mobiles in general (now its accessible at /bugLog/mobile), also there is an improved platform detection when going to /bugLog. If you go with any mobile browser you should get redirected to the new UI, otherwise you go to the regular desktop UI
* Multiple bug fixes 

### New in 1.4 (11/2009)
* Bug reports and rules are now processed asynchronously and not at the time they arrive. This largely increases the response and scalability of the system. The default interval for execution is 2 minutes but this can be configured easily.
* Reduced the number of configuration files (only 2) and moved them to a single location.
* Added a "settings" screen to the main interface to allow administrators to configure multiple aspects of BugLogHQ as well as perform user management.
* Added support for integrating with JIRA. When enabled allows sending issues directly from BugLog to a JIRA instance.
* Added support for multiple users in two roles: administrators and regular users. 
* Added option to change user password.
* Added option to require an API key that each application must send in order to submit bug reports.
* Added option to disable rules without having to delete them.
* Added more rule types and extended configuration options for existing types.
* Added option to purge history so that old data can be deleted
* Multiple bug fixes.
* Deprecated support for storing data in XML files (it really really didn't make any sense)
* UPDATE: Added custom web interface for iPhone/iPod Touch. See /bugLog/iphone

### New in 1.3
* This is a release of mostly internal changes. The entire data access layer has been refactored to use an improved mechanism that makes it easier to work with different backend data storages.
See: 
http://www.oscararevalo.com/index.cfm/2007/11/28/Using-Polymorphism-and-Inheritance-to-Build-a-Switchable-Data-Access-Layer
* The BugLogHQ application (where you go to see the bug reports) has also been updated to improve performance and use the new DAO layer.
* Configuration of data storage is now done via a config xml on the /buglog/config directory.The file is dao-config.xml.cfm. Here is where you can set the DSN, user, password and dbtype. From here, you can also change the storage mechanism from a database to simple XML files (maybe for a quick test drive)
* Fixed bug that would throw errors if the email addresses for top-level error reporting were not defined.
* Added a directory /bugLog/tests that contains files to test both the client and server side of buglog, and also can be used as a refence as to how to implement the client side of bugLog.
* BugLogListener now uses memory caching to improve performance and process bug reports faster
* Fixed sql scripts for MSSQL, all tables should now be configured with primary keys defined as numeric identity values
* bl_source table no longer needs to be populated with pre-defined values. The listener will insert these as needed.
* Added bugLogProxy.cfm for integration with BugLogMini ( http://buglogmini.riaforge.org/ )

### New in 1.2
* Support for a configurable and extensible rules system. Rules are processes that are applied to each bug report as it is received. Rules can be defined for tasks such as sending notifications when a bug of given conditions is received; when the amount of bugs received in a given timeframe is greater than a defined threshold, etc. The rules system is extensible in the sense that each rule is implemented as a CFC with a common interface.
For more info on rules see:
http://www.oscararevalo.com/index.cfm/2007/10/2/BugLogHQ-New-Rules-feature



3. Integrating BugLogHQ into your Applications
-----------------------------------------------------------------------
Applications can send bug reports to BugLogHQ via three different ways:
* webservice call
* http post
* direct CFC call

BugLogHQ provides a CFC that can be used to send the bug reports. This CFC is located in `/bugLog/client/bugLogService.cfc`. This is the only file that needs to be distributed with any application that wants to submit reports to BugLogHQ. The client cfc requires at least a CFML engine compatible with Adobe ColdFusion 8.

You may instantiate and keep the instance of this CFC in some a scope such as Application and then just call the `notifyService()` method in it whenever the application needs to submit a bug report.

To initialize the bugLogService, call the Init method. This method takes three parameters:
* _bugLogListener:_	The location of the listener where to send the bug reports
* _bugEmailRecipients:_  A comma-delimited list of email addresses to which send the bug reports in case there is an error submitting the report to the bugLog listener.
* _bugEmailSender:_	The sender address to use when sending the emails mentioned above.

The bugLogListener parameter can be any of:
* WSDL pointing to `/bugLog/listeners/bugLogListenerWS.cfc` (to submit the report using a webservice), 
* Full URL pointing to `/bugLog/listeners/bugLogListenerREST.cfm` (to submit as an http post)
* path to `/bugLog/listeners/bugLogListenerWS.cfc` in dot notation (i.e. bugLog.listeners.bugLogListenerWS)

If an error occurs while submitting the report to the listener, then bugLogService will automatically send the same information as an email to the addresses provided in the `init()` method.

**TIP:** Check the file `/bugLog/test/client.cfm` for an example of how to use the bugLog client CFC



4. BugLogHQ Interface
-----------------------------------------------------------------------
To access the BugLogHQ interface, go to `/bugLog/` on your bugLog server; the interface is password protected. The default username and password is: admin / admin. From here you can have an overview of every bug report that has been received. Everything is pretty self-explanatory, and there are lots of things you can click to visualize the data in different ways.



5. Installation and Usage Notes:
--------------------------------------------------------------------------------------
* To install BugLog just unpack the zip file into the root of your webserver. BugLogHQ assumes it will be installed on a directory named /bugLog. If you want, you can also put BugLog directly on the web root or any other directory.

**NOTE:** If you want to install bugLog on a location other than the default (/bugLog/), you will need to update the setting `general.externalURL` with the path to where you installed BugLog. The path must always end with a "/". Examples: "/", "/mybuglog/", "/bugtrackingthingy/", etc.

**NOTE:** The BugLogHQ webapp requires a CFML engine compatible with at least Adobe ColdFusion 9; however it can receive bug reports from any version of CFML engines (or pretty much anything that can make an HTTP post)

* Run the corresponding SQL script for your database. The script can be found in the `/install` directory. This will create the necessary tables.

* By default bugLogHQ uses a datasource named "bugLog" with no password, to change this go to: 

	/bugLog/config/buglog-config.xml.cfm

Change the `<setting />` tags for:

	db.dsn:	datasource name as defined in the CF administrator (by default is bugLog)
	db.dbtype: database type. Can be mysql, mssql (for Microsot SQL Server), pgsql (for PostgreSQL) or oracle. The default is mysql
	db.username: username for the datasource (if needed)
	db.password: password for the datasource (if needed)
	
* To access the bugLogHQ interface, go to /bugLog. The default username/password is:
	
	username: admin
	password: admin
	
**IMPORTANT:** To change the admin password or to create additional users click on the "Settings" link on the upper right corner of the screen.

**TIP:** Changing the setting `general.externalURL` in the main config you can tell BugLog the URL to use when referring to itself. By default buglog will try to guess it from the CGI scope, but in some cases you may want to override this. For example if you have a clustered deployment. This value can be either a relative path starting with "/", or a full URL (i.e. "http://www.someserver.com/bugLog/")

### TESTING AND VERIFICATION:
After installation use your browser to go to `/bugLog/test` and follow the links to test both the client and server side of buglog.

### CONFIGURING MULTIPLE ENVIRONMENTS
You can override any setting on the main config on a per-environment basis. To determine which is the current environment, BugLog will look for a file named `severkey.txt` on your `/bugLog/config` directory. This file should only contain a single word that is used to name the environment. For example: "dev" or "prod-server-1" or something like that.
	
Then on your buglog-config.xml.cfm add an `<envSettings />` section like the following example:

	<envSettings name="dev">
	  <setting name="db.dsn">bugLog_dev</setting>
	  <setting name="general.adminEmail">devteam@somedomain.org</setting>
	</envSettings>

Where the "name" attribute of the envSettings tag must match what you provide on your serverkey.txt file. Inside you can place any number of `<settings/>` tags you want. These will override the settings of the same name defined on the general part of the config.
	
You can have as many `<envSettings/>` sections as you want. However only one will be used (the one that matches your serverkey.txt).

If none matches the serverkey, then BugLog will use the default settings.	
	
An alternative way of providing the "serverkey" value is by using a Context Parameter. The advantage is that this method does not require you to add any new files to your BugLog installation. Of course, this only works if you have access to the config files of your application server.
	
For example in Tomcat, to set your serverkey as "dev", you would set a context parameter by editing `"{Tomcat Path}/conf/context.xml"` like this:
	
	<Context>
	  ...
	  <Parameter name="serverkey" value="dev" override="false" />
	  ...
	</Context>

### INSTALLING A NAMED INSTANCE
To create a new instance, just create a new directory under the webroot with the name you want for your neq instance (i.e. "/buglogdev").

On the new directory copy the contents of /bugLog/install/named-instance-template.

**NOTE:** don't copy the directory itself, only its contents.

Change the new Application.cfc to properly name your application, and modify the `config/buglog-config.xml.cfm` on your new instance to set its appropriate configuration (datasource, etc).

After that you can just go to /buglogdev (in this case) to access your new instance. 

To submit bugs to this instance, just point your buglog client to /buglogdev/listener.cfm
	


6. Supported Databases:
--------------------------------------------------------------------------------------
Currently BugLogHQ supports the following databases:
* MySQL
* Microsoft SQL Server 2000
* Microsoft SQL Server 2005
* Microsoft Access
* PostgreSQL
* Oracle

**IMPORTANT:** Make sure you enable CLOB/BLOB support on the CF datasource settings in the ColdFusion Administrator, otherwise your bug reports might get truncated.


7. Acknowledgements / Thanks / Credits
---------------------------------------------------------------------------
* BugLogHQ uses rss.cfc by Raymond Camden (http://cfrss.riaforge.org/)
* Lots of icons from the "Silk" icon set by Mark James (http://www.famfamfam.com/)
* Thanks to Tom DeManincor for creating the SQL script for MSSQL
* Thanks to Chuck Weidler for updating and providing the SQL scripts for Access, MS SQL Server 2000, MSSQL Server 2005
* Thanks to WST crew at Mentor Graphics for the great suggestions and ideas to improve BugLog
* Thanks to Morgan Dennithorne (https://github.com/morgdenn) for adding support for PostgreSQL
* Thanks to Brian Swartzfager (https://github.com/bcswartz) for adding support for Oracle
* Thanks to everyone that contributes code and patches to the project!


8. Bugs, suggestions, criticisms, well-wishes, good vibrations, etc
---------------------------------------------------------------------------
There is now a Google Groups for the BugLogHQ project. Use them to ask any questions, ask for help if you get stuck, or if you have any contributions that you would like to share.

* _Google Groups Page:_  http://groups.google.com/group/bugloghq
* _GitHub Project Page:_ https://github.com/oarevalo/BugLogHQ


9. Using BugLog with Non ColdFusion Applications
---------------------------------------------------------------------------
Since BugLog listens for bug reports through standard protocols via HTTP (REST and SOAP), you can use it to aggregate bug reports from any application, not just ones made in CFML. An application just needs to point to the right listener endpoint and pass the necessary parameters.

On the /client folder you can find basic versions of PHP, Python and JavaScript clients that can be used to have an easier integration between your applications and BugLog. Please note that this scripts are on an "experimental" state, so they are a bit more simpler than the CFML version. They also use only the REST listener, not the SOAP one.





