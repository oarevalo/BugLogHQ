<cfsetting enablecfoutputonly="true">

<cfset oConfig = createObject("component","bugLog.components.config").init(configProviderType = "xml", 
																			configDoc = "/bugLog/config/buglog-config.xml.cfm")>

<cfset oDAOFactory = createObject("component","bugLog.components.DAOFactory").init( oConfig )>
<cfset oAppService = createObject("component","bugLog.hq.components.services.appService").init("/bugLog", oConfig)>

<cfset settings = oAppService.getDigestSettings()>

<cfset adminEmail = oConfig.getSetting("general.adminEmail")>
<cfset dateMask = oConfig.getSetting("general.dateFormat")>

<cfif !settings.enabled>
	Digest report is not enabled.
	<cfabort>
</cfif>

<cfscript>
	if(settings.recipients eq "")
		settings.recipients = adminEmail;
	
	digestStartDate = dateAdd("h",-1*settings.schedulerIntervalHours,now());

	if(cgi.server_port_secure) thisHost = "https://"; else thisHost = "http://";
	thisHost = thisHost & cgi.server_name;
	if(cgi.server_port neq 80 and cgi.server_port neq 443) thisHost = thisHost & ":" & cgi.server_port;

	oEntryDAO = oDAOFactory.getDAO("entry");
	oEntryFinder = createObject("component","bugLog.components.entryFinder").init(oEntryDAO);
	
	searchArgs = {
		searchTerm = "", 
		startDate = digestStartDate
	}
	
	if(settings.severity neq "") {
		oFinder = createObject("component","bugLog.components.severityFinder").init(oDAOFactory.getDAO("severity"));
		searchArgs.severityID = ToIDList(settings.severity, oFinder);
	}
	if(settings.application neq "") {
		oFinder = createObject("component","bugLog.components.appFinder").init(oDAOFactory.getDAO("application"));
		searchArgs.applicationID = ToIDList(settings.application, oFinder);
	}
	if(settings.host neq "") {
		oFinder = createObject("component","bugLog.components.hostFinder").init(oDAOFactory.getDAO("host"));
		searchArgs.hostID = ToIDList(settings.host, oFinder);
	}

	qryData = oEntryFinder.search(argumentCollection = searchArgs);
</cfscript>

<cfsavecontent variable="tmpHTML">
	<cfoutput>
	<div style="font-family: arial,sans-serif;">
		<h1><span style="color:red;">BugLog</span>HQ Digest</h1>
	
		<p>The BugLog Server at <a href="#thisHost#">#thisHost#</a> has received the 
		following bug reports in the last 
		<b>#settings.schedulerIntervalHours# hour<cfif settings.schedulerIntervalHours gt 1>s</cfif></b>  
		since <b>#DateFormat(digestStartDate,"long")# #lsTimeFormat(digestStartDate)#</b>:</p>
		
		<cfinclude template="includes/digest_bugs_by_severity.cfm">
		<br />

		<table width="100%" border="0">
			<tr valign="top">
				<td width="49%" align="center">
					<cfinclude template="includes/digest_bugs_by_app_severity.cfm">
				</td>
				<td>&nbsp;</td>
				<td width="49%" align="center">
					<cfinclude template="includes/digest_bugs_by_host.cfm">
				</td>
			</tr>
		</table>

		<br /><br />
		<cfinclude template="includes/digest_bugs_by_msg.cfm">
		
		<br />

		<p style="font-family: arial,sans-serif;color:##666;font-size:11px;">
			** This email has been sent from the BugLogHQ server at 
			<a href="#thisHost#/bugLog/hq">#thisHost#/bugLog/hq</a>
		</p>
	</div>
	</cfoutput>
</cfsavecontent>		

<cfif qrydata.recordCount gt 0 or (qryData.recordCount eq 0 and settings.sendIfEmpty)>
	<cfmail from="#adminEmail#" 
			to="#settings.recipients#"
			subject="BugLogHQ Digest"
			type="html">#tmpHTML#</cfmail>
</cfif>

<cfoutput>Done</cfoutput>.


<cffunction name="ToIDList" returntype="string">
	<cfargument name="list" type="string">
	<cfargument name="finder" type="any">
	<cfscript>
		var rtn = [];
		var i = 0;
		var isNot = (left(list,1) eq "-");
	
		if(isNot) list = removechars(list,1,1);
	
		for(i=1;i lte listLen(list);i++) {
			arrayAppend( rtn, finder.findByCode(listGetAt(list,i)).getID() );
		}
		
		rtn = arrayToList(rtn);
		if(isNot) rtn = "-" & rtn;
					
		return rtn;
	</cfscript>
</cffunction>

<cffunction name="getSeverityIconURL" returntype="string">
	<cfargument name="severityCode" type="string" required="true">
	<cfset var tmpURL = "/bugLog/hq/images/severity/#lcase(severityCode)#.png">
	<cfif not fileExists(expandPath(tmpURL))>
		<cfset tmpURL = "/bugLog/hq/images/severity/default.png">
	</cfif>
	<cfreturn tmpURL>
</cffunction>
