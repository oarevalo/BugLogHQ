<cfset rs = request.requestState>
<cfset qryData = rs.qryEntries>

<cfinclude template="../includes/udf.cfm">

<cfoutput>
	<cfinclude template="dashboard/bugs_by_severity.cfm">
	<hr />
	<div id="dashboard-content" class="clearfix">
		<div id="dashboard-left">
			<cfinclude template="dashboard/bugs_by_msg.cfm">	
		</div>
		<div id="dashboard-right">
			<cfinclude template="dashboard/last_alert.cfm">
			<br />
			<cfinclude template="dashboard/bugs_by_time.cfm">
		</div>
	</div>
</cfoutput>



