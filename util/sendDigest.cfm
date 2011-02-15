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
	if(cgi.server_port neq 80) thisHost = thisHost & ":" & cgi.server_port;

	oEntryDAO = oDAOFactory.getDAO("entry");
	oEntryFinder = createObject("component","bugLog.components.entryFinder").init(oEntryDAO);
	qryData = oEntryFinder.search(searchTerm = "", startDate = digestStartDate);
</cfscript>

<cfquery name="qryData" dbtype="query">
	SELECT ApplicationCode, ApplicationID, 
			HostName, HostID, 
			SeverityCode, SeverityID,
			Message, COUNT(*) AS bugCount, MAX(createdOn) as createdOn, MAX(entryID) AS EntryID
		FROM qryData
		GROUP BY 
				ApplicationCode, ApplicationID, 
				HostName, HostID, 
				SeverityCode, SeverityID,
				Message
		ORDER BY createdOn DESC
</cfquery>

<cfsavecontent variable="tmpHTML">
<cfoutput>
	<div style="font-family: arial,sans-serif;">
		<h1><span style="color:red;">BugLog</span>HQ Digest</h1>
	
		<p>BugLog has received the following bug reports since <b>#DateFormat(digestStartDate,"long")# #lsTimeFormat(digestStartDate)#</b>:</p>
		
		<table style="border-bottom:1px solid ##333;width:95%;font-family: arial,sans-serif;" cellpadding="4" cellspacing="2">
			<tr>
				<th style="background-color:##90A4B5;line-height: 18px;color: ##FFFFFF;font-size:13px;padding: 3px 9px 3px 9px;">Severity</th>
				<th style="background-color:##90A4B5;line-height: 18px;color: ##FFFFFF;font-size:13px;padding: 3px 9px 3px 9px;">Application</th>
				<th style="background-color:##90A4B5;line-height: 18px;color: ##FFFFFF;font-size:13px;padding: 3px 9px 3px 9px;">Host</th>
				<th style="background-color:##90A4B5;line-height: 18px;color: ##FFFFFF;font-size:13px;padding: 3px 9px 3px 9px;">Message</th>
				<th style="background-color:##90A4B5;line-height: 18px;color: ##FFFFFF;font-size:13px;padding: 3px 9px 3px 9px;">Count</th>
				<th style="background-color:##90A4B5;line-height: 18px;color: ##FFFFFF;font-size:13px;padding: 3px 9px 3px 9px;">Most Recent</th>
			</tr>
			<cfloop query="qryData">
				<cfset tmpURL = thisHost & "/bugLog/hq/index.cfm?event=ehGeneral.dspEntry&entryID=#qryData.EntryID#">
				<tr>
					<td align="center" style="line-height:16px;color:##333;font-size:12px;padding: 3px 3px 3px 9px;border-bottom:1px dotted silver;">#qryData.SeverityCode#</td>
					<td style="line-height:16px;color:##333;font-size:12px;padding: 3px 3px 3px 9px;border-bottom:1px dotted silver;">#qryData.applicationCode#</td>
					<td style="line-height:16px;color:##333;font-size:12px;padding: 3px 3px 3px 9px;border-bottom:1px dotted silver;">#qryData.HostName#</td>
					<td style="line-height:16px;color:##333;font-size:12px;padding: 3px 3px 3px 9px;border-bottom:1px dotted silver;">#qryData.Message#</td>
					<td align="right" style="line-height:16px;color:##333;font-size:12px;padding: 3px 3px 3px 9px;border-bottom:1px dotted silver;">#qryData.bugCount#</td>
					<td align="center" style="line-height:16px;color:##333;font-size:12px;padding: 3px 3px 3px 9px;border-bottom:1px dotted silver;"><a href="#tmpURL#">#dateFormat(qryData.createdOn,dateMask)# #lsTimeFormat(qryData.createdOn)#</a></td>
				</tr>
			</cfloop>
			<cfif qryData.recordCount eq 0>
				<tr><td colspan="6" style="line-height:16px;color:##333;font-size:12px;padding: 3px 3px 3px 9px;border-bottom:1px dotted silver;"><em>No bug reports received! Yay!</em></td></tr>
			</cfif>
		</table>
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

Done.