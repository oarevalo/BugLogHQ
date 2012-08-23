<!--- vwHome.cfm --->

<!--- page parameters used for paging records --->
<cfparam name="startRow" default="1">

<cfset qryEntries = rs.qryEntries>
<cfset rowsPerPage = rs.rowsPerPage>
<cfset refreshSeconds = rs.refreshSeconds>
<cfset lastbugread = rs.lastbugread>
<cfset dateFormatMask = rs.dateFormatMask>
<cfset assetsPath = rs.assetsPath>

<cfset groupByApp = rs.criteria.groupByApp>
<cfset groupByHost = rs.criteria.groupByHost>
<cfset sortBy = rs.criteria.sortBy>
<cfset sortDir = rs.criteria.sortDir>

<cfif sortBy eq "">
	<cfset sortBy = "createdOn">
	<cfset sortDir = "DESC">
</cfif>

<!--- base URL for reloading --->
<cfset pageURL = "index.cfm?event=main">

<!--- setup variables for paging records --->
<cfset numPages = ceiling(qryEntries.recordCount / rowsPerPage)>
<cfset currPage = int(startRow/rowsPerPage)+1>
<cfset endRow = startRow+rowsPerPage-1>
<cfif endRow gt qryEntries.recordCount>
	<cfset endRow = qryEntries.recordCount>
</cfif>
<cfset delta = 5>

<!--- Handle sorting of data --->
<cfif sortBy eq "hostName" and not rs.criteria.groupByHost>
	<cfset sortBy = "createdOn">
</cfif>
<cfif sortBy eq "applicationCode" and not rs.criteria.groupByApp>
	<cfset sortBy = "createdOn">
</cfif>
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
	</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#tmpHead#">



<cfoutput>
	<!--- Page headers --->			
	<cfinclude template="../includes/menu.cfm">
				
				
	<!--- Search Criteria / Filters --->			
	<cfinclude template="../includes/filters.cfm">


	<!--- Data table --->
	<div style="float:right;">
		<a href="#rs.criteria.rssurl#&summary=true" target="_blank" title="Link to RSS feed for the current search criteria"><b>rss</b></a>
		<a href="#rs.criteria.rssurl#&summary=true" target="_blank" title="Link to RSS feed for the current search criteria"><img alt="RSS" width="16" height="16" src="#rs.assetsPath#images/icons/feed-icon16x16.gif" border="0" align="absmiddle"/></a>
	</div>
	<div style="font-size:10px;line-height:20px;margin-top:10px;font-weight:bold;">
		Showing entries #startRow# - #endRow# of #qryEntries.recordCount#
	</div>
	<table class="browseTable" style="width:100%">	
		<tr>
			<th width="15" nowrap>&nbsp;</th>
			<th width="120">
				<input type="checkbox" name="groupByApp" id="groupByApp" value="1" <cfif groupByApp>checked</cfif> class="searchCheckbox" title="Breakdown bugs by application name">
				<cfif sortBy eq "applicationCode">
					<a href="#pageURL#&sortBy=applicationCode&sortDir=#opSortDir#" title="Click to sort by application name">Application</a>
					<img src="#imgSortDir#" align="absmiddle" border="0" style="text-decoration:none;" />
				<cfelse>
					<a href="#pageURL#&sortBy=applicationCode" title="Click to sort by application name">Application</a>
				</cfif>
			</th>
			<th width="120">
				<input type="checkbox" name="groupByHost" id="groupByHost" value="1" <cfif groupByHost>checked</cfif> class="searchCheckbox"  title="Breakdown bugs by host name">
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
		<cfif !structKeyExists(qryEntries,"bugCount")>
			<cfset bugCount = 1>
		</cfif>
		<cfif bugCount gt 1>
			<cfset zoomURL = "index.cfm?event=log&msgFromEntryID=#qryEntries.entryID#">
			<cfif groupByApp>
				<Cfset zoomURL = zoomURL & "&ApplicationID=#qryEntries.applicationID#">
			</cfif>		
			<cfif groupByHost>
				<Cfset zoomURL = zoomURL & "&HostID=#qryEntries.HostID#">
			</cfif>		
		<cfelse>
			<cfset zoomURL = "?event=entry&entryID=#qryEntries.entryID#">
		</cfif>

		<cfset tmpRowClass = "">		
		<cfif structKeyExists(qryEntries,"applicationCode")>
			<cfset tmpRowClass = tmpRowClass & "row_app_" & replace(qryEntries.applicationCode," ","","ALL") & " ">
		</cfif>
		<cfif structKeyExists(qryEntries,"hostName")>
			<cfset tmpRowClass = tmpRowClass & "row_host_" & replace(qryEntries.hostName," ","","ALL") & " ">
		</cfif>
		<cfset tmpRowClass = tmpRowClass & "row_sev_" & replace(qryEntries.SeverityCode," ","","ALL")>
		
		<cfif qryEntries.message eq "">
			<cfset tmpMessage = "<em>No message</em>">
		<cfelse>		
			<cfset tmpMessage = HtmlEditFormat(qryEntries.message)>
		</cfif>
		
		<tr class="#LCase(tmpRowClass)#<cfif qryEntries.currentRow mod 2> altRow</cfif>" <cfif isNew>style="font-weight:bold;"</cfif>>
			<td class="cell_severity" width="15" align="center" style="padding:0px;">
				<cfset tmpImgName = "images/severity/default.png">
				<cfif qryEntries.SeverityCode neq "">
					<cfif fileExists(expandPath("images/severity/#lcase(qryEntries.SeverityCode)#.png"))>
						<cfset tmpImgName = "images/severity/#lcase(qryEntries.SeverityCode)#.png">
					</cfif>
				</cfif>
				<a href="index.cfm?event=log&severityID=#qryEntries.SeverityCode#" 
					title="Click to view all #qryEntries.SeverityCode# bugs"><img 
						src="#rs.assetsPath##tmpImgName#" 
						align="absmiddle"
						alt="#lcase(qryEntries.SeverityCode)#" 
						title="#lcase(qryEntries.SeverityCode)#"
						border="0"></a>
			</td>
			<td class="cell_application" width="120">
				<cfif groupByApp>
					<a href="index.cfm?event=log&applicationID=#qryEntries.applicationID#" title="Click to view all #qryEntries.applicationCode# bugs">#qryEntries.applicationCode#</a>
				</cfif>
			</td>
			<td class="cell_hostname" width="120">
				<cfif groupByHost>
					<a href="index.cfm?event=log&hostID=#qryEntries.hostID#" title="Click to view all bugs from #qryEntries.hostName#">#qryEntries.hostName#</a>
				</cfif>	
			</td>
			<td class="cell_message" rel="#zoomURL#" title="Click for more details">#tmpMessage#</td>
			<td class="cell_count" width="60" align="right">
				#bugCount#
			</td>
			<td class="cell_mostrecent" align="center" width="140">
				<a href="?event=entry&entryID=#qryEntries.entryID#" title="Click to view full details of bug">#DateFormat(qryEntries.createdOn,dateFormatMask)# #lsTimeFormat(qryEntries.createdOn)#</a>)
			</td>
			<td class="cell_details" align="center">
				<a href="#zoomURL#" title="Click for more detail">
					<img alt="View details" width="16" height="16" src="#rs.assetsPath#images/icons/zoom.png" align="absmiddle" border="0" /></a>
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

