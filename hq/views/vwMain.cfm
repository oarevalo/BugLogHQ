<!--- vwHome.cfm --->

<!--- values sent from the event handler --->
<cfparam name="request.requestState.stInfo" default="structNew()">
<cfparam name="request.requestState.qryEntries" default="#queryNew('')#">
<cfparam name="request.requestState.refreshSeconds" default="60">
<cfparam name="request.requestState.rowsPerPage" default="20">
<cfparam name="request.requestState.searchTerm" default="">
<cfparam name="request.requestState.applicationID" default="0">
<cfparam name="request.requestState.hostID" default="0">
<cfparam name="request.requestState.numDays" default="1">
<cfparam name="request.requestState.groupByApp" default="true">
<cfparam name="request.requestState.groupByHost" default="true">
<cfparam name="request.requestState.qryApplications" default="#queryNew('')#">
<cfparam name="request.requestState.qryHosts" default="#queryNew('')#">

<!--- page parameters used for paging records --->
<cfparam name="startRow" default="1">
<cfparam name="sortBy" default="">
<cfparam name="sortDir" default="ASC">

<cfset stInfo = request.requestState.stInfo>
<cfset qryEntries = request.requestState.qryEntries>
<cfset rowsPerPage = request.requestState.rowsPerPage>
<cfset refreshSeconds = request.requestState.refreshSeconds>
<cfset lastbugread = request.requestState.lastbugread>
<cfset searchTerm = request.requestState.searchTerm>
<cfset applicationID = request.requestState.applicationID>
<cfset hostID = request.requestState.hostID>
<cfset numDays = request.requestState.numDays>
<cfset groupByApp = request.requestState.groupByApp>
<cfset groupByHost = request.requestState.groupByHost>
<cfset qryApplications = request.requestState.qryApplications>
<cfset qryHosts = request.requestState.qryHosts>

<!--- base URL for reloading --->
<cfset pageURL = "index.cfm?event=ehGeneral.dspMain&applicationID=#applicationID#&hostID=#hostID#&searchTerm=#searchTerm#&groupByApp=#groupByApp#&groupByHost=#groupByHost#&numDays=#numDays#">

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
	<cfset imgSortDir = "images/icons/16-arrow-up.png">
	<cfset opSortDir = "DESC">
<cfelse>
	<cfset imgSortDir = "images/icons/16-arrow-down.png">
	<cfset opSortDir = "ASC">
</cfif>


<cfsavecontent variable="tmpHead">
	<cfoutput>
		<cfif refreshSeconds gt 0>
			<!-- refresh every X seconds -->
			<meta http-equiv="refresh" content="#refreshSeconds#">
		</cfif>
		
		<script type="text/javascript">
			function doSearch() {
				var frm = document.frmSearch;
				
				location.replace('index.cfm?event=ehGeneral.dspMain&applicationID='+frm.applicationID.value
									+'&hostID='+frm.hostID.value
									+'&searchTerm='+frm.searchTerm.value
									+'&groupByApp='+ document.getElementById("groupByApp").checked
									+'&groupByHost='+ document.getElementById("groupByHost").checked
									+"&numDays="+frm.numDays.value);
			}
		</script>	
	</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#tmpHead#">



<cfoutput>
	<!--- Page headers --->			
	<table width="100%">
		<tr>	
			<td>
				<h2 style="margin-bottom:3px;">Summary View</h2>
				<cfinclude template="../includes/menu.cfm">
			</td>
			<td align="right" width="300" style="font-size:13px;">
				<b>BugLogListener Service is: </b>
				<cfif stInfo.isRunning>
					<span style="color:green;font-weight:bold;">Running</span>
					<span style="font-size:12px;">(<a href="index.cfm?event=ehGeneral.doStop">Stop</a>)</span>
					<div style="font-size:9px;">
						<strong>Last Start:</strong> 
						#lsdateformat(stInfo.startedOn)# #lstimeformat(stInfo.startedOn)#
					</div>
				<cfelse>
					<span style="color:red;font-weight:bold;">Stopped</span>
					<span style="font-size:12px;">(<a href="index.cfm?event=ehGeneral.doStart">Start</a>)</span>
				</cfif>
			</td>
		</tr>
	</table>	
				
				
	<!--- Search Criteria / Filters --->			
	<form name="frmSearch" action="index.cfm" method="post" style="margin:0px;padding-top:10px;">
		<table  width="100%" class="criteriaTable" cellpadding="0" cellspacing="0">
			<tr align="center">
				<td>
					Show for last: &nbsp;&nbsp;
					<select name="numDays" style="width:100px;" onchange="doSearch()">
						<option value="1" <cfif numDays eq 1>selected</cfif>>24 hours</option>
						<option value="7" <cfif numDays eq 7>selected</cfif>>7 days</option>
						<option value="30" <cfif numDays eq 30>selected</cfif>>30 days</option>
						<option value="60" <cfif numDays eq 60>selected</cfif>>60 days</option>
						<option value="120" <cfif numDays eq 120>selected</cfif>>120 days</option>
						<option value="360" <cfif numDays eq 360>selected</cfif>>360 days</option>
					</select>				
				</td>
				<td>
					<span <cfif searchTerm neq "">style="color:red;"</cfif>>Search:</span> &nbsp;&nbsp;
					<input type="text" name="searchTerm" value="#searchTerm#" style="width:200px;" onchange="doSearch()">
				</td>
				<td>
					<span <cfif applicationID gt 0>style="color:red;"</cfif>>Application:</span> &nbsp;&nbsp;
					<select name="applicationID" style="width:200px;" onchange="doSearch()">
						<option value="0">All</option>
						<cfset tmp = applicationID>
						<cfloop query="qryApplications">
							<option value="#qryApplications.applicationID#" <cfif qryApplications.applicationID eq tmp>selected</cfif>>#qryApplications.applicationCode#</option>
						</cfloop>
					</select>
				</td>
				<td>
					<span <cfif hostID gt 0>style="color:red;"</cfif>>Host:</span> &nbsp;&nbsp;
					<select name="hostID" style="width:200px;" onchange="doSearch()">
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
			<th width="120">
				<input type="checkbox" name="groupByApp" id="groupByApp" value="1" <cfif groupByApp>checked</cfif> onclick="doSearch()" title="Breakdown bugs by application name">
				<cfif sortBy eq "applicationCode">
					<a href="#pageURL#&sortBy=applicationCode&sortDir=#opSortDir#" title="Click to sort by application name">Application</a>
					<img src="#imgSortDir#" align="absmiddle" border="0" style="text-decoration:none;" />
				<cfelse>
					<a href="#pageURL#&sortBy=applicationCode" title="Click to sort by application name">Application</a>
				</cfif>
			</th>
			<th width="120">
				<input type="checkbox" name="groupByHost" id="groupByHost" value="1" <cfif groupByHost>checked</cfif> onclick="doSearch()" title="Breakdown bugs by host name">
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
			<th width="60">
				<cfif sortBy eq "bugCount">
					<a href="#pageURL#&sortBy=bugCount&sortDir=#opSortDir#" title="Click to sort by message">Count</a>
					<img src="#imgSortDir#" align="absmiddle" border="0" style="text-decoration:none;" />
				<cfelse>
					<a href="#pageURL#&sortBy=bugCount" title="Click to sort by number of bugs">Count</a>
				</cfif>
			</th>
			<th width="110">
				<cfif sortBy eq "createdOn">
					<a href="#pageURL#&sortBy=createdOn&sortDir=#opSortDir#" title="Click to sort by bug date/time">Most Recent</a>
					<img src="#imgSortDir#" align="absmiddle" border="0" style="text-decoration:none;" />
				<cfelse>
					<a href="#pageURL#&sortBy=createdOn" title="Click to sort by bug date/time">Most Recent</a>
				</cfif>
			</th>
			<th width="10">&nbsp;</th>
		</tr>
	<cfloop query="qryEntries" startrow="#startRow#" endrow="#startRow+rowsPerPage-1#">
		<cfset isNew = qryEntries.entryID gt lastbugread>
		<cfif bugCount gt 1>
		<!--- 	<cfset zoomURL = "index.cfm?event=ehGeneral.dspLog&searchTerm=#urlencodedformat(qryEntries.message)#"> --->
			<cfset zoomURL = "index.cfm?event=ehGeneral.dspLog&msgFromEntryID=#qryEntries.entryID#">
			<cfif groupByApp>
				<Cfset zoomURL = zoomURL & "&ApplicationID=#qryEntries.applicationID#">
			</cfif>		
			<cfif groupByHost>
				<Cfset zoomURL = zoomURL & "&HostID=#qryEntries.HostID#">
			</cfif>		
		<cfelse>
			<cfset zoomURL = "?event=ehGeneral.dspEntry&entryID=#qryEntries.entryID#">
		</cfif>
		
		<tr <cfif qryEntries.currentRow mod 2>class="altRow"</cfif> <cfif isNew>style="font-weight:bold;"</cfif>>
			<td width="15" align="center" style="padding:0px;">
				<cfif qryEntries.SeverityCode neq "">
					<img src="images/severity/#lcase(qryEntries.SeverityCode)#.png" 
							align="absmiddle"
							alt="#lcase(qryEntries.SeverityCode)#" 
							title="#lcase(qryEntries.SeverityCode)#">
				</cfif>
			</td>
			<td width="120">
				<cfif groupByApp>
					<a href="index.cfm?event=ehGeneral.dspMain&applicationID=#qryEntries.applicationID#" title="Click to view all #qryEntries.applicationCode# bugs">#qryEntries.applicationCode#</a>
				</cfif>
			</td>	
			<td width="120">
				<cfif groupByHost>
					<a href="index.cfm?event=ehGeneral.dspMain&hostID=#qryEntries.hostID#" title="Click to view all bugs from #qryEntries.hostName#">#qryEntries.hostName#</a>
				</cfif>	
			</td>
			<td onclick="document.location='#zoomURL#'" 
				title="Click for more details"
				style="cursor:pointer;">#qryEntries.message#</td>
			<td width="60" align="right">
				#qryEntries.bugCount#
			</td>
			<td align="center" width="140">
				<a href="?event=ehGeneral.dspEntry&entryID=#qryEntries.entryID#" title="Click to view full details of bug">#DateFormat(qryEntries.createdOn,'mm/dd/yy')# #lsTimeFormat(qryEntries.createdOn)#</a>)
			</td>
			<td align="center">
				<a href="#zoomURL#" title="Click for more detail">
					<img alt="View details" width="16" height="16" src="images/icons/zoom.png" align="absmiddle" border="0" /></a>
			</td>
		</tr>
	</cfloop>
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

