<cfparam name="instance" type="string" default="default">
<cfsetting enablecfoutputonly="true">

<!--- this is to make sure that this template can only be invoked
	from the sendDigest template, so that we don't show its contents
	to everyone --->
<cfif getFileFromPath(getBaseTemplatePath()) neq "sendDigest">
	<cfabort>
</cfif>

<!--- Handle service initialization if necessary --->
<cfset oService = createObject("component", "bugLog.components.service").init( instanceName = instance )>

<cfset oConfig = oService.getConfig()>

<cfset oDAOFactory = createObject("component","bugLog.components.DAOFactory").init( oConfig )>
<cfset oAppService = createObject("component","bugLog.components.hq.appService").init(instanceName = instance)>
<cfset oUtils = createObject("component","bugLog.components.util").init()>

<cfset settings = oAppService.getDigestSettings()>

<cfset dateMask = oConfig.getSetting("general.dateFormat")>

<cfscript>
	digestStartDate = dateAdd("h",-1*settings.schedulerIntervalHours,now());

	thisHost = oUtils.getBaseBugLogHREF(oConfig, instance);  // points to actual instance
	thisHostHQ = oUtils.getBugLogHQAppHREF(oConfig, instance);
	thisHostHQAssets = oUtils.getBugLogHQAssetsHREF(oConfig);

	oEntryDAO = oDAOFactory.getDAO("entry");
	oEntryFinder = createObject("component","bugLog.components.entryFinder").init(oEntryDAO);
	
	searchArgs = {
		searchTerm = "", 
		startDate = digestStartDate
	};
	
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
	</div>
</cfoutput>


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
		<cfset tmpURL = thisHostHQAssets & "images/severity/default.png">
	<cfelse>
		<cfset tmpURL = thisHostHQAssets & "images/severity/#lcase(severityCode)#.png">
	</cfif>
	<cfreturn tmpURL>
</cffunction>
