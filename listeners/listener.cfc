<cfcomponent>
	<cfset variables.instanceName = "">

	<cffunction name="init" access="public" returntype="listener">
		<cfargument name="instanceName" type="string" required="true">
		<cfset variables.instanceName = arguments.instanceName>
		<cfreturn this>
	</cffunction>

	<cffunction name="logEntry" access="public" returntype="void">
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
		<cfargument name="source" type="string" required="false" default="Unknown">
		<cfscript>
			var oBugLogListener = 0;
			var oService = 0;
			var oRawEntry = 0;

			// get listener service wrapper
			oService = createObject("component", "bugLog.components.service").init( instanceName = variables.instanceName );
			
			// validate API Key
			oService.validateAPIKey(arguments.APIKey);
			
			// get handle to bugLogListener service
			oBugLogListener = oService.getService();
			
			// create entry bean
			oRawEntry = createObject("component","bugLog.components.rawEntryBean")
								.init()
								.setDateTime(arguments.dateTime)
								.setMessage(arguments.message)
								.setApplicationCode(arguments.applicationCode)
								.setSourceName(arguments.source)
								.setSeverityCode(arguments.severityCode)
								.setHostName(arguments.hostName)
								.setExceptionMessage(arguments.exceptionMessage)
								.setExceptionDetails(arguments.exceptionDetails)
								.setCFID(arguments.cfid)
								.setCFTOKEN(arguments.cftoken)
								.setUserAgent(arguments.userAgent)
								.setTemplatePath(arguments.templatePath)
								.setHTMLReport(arguments.HTMLReport);
			
			// log entry
			oBugLogListener.logEntry(oRawEntry);
		</cfscript>
	</cffunction>
	
</cfcomponent>