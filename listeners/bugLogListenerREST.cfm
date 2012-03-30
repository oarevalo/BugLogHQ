<cfset variables.sourceName = "Post">

<cfparam name="message" type="string" default="">
<cfparam name="applicationCode" type="string" default="Unknown">
<cfparam name="dateTime" type="date" default="#now()#">
<cfparam name="severityCode" type="string" default="ERROR">
<cfparam name="hostName" type="string" default="#cgi.REMOTE_ADDR#">
<cfparam name="exceptionMessage" default="">
<cfparam name="exceptionDetails" default="">
<cfparam name="CFID" type="string" default="">
<cfparam name="CFTOKEN" type="string" default="">
<cfparam name="userAgent" type="string" default="">
<cfparam name="templatePath" type="string" default="">
<cfparam name="HTMLReport" type="string" default="">
<cfparam name="APIKey" type="string" default="">


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
<cfif oService.getSetting("requireAPIKey",false) and apikey neq oService.getSetting("APIKey")>
	<cfthrow message="Invalid API Key." type="bugLog.invalidAPIKey">
</cfif>

<cfscript>
	// get handle to bugLogListener service
	oBugLogListener = oService.getService();

	
	// create entry bean
	oRawEntry = createObject("component","bugLog.components.rawEntryBean").init();
	oRawEntry.setDateTime(dateTime);
	oRawEntry.setMessage(message);
	oRawEntry.setApplicationCode(applicationCode);
	oRawEntry.setSourceName(variables.sourceName);
	oRawEntry.setSeverityCode(severityCode);
	oRawEntry.setHostName(hostName);
	oRawEntry.setExceptionMessage(exceptionMessage);
	oRawEntry.setExceptionDetails(exceptionDetails);
	oRawEntry.setCFID(cfid);
	oRawEntry.setCFTOKEN(cftoken);
	oRawEntry.setUserAgent(userAgent);
	oRawEntry.setTemplatePath(templatePath);
	oRawEntry.setHTMLReport(HTMLReport);
	
	// log entry
	oBugLogListener.logEntry(oRawEntry);
	
</cfscript>
