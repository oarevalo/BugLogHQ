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
				<cfset tmpImgURL = getSeverityIconURL(severityCode)>
				<td>
					<span class="badge badge-info">
						<img src="#tmpImgURL#" align="absmiddle" alt="#severityCode#" title="Click to see all bugs flagged as '#severityCode#'">
						<strong>#SeverityCode#</strong>: #bugCount#
					</span>
				</td>
				<td style="width:10px;border:0px;">&nbsp;</td>
			</cfloop>
		</tr>
	</table>
</cfoutput>