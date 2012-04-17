<?xml version="1.0" encoding="ISO-8859-1"?>
<config>
	<settings>
		<!-- Application Title -->
		<setting name="applicationTitle" value="BugLogHQ"/>
		<setting name="versionTag" value="1.5.195" />
		
		<!-- These two settings are used for reporting internal
			errors of the HQ application -->
		<setting name="bugEmailRecipients" value="" />
		<setting name="bugEmailSender" value="" />
		<setting name="bugLogListener" value="bugLog.listeners.bugLogListenerWS" />
		
		<!-- This is the directory/mapping where the application is located -->
		<setting name="bugLogPath" value="/bugLog/" />
		
		<!-- This flag controls wether detailed error information is displayed
			in case the application encounters an unhandled exception -->
		<setting name="debugMode" value="true" />

		<!-- main config -->
		<setting name="configProviderType" value="xml" />
		<setting name="configPath" value="/bugLog/config/buglog-config.xml.cfm" />
		
		<!-- This is used to enable/disable editing of settings via the UI,
			of disabled all settings change must be done directly on the config file.
			This can also be a comma-delimited list of config keys (environments)
			in which editing is allowed -->
		<setting name="allowConfigEditing" value="true" />
	</settings>

		
	<!-- This section describes all services that will be loaded into the application -->
	<services>
		<!-- General config settings -->
		<service name="config" class="bugLog.components.config">
			<init-param name="configProviderType" settingName="configProviderType" />
			<init-param name="configDoc" settingName="configPath" />
		</service>

		<!-- Application service (service layer) -->
		<service name="app" class="bugLog.hq.components.services.appService">
			<init-param name="path" settingName="bugLogPath" />
			<init-param name="config" serviceName="config" />
		</service>
	
		<!-- error reporting service -->
		<service name="bugTracker" class="bugLog.client.bugLogService">
			<init-param name="bugLogListener" settingName="bugLogListener" />
			<init-param name="bugEmailSender" settingName="bugEmailSender" />
			<init-param name="bugEmailRecipients" settingName="bugEmailRecipients" />
		</service>

		<!-- JIRA service -->
		<service name="jira" class="bugLog.hq.components.services.jiraService">
			<init-param name="config" serviceName="config" />
		</service>
	</services>
</config>
