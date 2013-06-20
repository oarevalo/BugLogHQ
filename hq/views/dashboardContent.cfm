<cfset rs = request.requestState>
<cfset qryData = rs.qryEntries>

<cfinclude template="../includes/udf.cfm">

<cftry>
	<cfset contents = {
		top = renderContent("views/dashboard/bugs_by_severity.cfm"),
		left1 = renderContent("views/dashboard/bugs_by_msg.cfm"),
		right1 = renderContent("views/dashboard/last_alert.cfm"),
		right2 = renderContent("views/dashboard/bugs_by_time.cfm")
	}>
	
	<cfoutput>
		#contents.top#
		<hr />
		<div class="row">
			<div class="span6">
				#contents.left1#	
			</div>
			<div class="span6">
				<div style="margin-left:10px;">
					#contents.right1#	
					#contents.right2#	
				</div>
			</div>
		</div>
	</cfoutput>

	<cfcatch type="any">
		<cfoutput>
			<cfset rs.bugTracker.notifyService(cfcatch.message, cfcatch)>
			<b>Error:</b> #cfcatch.message#. #cfcatch.detail#
			<script>
				// stop the automatic page refresh
				stopInterval();
			</script>
		</cfoutput>
	</cfcatch>
</cftry>		
