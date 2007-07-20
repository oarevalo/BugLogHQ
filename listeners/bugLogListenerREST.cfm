<cfset variables.sourceID = 2>

<cfparam name="message" type="string">
<cfparam name="applicationCode" type="string">
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


<!--- Handle service initialization if necessary --->
<cfset oService = createObject("component", "bugLog.components.service").init()>

<!--- check that the directory service has been started, if not then start it --->
<cfif Not oService.isRunning()>
	<cflock name="bugLogListener_start" timeout="5">
		<!--- use double-checked locking to make sure there is only one initialization --->
		<cfif Not oService.isRunning()>
			<cfset oService.start( )>
		</cfif>
	</cflock>
</cfif>

<cfscript>
	// get handle to bugLogListener service
	oBugLogListener = oService.getService();

	
	// create entry bean
	oRawEntry = createObject("component","bugLog.components.rawEntryBean").init();
	oRawEntry.setDateTime(dateTime);
	oRawEntry.setMessage(message);
	oRawEntry.setApplicationCode(applicationCode);
	oRawEntry.setSourceID(variables.sourceID);
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
