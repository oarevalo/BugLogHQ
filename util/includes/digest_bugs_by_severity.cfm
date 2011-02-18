<cfquery name="qrySummary" dbtype="query">
	SELECT SeverityCode, SeverityID, count(*) as BugCount
		FROM qryData
		GROUP BY SeverityCode, SeverityID
		ORDER BY SeverityCode
</cfquery>

<cfoutput>
	<div style="text-align:center;">
		<b>Total By Severity:</b>
	</div>
	<table style="border-bottom:1px solid ##333;font-family: arial,sans-serif;" cellpadding="0" cellspacing="2" border="1" align="center">
		<tr style="line-height:12px;color:##333;font-size:12px;">
			<cfloop query="qrySummary">
				<td style="padding:3px;border:1px dotted silver;">
					<img src="#thisHost#/bugLog/hq/images/severity/#lcase(SeverityCode)#.png" align="absmiddle" alt="#severityCode#" title="Click to see all bugs flagged as '#severityCode#'">
					<strong>#SeverityCode#</strong>: #bugCount#
				</td>
				<td style="width:10px;border:0px;">&nbsp;</td>
			</cfloop>
		</tr>
	</table>
</cfoutput>