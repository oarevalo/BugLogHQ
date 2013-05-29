<?xml version="1.0" encoding="UTF-8"?>
<config>
	<setting name="general.adminEmail">info@oscararevalo.com</setting>
	<setting name="general.externalURL" />
	<setting name="general.dateFormat">mm/dd/yy</setting>
	<!-- all dates/times are based on the current server time,
		but you can use the following setting to display times
		on a different time zone. Keep in mind that this is a basic
		offset calculation and does not handle things like daylight savings
		time and such. Use the format: "UTC+/-{hour offset}". Ex UTC+8 -->
	<setting name="general.timezoneInfo"></setting>
	<setting name="db.dsn">bugLog</setting>
	<setting name="db.dbtype">mysql</setting>
	<setting name="db.username" />
	<setting name="db.password" />
	<setting name="service.serviceCFC">bugLog.components.bugLogListenerAsync</setting>
	<setting name="service.autoStart">true</setting>
	<setting name="service.requireAPIKey">false</setting>
	<setting name="service.APIKey">2CF20630-DD24-491F-BA44314842183AFC</setting>
	<setting name="service.maxQueueSize">1000</setting>
	<setting name="service.maxLogSize">20</setting>
	<setting name="service.schedulerIntervalSecs">120</setting>
	<setting name="jira.enabled">false</setting>
	<setting name="jira.wsdl" />
	<setting name="jira.username" />
	<setting name="jira.password" />
	<setting name="purging.numberOfDays">15</setting>
	<setting name="purging.enabled">true</setting>
	<setting name="digest.enabled">true</setting>
	<setting name="digest.recipients">oarevalo@gmail.com</setting>
	<setting name="digest.schedulerIntervalHours">24</setting>
	<setting name="digest.schedulerStartTime">06:00</setting>
	<setting name="digest.sendIfEmpty">false</setting>
	<setting name="digest.severity"></setting>
	<setting name="digest.application"></setting>
	<setting name="digest.host"></setting>
		
	<!-- setting any of the following autoCreate options to false,
		will disable the automatic creation of new records for
		applications/hosts/severities when processing bug reports.
		If undefined, BugLog will always autocreate.	
	 -->
	<setting name="autoCreate.application">true</setting>	
	<setting name="autoCreate.host">true</setting>	
	<setting name="autoCreate.severity">true</setting>	
		
	<!-- Environment-specific Settings: 
		
		You can override any of the above settings for specific environments. 
		
		The environment can be given in any of the following ways:
		
			1. Create a file named "serverkey.txt" on the same directory as this config file.
				This file should contain only a single word to use as the environment name (i.e. "dev", "production1", "test", etc)
			2. Create a servlet context parameter named "serverkey" with the value you want to use for your environment
				In Tomcat, this would be done by editing the file {TOMCAT_HOME}/conf/context.xml
				and adding a line like:
					 <Parameter name="serverkey" value="someNameHere" override="false" />
			3. Pass the environment name using the configKey argument to the init() method on config.cfc whenever is created
			4. Pass the path to a file containing the environment key to config.cfc
			
		NOTE: the first two methods are way more easier and portable since there are at least 3 places where the config.cfc object is created
			and you would need to update all three if you use method #3 or #4
		
		NOTE 2: If you are using methods #1 or #2, you can change the value of the filename or the context parameter
			by editing /bugLog/components/xmlConfigProvider.cfc, lines 6 and 9.
			
	<envSettings name="dev">
		<setting name="db.dsn">bugLog_dev</setting>
		<setting name="general.adminEmail">devteam@somedomain.org</setting>
	</envSettings>

	<envSettings name="qa">
		<setting name="db.dsn">bugLog_qa</setting>
		<setting name="general.adminEmail">qateam@somedomain.org</setting>
	</envSettings>

	-->

</config>
