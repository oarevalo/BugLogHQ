<?xml version="1.0" encoding="ISO-8859-1"?>
<config>
	<settings>
		<!-- Application Title -->
		<setting name="applicationTitle" value="BugLogHQ"/>
		<setting name="versionTag" value="1.8.7" />
		
		<!-- These two settings are used for reporting internal
			errors of the HQ application -->
		<setting name="bugEmailRecipients" value="" />
		<setting name="bugEmailSender" value="" />
		<setting name="bugLogListener" value="bugLog.listeners.bugLogListenerWS" />
				
		<!-- This flag controls wether detailed error information is displayed
			in case the application encounters an unhandled exception -->
		<setting name="debugMode" value="true" />

		<!-- This is used to enable/disable editing of settings via the UI,
			of disabled all settings change must be done directly on the config file.
			This can also be a comma-delimited list of config keys (environments)
			in which editing is allowed -->
		<setting name="allowConfigEditing" value="true" />
	</settings>

		
	<!-- This section describes all services that will be loaded into the application -->
	<services>
		<!-- Application service (service layer) -->
		<service name="app" class="bugLog.components.hq.appService">
		</service>
	
		<!-- error reporting service -->
		<service name="bugTracker" class="bugLog.client.bugLogService">
			<init-param name="bugLogListener" settingName="bugLogListener" />
			<init-param name="bugEmailSender" settingName="bugEmailSender" />
			<init-param name="bugEmailRecipients" settingName="bugEmailRecipients" />
		</service>

		<!-- JIRA service -->
		<service name="jira" class="bugLog.components.hq.jiraService">
			<init-param name="appService" serviceName="app" />
		</service>

		<!-- RSS service -->
		<service name="rss" class="bugLog.components.lib.rss">
		</service>
	</services>
</config>

