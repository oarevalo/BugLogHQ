<cfquery name="qrySummary" dbtype="query">
	SELECT SeverityCode, SeverityID, count(*) as BugCount
		FROM qryData
		GROUP BY SeverityCode, SeverityID
		ORDER BY BugCount DESC
</cfquery>

<cfoutput>
	<table cellpadding="0" cellspacing="2" align="center">
		<tr>
			<cfloop query="qrySummary">
				<cfset tmpImgURL = getSeverityIconURL(qrySummary.severityCode)>
				<cfset tmpSeverityURL = "index.cfm?event=main&severityID=#qrySummary.SeverityID#&numDays=#rs.criteria.numDays#&hostID=#rs.criteria.hostID#&applicationID=#rs.criteria.applicationID#">
				<td>
					<span class="badge badge-info">
						<a href="#tmpSeverityURL#"><img 
								src="#tmpImgURL#" align="absmiddle" alt="#qrySummary.severityCode#" 
								title="Click to see all bugs flagged as '#severityCode#'">
							<b>#qrySummary.SeverityCode#</b>: #qrySummary.bugCount#
						</a>
					</span>
				</td>
				<td style="width:10px;border:0px;">&nbsp;</td>
			</cfloop>
		</tr>
	</table>
</cfoutput>