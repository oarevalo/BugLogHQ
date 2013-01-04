<!--- page parameters used for paging records --->
<cfparam name="rs.startRow" default="1">
<cfparam name="rs.rowsPerPage" default="20">

<!--- setup variables for paging records --->
<cfset numPages = ceiling(rs.qryHistory.recordCount / rs.rowsPerPage)>
<cfset currPage = int(rs.startRow/rs.rowsPerPage)+1>
<cfset endRow = rs.startRow+rs.rowsPerPage-1>
<cfif endRow gt rs.qryHistory.recordCount>
	<cfset endRow = rs.qryHistory.recordCount>
</cfif>
<cfset delta = 5>

<cfoutput>
	<div style="font-size:10px;line-height:20px;margin-top:10px;font-weight:bold;">
		Showing entries #rs.startRow# - #endRow# of #rs.qryHistory.recordCount#
	</div>
	<table class="browseTable" style="width:100%">	
		<tr>
			<th>Date/Time</th>
			<th>Rule Name</th>
			<th>Application</th>
			<th>Host</th>
			<th>Message</th>
		</tr>
		<cfloop query="rs.qryHistory" startrow="#rs.startRow#" endrow="#endRow#">
			<cfset tmpEntryURL = "index.cfm?event=entry&entryID=#rs.qryHistory.EntryID#">
			<cfif rs.qryHistory.message eq "">
				<cfset tmpMessage = "<em>No message</em>">
			<cfelseif len(rs.qryHistory.message) gt 45>		
				<cfset tmpMessage = left(HtmlEditFormat(rs.qryHistory.message),45) & "...">
			<cfelse>
				<cfset tmpMessage = HtmlEditFormat(rs.qryHistory.message)>
			</cfif>
			<tr <cfif rs.qryHistory.currentRow mod 2>class="altRow"</cfif>>
				<td>#showDateTime(rs.qryHistory.createdOn)#</td>
				<td>#name#</td>
				<td>#application_code#</td>
				<td>#hostname#</td>
				<td><a href="#tmpEntryURL#">[#severity_code#] #tmpMessage#</a></td>
			</tr>
		</cfloop>
		<cfif rs.qryHistory.recordCount eq 0>
			<tr><td colspan="5"><em>No records found.</em></td></tr>
		</cfif>
	</table>

	<!--- Table Footer (paging controls) --->
	<div style="font-size:10px;line-height:20px;margin-top:10px;font-weight:bold;">
		<cfset pageURL = "index.cfm?event=extensions.main&panel=history">
		
		Page #currPage# of #numPages#
		&nbsp;&nbsp;&middot;&nbsp;&nbsp;

		<cfif numPages gt 1>
			<cfif currPage gt 1>
				<a href="#pageURL#&startRow=#(currPage-2)*rs.rowsPerPage+1#">Previous Page</a>
				&nbsp;&nbsp;
			</cfif>
			<cfif currPage lt numPages>
				<a href="#pageURL#&startRow=#(currPage)*rs.rowsPerPage+1#">Next Page</a>
				&nbsp;&nbsp;
			</cfif>
			&nbsp;&nbsp;&middot;&nbsp;&nbsp;
		</cfif>

		<cfif currPage - delta gt 0>... &nbsp;&nbsp;</cfif>
		<cfloop from="1" to="#numPages#" index="i">
			<cfif i gte currPage-delta and i lte currPage+delta>
				<cfif i eq currPage>
					<b>#i#</b>
				<cfelse>						
					<a href="#pageURL#&startRow=#(i-1)*rs.rowsPerPage+1#">#i#</a>
				</cfif>
				&nbsp;&nbsp;
			</cfif>
		</cfloop>
		<cfif currPage + delta lt numPages>... &nbsp;&nbsp;</cfif>
	</div>
</cfoutput>