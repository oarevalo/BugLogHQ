<!--- vwLog.cfm --->

<!--- values sent from the event handler --->
<cfparam name="request.requestState.stInfo" default="structNew()">
<cfparam name="request.requestState.qryEntries" default="#queryNew('')#">
<cfparam name="request.requestState.refreshSeconds" default="60">
<cfparam name="request.requestState.rowsPerPage" default="20">
<cfparam name="request.requestState.searchTerm" default="">
<cfparam name="request.requestState.applicationID" default="0">
<cfparam name="request.requestState.hostID" default="0">
<cfparam name="request.requestState.qryApplications" default="#queryNew('')#">
<cfparam name="request.requestState.qryHosts" default="#queryNew('')#">
<cfparam name="request.requestState.msgFromEntryID" default="">

<!--- page parameters used for paging records --->
<cfparam name="startRow" default="1">
<cfparam name="sortBy" default="mydatetime">
<cfparam name="sortDir" default="DESC">


<cfset stInfo = request.requestState.stInfo>
<cfset qryEntries = request.requestState.qryEntries>
<cfset rowsPerPage = request.requestState.rowsPerPage>
<cfset refreshSeconds = request.requestState.refreshSeconds>
<cfset lastbugread = request.requestState.lastbugread>
<cfset searchTerm = request.requestState.searchTerm>
<cfset applicationID = request.requestState.applicationID>
<cfset hostID = request.requestState.hostID>
<cfset qryApplications = request.requestState.qryApplications>
<cfset qryHosts = request.requestState.qryHosts>
<cfset msgFromEntryID = request.requestState.msgFromEntryID>
<cfset dateFormatMask = request.requestState.dateFormatMask>

<!--- base URL for reloading --->
<cfset pageURL = "index.cfm?event=log&applicationID=#applicationID#&hostID=#hostID#&searchTerm=#urlEncodedFormat(searchTerm)#&msgFromEntryID=#msgFromEntryID#">

<!--- setup variables for paging records --->
<cfset numPages = ceiling(qryEntries.recordCount / rowsPerPage)>
<cfset currPage = int(startRow/rowsPerPage)+1>
<cfset endRow = startRow+rowsPerPage-1>
<cfif endRow gt qryEntries.recordCount>
	<cfset endRow = qryEntries.recordCount>
</cfif>
<cfset delta = 5>


<!--- Handle sorting of data --->
<cfif sortBy neq "">
	<cfquery name="qryEntries" dbtype="query">
		SELECT *, UPPER(#sortBy#) AS SortField
			FROM qryEntries
			ORDER BY SortField #sortDir#
	</cfquery>
</cfif>
<cfif sortDir eq "ASC">
	<cfset imgSortDir = "#rs.assetsPath#images/icons/16-arrow-up.png">
	<cfset opSortDir = "DESC">
<cfelse>
	<cfset imgSortDir = "#rs.assetsPath#images/icons/16-arrow-down.png">
	<cfset opSortDir = "ASC">
</cfif>




<cfsavecontent variable="tmpHead">
	<cfoutput>
		<cfif refreshSeconds gt 0>
			<!-- refresh every X seconds -->
			<meta http-equiv="refresh" content="#refreshSeconds#">
		</cfif>
		
		<script type="text/javascript">
			function search(term, appID, hostID) {
				location.replace('index.cfm?event=log&applicationID='+appID+'&hostID='+hostID+'&searchTerm='+escape(term)+'&msgFromEntryID=#msgFromEntryID#');
			}
		</script>	
	</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#tmpHead#">



<cfoutput>
	<!--- Page headers --->			
	<cfinclude template="../includes/menu.cfm">
				
	<!--- Search Criteria / Filters --->			
	<form name="frmSearch" action="index.cfm" method="post" style="margin:0px;padding-top:10px;">
		<input type="hidden" name="event" value="log">
		<table  width="100%" class="criteriaTable" cellpadding="0" cellspacing="0">
			<tr align="center">
				<td>
					<span <cfif searchTerm neq "">style="color:red;"</cfif>>Search:</span> &nbsp;&nbsp;
					<input type="text" name="searchTerm" value="#htmlEditFormat(searchTerm)#" style="width:200px;" onchange="search(this.value,#applicationID#,#hostID#)">
				</td>
				<td>
					<span <cfif applicationID gt 0>style="color:red;"</cfif>>Application:</span> &nbsp;&nbsp;
					<select name="applicationID" style="width:200px;" onchange="search('#jsStringFormat(searchTerm)#',this.value,#hostID#)">
						<option value="0">All</option>
						<cfset tmp = applicationID>
						<cfloop query="qryApplications">
							<option value="#qryApplications.applicationID#" <cfif qryApplications.applicationID eq tmp>selected</cfif>>#qryApplications.applicationCode#</option>
						</cfloop>
					</select>
				</td>
				<td>
					<span <cfif hostID gt 0>style="color:red;"</cfif>>Host:</span> &nbsp;&nbsp;
					<select name="hostID" style="width:200px;" onchange="search('#jsStringFormat(searchTerm)#',#applicationID#,this.value)">
						<option value="0">All</option>
						<cfset tmp = hostID>
						<cfloop query="qryHosts">
							<option value="#qryHosts.hostID#" <cfif qryHosts.hostID eq tmp>selected</cfif>>#qryHosts.hostName#</option>
						</cfloop>
					</select>
				</td>
			</tr>
		</table>
	</form>



	<!--- Data table --->
	<div style="font-size:10px;line-height:20px;margin-top:10px;font-weight:bold;">
		Showing entries #startRow# - #endRow# of #qryEntries.recordCount#
	</div>
	<table class="browseTable" style="width:100%">	
		<tr>
			<th width="15" nowrap>&nbsp;</th>
			<th width="20" nowrap>
				<cfif sortBy eq "entryID">
					<a href="#pageURL#&sortBy=entryID&sortDir=#opSortDir#" title="Click to sort by bug ##">##</a>
					<img src="#imgSortDir#" align="absmiddle" border="0" style="text-decoration:none;" />
				<cfelse>
					<a href="#pageURL#&sortBy=entryID" title="Click to sort by bug ##">##</a>
				</cfif>
			</th>
			<th width="110">
				<cfif sortBy eq "mydateTime">
					<a href="#pageURL#&sortBy=mydateTime&sortDir=#opSortDir#" title="Click to sort by bug date/time">Date/Time</a>
					<img src="#imgSortDir#" align="absmiddle" border="0" style="text-decoration:none;" />
				<cfelse>
					<a href="#pageURL#&sortBy=mydateTime" title="Click to sort by bug date/time">Date/Time</a>
				</cfif>
			</th>
			<th width="120">
				<cfif sortBy eq "applicationCode">
					<a href="#pageURL#&sortBy=applicationCode&sortDir=#opSortDir#" title="Click to sort by application name">Application</a>
					<img src="#imgSortDir#" align="absmiddle" border="0" style="text-decoration:none;" />
				<cfelse>
					<a href="#pageURL#&sortBy=applicationCode" title="Click to sort by application name">Application</a>
				</cfif>
			</th>
			<th width="120">
				<cfif sortBy eq "hostName">
					<a href="#pageURL#&sortBy=hostName&sortDir=#opSortDir#" title="Click to sort by host name">Host</a>
					<img src="#imgSortDir#" align="absmiddle" border="0" style="text-decoration:none;" />
				<cfelse>
					<a href="#pageURL#&sortBy=hostName" title="Click to sort by host name">Host</a>
				</cfif>
			</th>
			<th>
				<cfif sortBy eq "message">
					<a href="#pageURL#&sortBy=message&sortDir=#opSortDir#" title="Click to sort by message">Message</a>
					<img src="#imgSortDir#" align="absmiddle" border="0" style="text-decoration:none;" />
				<cfelse>
					<a href="#pageURL#&sortBy=message" title="Click to sort by message">Message</a>
				</cfif>
			</th>
			<th width="10">&nbsp;</th>
		</tr>
	<cfloop query="qryEntries" startrow="#startRow#" endrow="#startRow+rowsPerPage-1#">
		<cfset isNew = qryEntries.entryID gt lastbugread>
		<cfset tmpRowClass = "row_app_" & replace(qryEntries.applicationCode," ","","ALL") & " "
							 & "row_host_" & replace(qryEntries.hostName," ","","ALL") & " "
						 	 & "row_sev_" & replace(qryEntries.SeverityCode," ","","ALL")>

		<tr class="#LCase(tmpRowClass)#<cfif qryEntries.currentRow mod 2> altRow</cfif>" <cfif isNew>style="font-weight:bold;"</cfif>>
			<td class="cell_severity" width="15" align="center" style="padding:0px;">
				<cfset tmpImgName = "images/severity/default.png">
				<cfif qryEntries.SeverityCode neq "">
					<cfif fileExists(expandPath("images/severity/#lcase(qryEntries.SeverityCode)#.png"))>
						<cfset tmpImgName = "images/severity/#lcase(qryEntries.SeverityCode)#.png">
					</cfif>
				</cfif>
				<img src="#rs.assetsPath##tmpImgName#" 
						align="absmiddle"
						alt="#lcase(qryEntries.SeverityCode)#" 
						title="#lcase(qryEntries.SeverityCode)#">
			</td>
			<td class="cell_entry" width="15">
				<a href="?event=entry&entryID=#qryEntries.entryID#" title="Click to view full details of bug">#qryEntries.entryID#</a>
			</td>
			<td class="cell_datetime" align="center" width="110">#DateFormat(qryEntries.createdOn,dateFormatMask)# #lsTimeFormat(qryEntries.createdOn)#</td>
			<td class="cell_application" width="120"><a href="index.cfm?event=log&applicationID=#qryEntries.applicationID#" title="Click to view all #qryEntries.applicationCode# bugs">#qryEntries.applicationCode#</a></td>
			<td class="cell_hostname" width="120"><a href="index.cfm?event=log&hostID=#qryEntries.hostID#" title="Click to view all bugs from #qryEntries.hostName#">#qryEntries.hostName#</a></td>
			<td class="cell_message" onclick="document.location='?event=entry&entryID=#qryEntries.entryID#'" 
				title="Click to view full details of bug"
				style="cursor:pointer;">#HtmlEditFormat(qryEntries.message)#</td>
			<td class="cell_details" align="center">
				<a href="?event=entry&entryID=#qryEntries.entryID#" title="Click to view full details of bug">
					<img alt="View details" width="16" height="16" src="#rs.assetsPath#images/icons/zoom.png" align="absmiddle" border="0" /></a>
			</td>
		</tr>
	</cfloop>
	<cfif qryEntries.recordCount eq 0>
		<td colspan="7"><em>No entries found.</em></td>
	</cfif>
	</table>
	
	
	
	<!--- Table Footer (paging controls) --->
	<div style="font-size:10px;line-height:20px;margin-top:10px;font-weight:bold;">
		<cfset pageURL = pageURL & "&sortBy=#sortBy#&sortDir=#sortDir#">
		
		Page #currPage# of #numPages#
		&nbsp;&nbsp;&middot;&nbsp;&nbsp;

		<cfif numPages gt 1>
			<cfif currPage gt 1>
				<a href="#pageURL#&startRow=#(currPage-2)*rowsPerPage+1#">Previous Page</a>
				&nbsp;&nbsp;
			</cfif>
			<cfif currPage lt numPages>
				<a href="#pageURL#&startRow=#(currPage)*rowsPerPage+1#">Next Page</a>
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
					<a href="#pageURL#&startRow=#(i-1)*rowsPerPage+1#">#i#</a>
				</cfif>
				&nbsp;&nbsp;
			</cfif>
		</cfloop>
		<cfif currPage + delta lt numPages>... &nbsp;&nbsp;</cfif>
	</div>
	
	<cfif refreshSeconds gt 0>
		<p style="margin-top:10px;font-size:10px;">* Page will refresh automatically every #refreshSeconds# seconds.</p>
	</cfif>
</cfoutput>

