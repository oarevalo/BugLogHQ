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



<cfsavecontent variable="tmpHTML">
	<div style="font-family: arial,sans-serif;">
		<h1><span style="color:red;">BugLog</span>HQ Digest</h1>
	
		<cfoutput>
		<p>BugLog has received the following bug reports since <b>#DateFormat(digestStartDate,"long")# #lsTimeFormat(digestStartDate)#</b>:</p>
		</cfoutput>
		
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

		<cfoutput>
			<p style="font-family: arial,sans-serif;color:##666;font-size:11px;">
				** This email has been sent from the BugLogHQ server at 
				<a href="#thisHost#/bugLog/hq">#thisHost#/bugLog/hq</a>
			</p>
		</cfoutput>
	</div>
</cfsavecontent>		

<cfif qrydata.recordCount gt 0 or (qryData.recordCount eq 0 and settings.sendIfEmpty)>
	<cfmail from="#adminEmail#" 
			to="#settings.recipients#"
			subject="BugLogHQ Digest"
			type="html">#tmpHTML#</cfmail>
</cfif>

Done.