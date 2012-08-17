<cfset rs = request.requestState>
<cfset qryData = rs.qryEntries>
<cfset dateMask = rs.dateFormatMask>

<cfoutput>
	<cfinclude template="dashboard/bugs_by_severity.cfm">
	<br />
	<table width="100%">
		<tr valign="top">
			<td width="50%">
				<cfinclude template="dashboard/bugs_by_msg.cfm">	
			</td>
			<td style="width:20px;">&nbsp;</td>
			<td align="center">
				<cfinclude template="dashboard/bugs_by_time.cfm">
				<br /><br />
				<cfinclude template="dashboard/rule_triggers.cfm">
			</td>
		</tr>
	</table>
</cfoutput>


<cffunction name="getSeverityIconURL" returntype="string">
	<cfargument name="severityCode" type="string" required="true">
	<cfset var tmpURL = "images/severity/#lcase(severityCode)#.png">
	<cfif not fileExists(expandPath(tmpURL))>
		<cfset tmpURL = "images/severity/default.png">
	<cfelse>
		<cfset tmpURL = "images/severity/#lcase(severityCode)#.png">
	</cfif>
	<cfreturn tmpURL>
</cffunction>
