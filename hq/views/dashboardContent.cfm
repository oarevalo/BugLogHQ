<cfset rs = request.requestState>
<cfset qryData = rs.qryEntries>

<cfinclude template="../includes/udf.cfm">

<cfset contents = {
	top = renderContent("views/dashboard/bugs_by_severity.cfm"),
	left1 = renderContent("views/dashboard/bugs_by_msg.cfm"),
	right1 = renderContent("views/dashboard/last_alert.cfm"),
	right2 = renderContent("views/dashboard/bugs_by_time.cfm")
}>

<cfoutput>
	#contents.top#
	<hr />
	<div id="dashboard-content" class="clearfix">
		<div id="dashboard-left">
			#contents.left1#	
		</div>
		<div id="dashboard-right">
			#contents.right1#	
			<br />
			#contents.right2#	
		</div>
	</div>
</cfoutput>
