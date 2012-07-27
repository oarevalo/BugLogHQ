<cfquery name="qrySummary" dbtype="query">
	SELECT ApplicationCode, ApplicationID, 
			HostName, HostID, 
			COUNT(*) AS bugCount, 
			MAX(createdOn) as createdOn, MAX(entryID) AS EntryID
		FROM qryData
		GROUP BY 
				ApplicationCode, ApplicationID, 
				HostName, HostID
		ORDER BY ApplicationCode, bugCount desc, createdOn DESC
</cfquery>

<b>Breakdown By Host:</b>
<table style="border-bottom:1px solid #333;font-family: arial,sans-serif;" cellpadding="0" cellspacing="2" border="1">
	<tr>
		<th style="background-color:#90A4B5;line-height: 14px;color: #FFFFFF;font-size:13px;padding:3px;">Application</th>
		<th style="background-color:#90A4B5;line-height: 14px;color: #FFFFFF;font-size:13px;padding:3px;">Host</th>
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
					<cfset tmpURL = thisHost & "hq/index.cfm?applicationID=#ApplicationID#">
					<a href="#tmpURL#">#ApplicationCode#</a>
				</td>
			</cfif>
			<td style="padding:3px;border:1px dotted silver;" align="center">
				<cfset tmpURL = thisHost & "hq/index.cfm?applicationID=#ApplicationID#&hostID=#hostID#">
				<a href="#tmpURL#">#hostName#</a>
			</td>
			<td style="padding:3px;border:1px dotted silver;padding-right:10px;" align="right">
				<cfset tmpURL = thisHost & "hq/index.cfm?event=log&msgFromEntryID=#EntryID#&applicationID=#ApplicationID#&hostID=#hostID#">
				<a href="#tmpURL#">#bugCount#</a>
			</td>
			<td style="padding:3px;border:1px dotted silver;" align="center">
				<cfset tmpURL = thisHost & "hq/index.cfm?event=entry&entryID=#EntryID#">
				<a href="#tmpURL#">#dateFormat(createdOn,dateMask)# #lsTimeFormat(createdOn)#</a>
			</td>
		</tr>
		<cfset prevAppCode = applicationCode>
	</cfoutput>
</table>
