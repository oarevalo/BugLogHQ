<cfset maxRows = 50>
<cfquery name="qryListing" dbtype="query">
	SELECT ApplicationCode, ApplicationID, 
			SeverityCode, SeverityID,
			Message, COUNT(*) AS bugCount, MAX(createdOn) as createdOn, MAX(entryID) AS EntryID
		FROM qryData
		GROUP BY 
				ApplicationCode, ApplicationID, 
				SeverityCode, SeverityID,
				Message
		ORDER BY bugCount DESC
</cfquery>

<cfoutput>	
<div style="text-align:center;">
	<b>Breakdown By Application & Message <cfif qryListing.recordCount gt maxRows>(Top #maxRows#)</cfif>:</b>
</div>
<table style="border-bottom:1px solid ##333;width:95%;font-family: arial,sans-serif;" cellpadding="0" cellspacing="2" align="center">
	<tr>
		<th style="background-color:##90A4B5;line-height: 14px;color: ##FFFFFF;font-size:13px;padding:3px;">&nbsp;</th>
		<th style="background-color:##90A4B5;line-height: 14px;color: ##FFFFFF;font-size:13px;padding:3px;">Count</th>
		<th style="background-color:##90A4B5;line-height: 14px;color: ##FFFFFF;font-size:13px;padding:3px;">Message (#min(qryListing.recordCount,maxRows)#)</th>
	</tr>
	<cfloop query="qryListing" endrow="#maxRows#">
		<cfset tmpURL = "index.cfm?event=entry&entryID=#qryListing.EntryID#">
		<cfset tmpImgURL = getSeverityIconURL(severityCode)>
		<tr style="line-height:12px;color:##333;font-size:12px;<cfif qryListing.currentRow mod 2>background-color:##F6F6F6;</cfif>">
			<td align="center" style="padding:3px;border-bottom:1px dotted silver;">
				<img src="#tmpImgURL#" align="absmiddle" alt="#severityCode#" title="Click to see all bugs flagged as '#severityCode#'">
			</td>
			<td align="center" style="padding:3px;border-bottom:1px dotted silver;font-weight:bold;font-size:18px;">#qryListing.bugCount#</td>
			<td style="padding:3px;border-bottom:1px dotted silver;">
				<div style="font-weight:bold;margin-bottom:4px;">
					#qryListing.Message#
				</div>
				<div style="font-size:11px;">
					on #qryListing.applicationCode#
					last received on
					<a href="#tmpURL#">#dateFormat(qryListing.createdOn,dateMask)# #lsTimeFormat(qryListing.createdOn)#</a>
				</div>
			</td>
		</tr>
	</cfloop>
	<cfif qryListing.recordCount eq 0>
		<tr><td colspan="6" style="line-height:16px;color:##333;font-size:12px;padding: 3px 3px 3px 9px;border-bottom:1px dotted silver;"><em>No bug reports received! Yay!</em></td></tr>
	</cfif>
</table>
</cfoutput>