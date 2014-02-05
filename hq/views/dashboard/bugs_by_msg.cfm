<cfset maxRows = rs.criteria.rows>
<cfset sortBy = rs.criteria.sortBy>

<!--- determine required sort field --->
<cfswitch expression="#sortBy#">
	<cfcase value="most_recent">
		<cfset sortField = "createdOn desc,bugCount desc">
	</cfcase>
	<cfcase value="most_frequent">
		<cfset sortField = "bugCount desc,createdOn desc">
	</cfcase>
	<cfdefaultcase>
		<cfset sortBy = "most_frequent">
		<cfset sortField = "bugCount desc,createdOn desc">
	</cfdefaultcase>
</cfswitch>

<cfquery name="qryListing" dbtype="query">
	SELECT ApplicationCode, ApplicationID, 
			SeverityCode, SeverityID,
			Message, COUNT(*) AS bugCount, MAX(createdOn) as createdOn, MAX(entryID) AS EntryID
		FROM qryData
		GROUP BY 
				ApplicationCode, ApplicationID, 
				SeverityCode, SeverityID,
				Message
		ORDER BY #sortField#
</cfquery>

<cfoutput>
<cfif qryListing.recordCount gt maxRows>
	<div style="float:right;">
		<b>1 to #min(maxRows,qryListing.recordCount)#</b>
		&nbsp;|&nbsp;
		<a href="index.cfm?event=dashboard&rows=#maxRows+5#">More...</a>	
	</div>
</cfif>
<b>Recent Messages <cfif  qryListing.recordCount gt 0>(#qryListing.recordCount#)</cfif></b>	
<table style="width:100%;" class="table table-striped">	
	<tbody>
	<cfloop query="qryListing" endrow="#maxRows#">
		<cfset tmpEntryURL = "index.cfm?event=entry&entryID=#qryListing.EntryID#">
		<cfset tmpAppURL = "index.cfm?event=main&applicationID=#qryListing.applicationID#&hostID=#rs.criteria.hostID#&severityID=#rs.criteria.severityID#&numDays=#rs.criteria.numDays#">
		<cfset tmpMsgURL = "index.cfm?event=log&applicationID=#qryListing.applicationID#&msgFromEntryID=#qryListing.EntryID#&hostID=#rs.criteria.hostID#&severityID=#rs.criteria.severityID#&numDays=#rs.criteria.numDays#">
		<cfset tmpImgURL = getSeverityIconURL(severityCode)>
		<cfif qryListing.message eq "">
			<cfset tmpMessage = "<em>No message</em>">
		<cfelse>		
			<cfset tmpMessage = HtmlEditFormat(qryListing.message)>
		</cfif>
		
		<cfset color_code_count = getColorCodeByCount(qryListing.bugCount)>
		<cfset color_code_severity = getColorCodeBySeverity(qryListing.severityCode)>

		<tr>
			<td>
				<div class="pull-right" style="position:relative;z-index:2;">
					<span class="badge badge-#color_code_count#">
						<a href="#tmpMsgURL#" title="This bug report has occurred #qryListing.bugCount# times">#qryListing.bugCount#</a>
					</span>
				</div>
				<div style="font-weight:bold;font-size:13px;">
					<span class="badge badge-#color_code_severity#">
						<img src="#tmpImgURL#" align="absmiddle" alt="#qryListing.severityCode#" title="#qryListing.severityCode#">
						#lcase(qryListing.severityCode)#
					</span>
					&nbsp;
					<span class="cell_message" rel="#tmpEntryURL#" title="#htmlEditFormat(tmpMessage)#">#tmpMessage#</span>
				</div>
				<div style="font-size:12px;margin-top:3px;">
					on <a href="#tmpAppURL#" title="View all bug reports for this application">#qryListing.applicationCode#</a>
					last received on
					<a href="#tmpEntryURL#" title="View bug report">#showDateTime(qryListing.createdOn)#</a>
				</div>
			</td>
		</tr>
	</cfloop>
	<cfif qryListing.recordCount eq 0>
		<tr><td><em>No bug reports received! Yay!</em></td></tr>
	</cfif>
	</tbody>
</table>
<cfif qryListing.recordCount gt 0>
	<div style="float:right;">
		<cfif maxRows neq 5>
			<a href="index.cfm?event=dashboard&rows=5">Reset</a>	
			&nbsp;|&nbsp;
		</cfif>
		<a href="index.cfm?event=main&sortBy=bugCount&sortDir=desc&applicationID=#rs.criteria.applicationID#&hostID=#rs.criteria.hostID#">Show All</a>	
	</div>
	<div>
		<cfif sortBy eq "most_frequent">
			<b>&raquo; Showing most frequent first</b>
			(<a href="index.cfm?event=dashboard&sortBy=most_recent">toggle to most recent</a>)
		<cfelse>
			<b>&raquo; Showing most recent first</b>
			(<a href="index.cfm?event=dashboard&sortBy=most_frequent">toggle to most frequent</a>)
		</cfif>
	</div>
</cfif>
</cfoutput>
<script type="text/javascript">
$(document).ready(function(){
	$('.cell_message').click(function(){
		var rel = $(this).attr("rel");
		document.location = rel;
	});
});
</script>