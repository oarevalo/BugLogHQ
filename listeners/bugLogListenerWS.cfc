<cfcomponent>
	<cfset variables.sourceName = "WebService">

	<cffunction name="logEntry" access="remote" returntype="boolean">
		<cfargument name="dateTime" type="Date" required="true">
		<cfargument name="message" type="string" required="true">
		<cfargument name="applicationCode" type="string" required="true">
		<cfargument name="severityCode" type="string" required="true">
		<cfargument name="hostName" type="string" required="true">
		<cfargument name="exceptionMessage" required="false" default="">
		<cfargument name="exceptionDetails" required="false" default="">
		<cfargument name="CFID" type="string" required="false" default="">
		<cfargument name="CFTOKEN" type="string" required="false" default="">
		<cfargument name="userAgent" type="string" required="false" default="">
		<cfargument name="templatePath" type="string" required="false" default="">
		<cfargument name="HTMLReport" type="string" required="false" default="">
		<cfargument name="APIKey" type="string" required="false" default="">

		<cfscript>
			var oBugLogListener = 0;
			var oService = 0;
			var oRawEntry = 0;
		</cfscript>

		<!--- Handle service initialization if necessary --->
		<cfset oService = createObject("component", "bugLog.components.service").init()>
		
		<!--- check that the directory service has been started, if not then start it --->
		<cfif Not oService.isRunning() and oService.getSetting("autoStart")>
			<cflock name="bugLogListener_start" timeout="5">
				<!--- use double-checked locking to make sure there is only one initialization --->
				<cfif Not oService.isRunning()>
					<cfset oService.start( )>
				</cfif>
			</cflock>
		</cfif>

		<!--- validate API Key (if required) --->
		<cfif oService.getSetting("requireAPIKey",false) and arguments.apikey neq oService.getSetting("APIKey")>
			<cfthrow message="Invalid API Key." type="bugLog.invalidAPIKey">
		</cfif>
				
		<cfscript>
			// get handle to bugLogListener service
			oBugLogListener = oService.getService();
			
			// create entry bean
			oRawEntry = createObject("component","bugLog.components.rawEntryBean").init();
			oRawEntry.setDateTime(arguments.dateTime);
			oRawEntry.setMessage(arguments.message);
			oRawEntry.setApplicationCode(arguments.applicationCode);
			oRawEntry.setSourceName(variables.sourceName);
			oRawEntry.setSeverityCode(arguments.severityCode);
			oRawEntry.setHostName(arguments.hostName);
			oRawEntry.setExceptionMessage(arguments.exceptionMessage);
			oRawEntry.setExceptionDetails(arguments.exceptionDetails);
			oRawEntry.setCFID(arguments.cfid);
			oRawEntry.setCFTOKEN(arguments.cftoken);
			oRawEntry.setUserAgent(arguments.userAgent);
			oRawEntry.setTemplatePath(arguments.templatePath);
			oRawEntry.setHTMLReport(arguments.HTMLReport);
			
			// log entry
			oBugLogListener.logEntry(oRawEntry);
			
			return true;
		</cfscript>
	</cffunction>
	
</cfcomponent>