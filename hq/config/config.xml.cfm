<?xml version="1.0" encoding="ISO-8859-1"?>
<config>
	<settings>
		<!-- Application Title -->
		<setting name="applicationTitle" value="BugLogHQ"/>
		<setting name="versionTag" value="1.4.65" />
		
		<!-- These two settings are used for reporting internal
			errors of the HQ application -->
		<setting name="bugEmailRecipients" value="" />
		<setting name="bugEmailSender" value="" />
		
		<!-- This is the directory/mapping where the application is located -->
		<setting name="bugLogPath" value="/bugLog/" />
		
		<!-- This flag controls wether detailed error information is displayed
			in case the application encounters an unhandled exception -->
		<setting name="debugMode" value="true" />

		<!-- main config -->
		<setting name="configProviderType" value="xml" />
		<setting name="configPath" value="/bugLog/config/buglog-config.xml.cfm" />
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
		<service name="bugTracker" class="bugLog.hq.components.services.bugTrackerService">
			<init-param name="bugEmailSender" settingName="bugEmailSender" />
			<init-param name="bugEmailRecipients" settingName="bugEmailRecipients" />
		</service>

		<!-- JIRA service -->
		<service name="jira" class="bugLog.hq.components.services.jiraService">
			<init-param name="config" serviceName="config" />
		</service>
	</services>
</config>
