<cfquery name="qryListing" dbtype="query">
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
		ORDER BY bugCount DESC
</cfquery>

<div style="text-align:center;">
	<b>Breakdown By Application, Host & Message:</b>
</div>
<cfoutput>	
<table style="border-bottom:1px solid ##333;width:95%;font-family: arial,sans-serif;" cellpadding="0" cellspacing="2" align="center">
	<tr>
		<th style="background-color:##90A4B5;line-height: 14px;color: ##FFFFFF;font-size:13px;padding:3px;">Severity</th>
		<th style="background-color:##90A4B5;line-height: 14px;color: ##FFFFFF;font-size:13px;padding:3px;">Application</th>
		<th style="background-color:##90A4B5;line-height: 14px;color: ##FFFFFF;font-size:13px;padding:3px;">Host</th>
		<th style="background-color:##90A4B5;line-height: 14px;color: ##FFFFFF;font-size:13px;padding:3px;">Message</th>
		<th style="background-color:##90A4B5;line-height: 14px;color: ##FFFFFF;font-size:13px;padding:3px;">Count</th>
		<th style="background-color:##90A4B5;line-height: 14px;color: ##FFFFFF;font-size:13px;padding:3px;">Most Recent</th>
	</tr>
	<cfloop query="qryListing">
		<cfset tmpURL = thisHost & "/bugLog/hq/index.cfm?event=ehGeneral.dspEntry&entryID=#qryListing.EntryID#">
		<tr style="line-height:12px;color:##333;font-size:12px;<cfif qryListing.currentRow mod 2>background-color:##F6F6F6;</cfif>">
			<td align="center" style="padding:3px;border-bottom:1px dotted silver;">
				<img src="#thisHost#/bugLog/hq/images/severity/#lcase(SeverityCode)#.png" align="absmiddle" alt="#severityCode#" title="Click to see all bugs flagged as '#severityCode#'">
			</td>
			<td style="padding:3px;border-bottom:1px dotted silver;">#qryListing.applicationCode#</td>
			<td style="padding:3px;border-bottom:1px dotted silver;">#qryListing.HostName#</td>
			<td style="padding:3px;border-bottom:1px dotted silver;">#qryListing.Message#</td>
			<td align="right" style="padding:3px;border-bottom:1px dotted silver;">#qryListing.bugCount#</td>
			<td align="center" style="padding:3px;border-bottom:1px dotted silver;"><a href="#tmpURL#">#dateFormat(qryListing.createdOn,dateMask)# #lsTimeFormat(qryListing.createdOn)#</a></td>
		</tr>
	</cfloop>
	<cfif qryListing.recordCount eq 0>
		<tr><td colspan="6" style="line-height:16px;color:##333;font-size:12px;padding: 3px 3px 3px 9px;border-bottom:1px dotted silver;"><em>No bug reports received! Yay!</em></td></tr>
	</cfif>
</table>
</cfoutput>