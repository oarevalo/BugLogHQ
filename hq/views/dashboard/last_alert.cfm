<cfset qryTriggers = rs.qryTriggers>
<cfif qryTriggers.recordCount eq 0>
	<cfexit method="exittemplate">
</cfif>
<cfset currentAlertID = 0>
<cfif currentAlertID eq 0>
	<cfset currentAlertID = qryTriggers.extensionLogID>
</cfif>
<cfset numAlerts = 1>

<cfoutput>	
	<b>Recent Alerts:</b>
	<cfloop query="qryTriggers" startrow="1" endrow="#min(numAlerts,qryTriggers.recordCount)#">
		<cfset tmpEntryURL = "index.cfm?event=entry&entryID=#qryTriggers.EntryID#">
		<cfset tmpAppURL = "index.cfm?event=main&applicationID=#qryTriggers.applicationID#">
		<cfset tmpHostURL = "index.cfm?event=main&applicationID=#qryTriggers.applicationID#&hostID=#qryTriggers.hostID#">
		<cfset tmpMsgURL = "index.cfm?event=log&applicationID=#qryTriggers.applicationID#&msgFromEntryID=#qryTriggers.EntryID#">
		<cfset tmpImgURL = getSeverityIconURL(qryTriggers.severity_code)>
		<cfif qryTriggers.message eq "">
			<cfset tmpMessage = "<em>No message</em>">
		<cfelse>		
			<cfset tmpMessage = HtmlEditFormat(qryTriggers.message)>
		</cfif>
		<cfset color_code_severity = getColorCodeBySeverity(qryTriggers.severity_code)>

		<div class="alert triggerAlert" rel="#tmpEntryURL#" style="margin-bottom:3px;">
			<div style="margin-bottom:3px;" title="Click to view details">
				<strong style="font-size:13px;">#qryTriggers.name#</strong>
			</div>
			<div>
				<div style="margin-bottom:3px;">
					<span class="badge badge-#color_code_severity#">
						<img src="#tmpImgURL#" align="absmiddle" alt="#qryTriggers.severity_code#" title="#qryTriggers.severity_code#">
						#lcase(qryTriggers.severity_code)#
					</span>
					&nbsp;
					<em>#tmpMessage#</em>
				</div>
				on <a href="#tmpAppURL#">#qryTriggers.application_Code#</a> 
				(<a href="#tmpHostURL#">#qryTriggers.hostname#</a>)
				received on
				<a href="#tmpEntryURL#">#showDateTime(qryTriggers.entry_createdOn)#</a>
			</div>
		</div>
	</cfloop>
	<div style="float:right;">
		<cfif qryTriggers.recordCount gt numAlerts>
			<cfset tmp = qryTriggers.recordCount-numAlerts>
			#tmp# more alert<cfif tmp gt 1>s</cfif> fired.
		</cfif>
		<a href="index.cfm?event=extensions.main">More...</a>
	</div>
</cfoutput>

<script type="text/javascript">
$(document).ready(function(){
	$('.triggerAlert').click(function(){
		var href = $(this).attr("rel");
		document.location = href;
	});
});
</script>