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
<table class="browseTable" style="width:100%">	
	<tr>
		<th>Application</th>
		<th>Host</th>
		<th style="width:50px;">Count</th>
		<th>Most Recent</th>
	</tr>
	<cfset prevAppCode = "">
	<cfoutput query="qrySummary">
		<tr <cfif qrySummary.currentRow mod 2>class="altRow"</cfif>>
			<cfif applicationCode eq prevAppCode>
				<td>&nbsp;</td>
			<cfelse>
				<td>
					<cfset tmpURL = "index.cfm?event=main&applicationID=#ApplicationID#">
					<a href="#tmpURL#">#ApplicationCode#</a>
				</td>
			</cfif>
			<td align="center">
				<cfset tmpURL = "index.cfm?event=main&applicationID=#ApplicationID#&hostID=#hostID#">
				<a href="#tmpURL#">#hostName#</a>
			</td>
			<td align="right">
				<cfset tmpURL = "index.cfm?event=log&msgFromEntryID=#EntryID#&applicationID=#ApplicationID#&hostID=#hostID#">
				<a href="#tmpURL#">#bugCount#</a>
			</td>
			<td align="center">
				<cfset tmpURL = "index.cfm?event=entry&entryID=#EntryID#">
				<a href="#tmpURL#">#showDateTime(qrySummary.createdOn)#</a>
			</td>
		</tr>
		<cfset prevAppCode = applicationCode>
	</cfoutput>
</table>
