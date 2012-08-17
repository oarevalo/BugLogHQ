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
				<cfswitch expression="#qrySummary.severityCode#">
					<cfcase value="fatal">
						<cfset color_code_label = "important">
					</cfcase>
					<cfcase value="error">
						<cfset color_code_label = "warning">
					</cfcase>
					<cfcase value="info">
						<cfset color_code_label = "info">
					</cfcase>
					<cfdefaultcase>
						<cfset color_code_label = "default">
					</cfdefaultcase>
				</cfswitch>
				<td>
					<span class="badge badge-#color_code_label#">
						<a href="#tmpSeverityURL#" title="Click to see all bugs flagged as '#severityCode#'"><img 
								src="#tmpImgURL#" align="absmiddle" alt="#qrySummary.severityCode#">
							<b>#lcase(qrySummary.SeverityCode)#</b>: #qrySummary.bugCount#
						</a>
					</span>
				</td>
				<td style="width:10px;border:0px;">&nbsp;</td>
			</cfloop>
		</tr>
	</table>
</cfoutput>