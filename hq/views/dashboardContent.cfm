<cfset rs = request.requestState>
<cfset qryData = rs.qryEntries>
<cfset dateMask = rs.dateFormatMask>

<cfinclude template="../includes/udf.cfm">

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



