<cfset maxRows = 10>
<cfset sortField = "bugCount">
<cfquery name="qryListing" dbtype="query">
	SELECT ApplicationCode, ApplicationID, 
			SeverityCode, SeverityID,
			Message, COUNT(*) AS bugCount, MAX(createdOn) as createdOn, MAX(entryID) AS EntryID
		FROM qryData
		GROUP BY 
				ApplicationCode, ApplicationID, 
				SeverityCode, SeverityID,
				Message
		ORDER BY #sortField# DESC
</cfquery>

<cfoutput>	
<div style="text-align:center;">
	<b>Breakdown By Application & Message <cfif qryListing.recordCount gt maxRows>(Top #maxRows#)</cfif>:</b>
</div>
<table class="browseTable" style="width:100%">	
	<tr>
		<th style="width:15px;">&nbsp;</th>
		<th style="width:35px;">Count</th>
		<th>Message (#min(qryListing.recordCount,maxRows)#)</th>
	</tr>
	<cfloop query="qryListing" endrow="#maxRows#">
		<cfset tmpEntryURL = "index.cfm?event=entry&entryID=#qryListing.EntryID#">
		<cfset tmpAppURL = "index.cfm?event=main&applicationID=#qryListing.applicationID#">
		<cfset tmpMsgURL = "index.cfm?event=log&applicationID=#qryListing.applicationID#&msgFromEntryID=#qryListing.EntryID#">
		<cfset tmpImgURL = getSeverityIconURL(severityCode)>
		<tr <cfif qryListing.currentRow mod 2>class="altRow"</cfif>>
			<td align="center">
				<img src="#tmpImgURL#" align="absmiddle" alt="#severityCode#" title="Click to see all bugs flagged as '#severityCode#'">
			</td>
			<td align="center" style="font-size:18px;"><a href="#tmpMsgURL#">#qryListing.bugCount#</a></td>
			<td>
				<div style="font-weight:bold;font-size:14px;">
					#HtmlEditFormat(qryListing.Message)#
				</div>
				<div style="font-size:12px;margin-top:3px;">
					on <a href="#tmpAppURL#">#qryListing.applicationCode#</a>
					last received on
					<a href="#tmpEntryURL#">#dateFormat(qryListing.createdOn,dateMask)# #lsTimeFormat(qryListing.createdOn)#</a>
				</div>
			</td>
		</tr>
	</cfloop>
	<cfif qryListing.recordCount eq 0>
		<tr><td colspan="3"><em>No bug reports received! Yay!</em></td></tr>
	</cfif>
</table>
</cfoutput>