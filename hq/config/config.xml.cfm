<?xml version="1.0" encoding="ISO-8859-1"?>
<config>
	<settings>
		<!-- Application Title -->
		<setting name="applicationTitle" value="BugLogHQ"/>
		<setting name="versionTag" value="1.4.60" />
		
		<!-- These two settings are used for reporting internal
			errors of the HQ application -->
		<setting name="bugEmailRecipients" value="" />
		<setting name="bugEmailSender" value="" />
		
		<!-- This is the directory/mapping where the application is located -->
		<setting name="bugLogPath" value="/bugLog/" />
		
		<!-- This email address is used as the sender when sending
			copies of received bug reports via email. This setting
			needs to be set with an email address in order for the
			emailing feature to work -->
		<setting name="contactEmail" value="" />

		<!-- This flag controls wether detailed error information is displayed
			in case the application encounters an unhandled exception -->
		<setting name="debugMode" value="true" />

		<!-- JIRA integration settings -->
		<setting name="jiraEnabled" value="false" />
		<setting name="jiraWsdl" value="" />
		<setting name="jiraUsername" value="" />
		<setting name="jiraPassword" value="" />
	</settings>

		
	<!-- This section describes all services that will be loaded into the application -->
	<services>
		<!-- Application service (service layer) -->
		<service name="app" class="bugLog.hq.components.services.appService">
			<init-param name="path" settingName="bugLogPath" />
		</service>
	
		<!-- error reporting service -->
		<service name="bugTracker" class="bugLog.hq.components.services.bugTrackerService">
			<init-param name="bugEmailSender" settingName="bugEmailSender" />
			<init-param name="bugEmailRecipients" settingName="bugEmailRecipients" />
		</service>

		<!-- JIRA service -->
		<service name="jira" class="bugLog.components.jiraService">
			<init-param name="wsdl" settingName="jiraWsdl" />
			<init-param name="username" settingName="jiraUsername" />
			<init-param name="password" settingName="jiraPassword" />
		</service>
		
	</services>
</config>
