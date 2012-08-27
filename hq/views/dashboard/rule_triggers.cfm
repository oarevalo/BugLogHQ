<cfset qryTriggers = rs.qryTriggers>
<cfoutput>	
<div style="text-align:center;">
	<b>Recent Alerts:</b>
</div>
<table class="browseTable" style="width:100%">	
	<tr>
		<th>&nbsp;</th>
		<th>Alert</th>
	</tr>
	<cfloop query="qryTriggers">
		<cfset tmpEntryURL = "index.cfm?event=entry&entryID=#qryTriggers.EntryID#">
		<cfset tmpAppURL = "index.cfm?event=main&applicationID=#qryTriggers.applicationID#">
		<cfset tmpHostURL = "index.cfm?event=main&applicationID=#qryTriggers.applicationID#&hostID=#qryTriggers.hostID#">
		<cfset tmpMsgURL = "index.cfm?event=log&applicationID=#qryTriggers.applicationID#&msgFromEntryID=#qryTriggers.EntryID#">
		<cfset tmpImgURL = getSeverityIconURL(qryTriggers.severity_code)>
		<cfif qryTriggers.message eq "">
			<cfset tmpMessage = "<em>No message</em>">
		<cfelse>		
			<cfset tmpMessage = HtmlEditFormat(qryTriggers.message)>
		</cfif>

		<tr <cfif qryTriggers.currentRow mod 2>class="altRow"</cfif>>
			<td align="center">
				<img src="#tmpImgURL#" align="absmiddle" alt="#severity_code#" title="Click to see all bugs flagged as '#severity_code#'">
			</td>
			<td>
				<div style="font-weight:bold;font-size:14px;">
					#qryTriggers.name#
				</div>
				<div style="font-size:12px;margin-top:3px;">
					by <em>#tmpMessage#</em><br />
					on <a href="#tmpAppURL#">#qryTriggers.application_Code#</a> 
					(<a href="#tmpHostURL#">#qryTriggers.hostname#</a>)
					received on
					<a href="#tmpEntryURL#">#showDateTime(qryTriggers.createdOn)#</a>
				</div>
			</td>
		</tr>
	</cfloop>
	<cfif qryTriggers.recordCount eq 0>
		<tr><td colspan="2"><em>No alerts triggered! Yay!</em></td></tr>
	</cfif>
</table>
</cfoutput>