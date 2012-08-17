<cfset qryTriggers = rs.qryTriggers>
<cfset numToShow = 1>
<cfif qryTriggers.recordCount eq 0>
	<cfexit method="exittemplate">
</cfif>

<cfoutput>	
	<b>Most Recent Alert<cfif numToShow gt 1>s</cfif>:</b>
	<cfloop query="qryTriggers" startrow="1" endrow="#min(numToShow,qryTriggers.recordCount)#">
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

		<div class="alert">
			<div style="margin-bottom:3px;">
				<strong style="font-size:13px;">#qryTriggers.name#</strong>
			</div>
			<span class="badge badge-#color_code_severity#">
				<img src="#tmpImgURL#" align="absmiddle" alt="#qryTriggers.severity_code#" title="#qryTriggers.severity_code#">
				#lcase(qryTriggers.severity_code)#
			</span>
			&nbsp;
			<em>#tmpMessage#</em><br />
			on <a href="#tmpAppURL#">#qryTriggers.application_Code#</a> 
			(<a href="#tmpHostURL#">#qryTriggers.hostname#</a>)
			received on
			<a href="#tmpEntryURL#">#dateFormat(qryTriggers.createdOn,dateMask)# #lsTimeFormat(qryTriggers.createdOn)#</a>
		</div>
	</cfloop>
</cfoutput>