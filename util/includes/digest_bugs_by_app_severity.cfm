<cfquery name="qrySummary" dbtype="query">
	SELECT ApplicationCode, ApplicationID, 
			SeverityCode, SeverityID,
			COUNT(*) AS bugCount, 
			MAX(createdOn) as createdOn, MAX(entryID) AS EntryID
		FROM qryData
		GROUP BY 
				ApplicationCode, ApplicationID, 
				SeverityCode, SeverityID
		ORDER BY ApplicationCode, bugCount desc, createdOn DESC
</cfquery>

<b>Breakdown By Severity:</b>
<table style="border-bottom:1px solid #333;font-family: arial,sans-serif;" cellpadding="0" cellspacing="2" border="1">
	<tr>
		<th style="background-color:#90A4B5;line-height: 14px;color: #FFFFFF;font-size:13px;padding:3px;">Application</th>
		<th style="width:65px;background-color:#90A4B5;line-height: 14px;color: #FFFFFF;font-size:13px;padding:3px;">Severity</th>
		<th style="width:50px;background-color:#90A4B5;line-height: 14px;color: #FFFFFF;font-size:13px;padding:3px;">Count</th>
		<th style="background-color:#90A4B5;line-height: 14px;color: #FFFFFF;font-size:13px;padding:3px;">Most Recent</th>
	</tr>
	<cfset prevAppCode = "">
	<cfoutput query="qrySummary">
		<tr valign="top" style="line-height:12px;color:##333;font-size:12px;<cfif currentRow mod 2>background-color:##F6F6F6;</cfif>">
			<cfif applicationCode eq prevAppCode>
				<td style="padding:3px;border:1px dotted silver;">&nbsp;</td>
			<cfelse>
				<td style="padding:3px;border:1px dotted silver;">
					<cfset tmpURL = thisHostHQ & "index.cfm?applicationID=#ApplicationID#">
					<a href="#tmpURL#">#ApplicationCode#</a>
				</td>
			</cfif>
			<td style="padding:3px;border:1px dotted silver;" align="center">
				<cfset tmpURL = thisHostHQ & "index.cfm?applicationID=#ApplicationID#&severityID=#severityID#">
				<cfset tmpImgURL = getSeverityIconURL(severityCode)>
				<a href="#tmpURL#"><img src="#tmpImgURL#" align="absmiddle" alt="#severityCode#" title="Click to see all bugs flagged as '#severityCode#'"></a>
			</td>
			<td style="padding:3px;border:1px dotted silver;padding-right:10px;" align="right">
				<cfset tmpURL = thisHostHQ & "index.cfm?event=ehGeneral.dspLog&msgFromEntryID=#EntryID#&applicationID=#ApplicationID#&severityID=#severityID#">
				<a href="#tmpURL#">#bugCount#</a>
			</td>
			<td style="padding:3px;border:1px dotted silver;" align="center">
				<cfset tmpURL = thisHostHQ & "index.cfm?event=ehGeneral.dspEntry&entryID=#EntryID#">
				<a href="#tmpURL#">#dateFormat(createdOn,dateMask)# #lsTimeFormat(createdOn)#</a>
			</td>
		</tr>
		<cfset prevAppCode = applicationCode>
	</cfoutput>
</table>
