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
	<style type="text/css">
		p {
			font-family: "trebuchet MS", Arial, Helvetica, "Sans Serif";
		}
		.footer {
			color:##666;
			font-size:11px;
		}
		.browseTable {
			border-bottom:1px solid ##333;
			width:95%;
		}
		
		.browseTable th {
			font-family: "trebuchet MS", Arial, Helvetica, "Sans Serif";
		    background-color:##90A4B5;
			line-height: 18px;
			color: ##FFFFFF;
			padding: 3px 9px 3px 9px;
			font-size:13px;
			font-weight:bold;
		}
		.browseTable td {
			font-family: "trebuchet MS", Arial, Helvetica, "Sans Serif";
			line-height: 16px;
			color: ##333;
			padding: 3px 3px 3px 9px;
			font-size:12px;
			border-bottom:1px dotted silver;
		}
		
		.altRow {
		    background-color:##F6F6F6;
		}
		
		.listTI {
		    background-color:##6b8091;
		}
		.browseTable tr:hover {
		    background-color:##ebebeb;
		}
		.browseTable th a {
		    color:white;
		    text-decoration:none;
		}
		.browseTable th a:hover {
		    text-decoration:underline;
		}
	</style>

	<h1>BugLogHQ Digest</h1>

	<p>BugLog has received the following bug reports since <b>#lsDateFormat(digestStartDate)# #lsTimeFormat(digestStartDate)#</b>:</p>
	
	<table class="browseTable">
		<tr>
			<th>Severity</th>
			<th>Application</th>
			<th>Host</th>
			<th>Message</th>
			<th>Count</th>
			<th>Most Recent</th>
		</tr>
		<cfloop query="qryData">
			<cfset tmpURL = thisHost & "/bugLog/hq/index.cfm?event=ehGeneral.dspEntry&entryID=#qryData.EntryID#">
			<tr>
				<td align="center">#qryData.SeverityCode#</td>
				<td>#qryData.applicationCode#</td>
				<td>#qryData.HostName#</td>
				<td>#qryData.Message#</td>
				<td align="right">#qryData.bugCount#</td>
				<td align="center"><a href="#tmpURL#">#dateFormat(qryData.createdOn,dateMask)# #lsTimeFormat(qryData.createdOn)#</a></td>
			</tr>
		</cfloop>
		<cfif qryData.recordCount eq 0>
			<tr><td colspan="6"><em>No bug reports received! Yay!</em></td></tr>
		</cfif>
	</table>
	<br />
	<p class="footer">
		** This email has been sent from the BugLogHQ server at 
		<a href="#thisHost#/bugLog/hq">#thisHost#/bugLog/hq</a>
	</p>
</cfoutput>
</cfsavecontent>		

<cfif qrydata.recordCount gt 0 or (qryData.recordCount eq 0 and settings.sendIfEmpty)>
	<cfmail from="#adminEmail#" 
			to="#settings.recipients#"
			subject="BugLogHQ Digest"
			type="html">#tmpHTML#</cfmail>
</cfif>

Done.