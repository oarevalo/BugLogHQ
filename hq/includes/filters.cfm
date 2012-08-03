<cfparam name="rs.qryApplications" default="#queryNew('')#">
<cfparam name="rs.qryHosts" default="#queryNew('')#">
<cfparam name="rs.qrySeverities" default="#queryNew('')#">
<cfparam name="rs.criteria" default="#structNew()#">

<cfset times = [
				{value="1", label="24 hours"},
				{value="7", label="7 days"},
				{value="30", label="30 days"},
				{value="60", label="60 days"},
				{value="120", label="120 days"},
				{value="360", label="360 days"}
			]>

<cfoutput>
	<form name="frmSearch" action="index.cfm" method="get" style="margin:0px;padding-top:10px;">
		<input type="hidden" name="groupByApp" value="#rs.criteria.groupByApp#">
		<input type="hidden" name="groupByHost" value="#rs.criteria.groupByHost#">
		<input type="hidden" name="searchHTMLReport" value="#rs.criteria.searchHTMLReport#">
		<input type="hidden" name="event" value="#rs.event#">
		
		<table  width="100%" class="criteriaTable" cellpadding="0" cellspacing="0">
			<tr align="center">
				<td>
					Show for last: &nbsp;&nbsp;
					<select name="numDays" style="width:100px;" onchange="doSearch()">
						<cfloop array="#times#" index="item">
							<option value="#item.value#" <cfif rs.criteria.numDays eq item.value>selected</cfif>>#item.label#</option>
						</cfloop>
					</select>				
				</td>
				<td>
					<span <cfif rs.criteria.searchTerm neq "">style="color:red;"</cfif>>Search:</span> &nbsp;&nbsp;
					<input type="text" name="searchTerm" value="#rs.criteria.searchTerm#" style="width:200px;" onchange="doSearch()">
					<div style="font-size:10p;">
						<label>
							<input type="checkbox" 
									name="searchHTMLReportChk" 
									id="searchHTMLReportChk" 
									value="true"
									onclick="doSearch()" 
									<cfif rs.criteria.searchHTMLReport>checked</cfif>>
							Search HTML Report content
						</label>
					</div>
				</td>
				<td>
					<span <cfif rs.criteria.applicationID gt 0>style="color:red;"</cfif>>Application:</span> &nbsp;&nbsp;
					<select name="applicationID" style="width:200px;" onchange="doSearch()">
						<option value="0">All</option>
						<cfset found = false>
						<cfloop query="rs.qryApplications">
							<cfset isSelected = (rs.qryApplications.applicationID eq rs.criteria.applicationID or rs.qryApplications.code eq rs.criteria.applicationID)>
							<option value="#rs.qryApplications.applicationID#" <cfif isSelected>selected</cfif>>#rs.qryApplications.code#</option>
							<cfif isSelected>
								<cfset found = true>
							</cfif>
						</cfloop>
						<cfif rs.criteria.applicationID gt 0 and not found>
							<option value="0" selected>No Match Found</option>
						</cfif>
					</select>
				</td>
				<td>
					<span <cfif rs.criteria.hostID gt 0>style="color:red;"</cfif>>Host:</span> &nbsp;&nbsp;
					<select name="hostID" style="width:200px;" onchange="doSearch()">
						<option value="0">All</option>
						<cfset found = false>
						<cfloop query="rs.qryHosts">
							<cfset isSelected = (rs.qryHosts.hostID eq rs.criteria.hostID or rs.qryHosts.hostName eq rs.criteria.hostID)>
							<option value="#rs.qryHosts.hostID#" <cfif isSelected>selected</cfif>>#rs.qryHosts.hostName#</option>
							<cfif isSelected>
								<cfset found = true>
							</cfif>
						</cfloop>
						<cfif rs.criteria.hostID gt 0 and not found>
							<option value="0" selected>No Match Found</option>
						</cfif>
					</select>
				</td>
			</tr>
			<tr>
				<td colspan="4" align="center">
					<span <cfif rs.criteria.severityID neq "_ALL_">style="color:red;"</cfif>>Severity:</span> &nbsp;&nbsp;
					<cfloop query="rs.qrySeverities">
						<cfset tmpImgName = "#rs.assetsPath#images/severity/#lcase(rs.qrySeverities.name)#.png">
						<cfset tmpDefImgName = "#rs.assetsPath#images/severity/default.png">

						<label>
							<input type="checkbox" 
									onclick="doSearch()"
									name="severityID" 
									value="#rs.qrySeverities.severityID#"
									<cfif rs.criteria.severityID eq "_ALL_" or listFind(rs.criteria.severityID, rs.qrySeverities.severityID)>checked</cfif>
									>
							<cfif fileExists(expandPath(tmpImgName))>
								<img src="#tmpImgName#" 
										alt="#lcase(rs.qrySeverities.name)#" 
										title="#lcase(rs.qrySeverities.name)#">
							<cfelse>
								<img src="#tmpDefImgName#" 
										alt="#lcase(rs.qrySeverities.name)#" 
										title="#lcase(rs.qrySeverities.name)#">
							</cfif>
							 #lcase(rs.qrySeverities.name)#
						</label>
						&nbsp;&nbsp;&nbsp;
					</cfloop>
				</td>
			</tr>
		</table>
	</form>
</cfoutput>