<?xml version="1.0" encoding="ISO-8859-1"?>
<config>
	<settings>
		<setting name="applicationTitle" value="BugLogHQ"/>
		<setting name="bugEmailRecipients" value="" />
		<setting name="bugEmailSender" value="" />
		<setting name="bugLogPath" value="/bugLog/" />
	</settings>

		
	<!-- This section describes all services that will be loaded into the application -->
	<services>
		<!-- Application service (service layer) -->
		<service name="app" class="components/services/appService.cfc">
			<init-param name="path" settingName="bugLogPath" />
		</service>
	
		<!-- error reporting service -->
		<service name="bugTracker" class="components/services/bugTrackerService.cfc">
			<init-param name="bugEmailSender" settingName="bugEmailSender" />
			<init-param name="bugEmailRecipients" settingName="bugEmailRecipients" />
		</service>
		
	</services>
</config>
