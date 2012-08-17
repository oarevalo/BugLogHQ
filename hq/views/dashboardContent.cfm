<cfset rs = request.requestState>
<cfset qryData = rs.qryEntries>
<cfset dateMask = rs.dateFormatMask>

<cfoutput>
	<cfinclude template="dashboard/bugs_by_severity.cfm">
	<br />
		
	<div id="dashboard-content" class="clearfix">
		<div id="dashboard-left">
			<cfinclude template="dashboard/bugs_by_msg.cfm">	
		</div>
		<div id="dashboard-right">
			<cfinclude template="dashboard/bugs_by_time.cfm">
			<br /><br />
			<cfinclude template="dashboard/rule_triggers.cfm">
		</div>
	</div>
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
