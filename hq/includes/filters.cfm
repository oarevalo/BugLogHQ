<cfparam name="rs.qryApplications" default="#queryNew('')#">
<cfparam name="rs.qryHosts" default="#queryNew('')#">
<cfparam name="rs.qrySeverities" default="#queryNew('')#">
<cfparam name="rs.criteria" default="#structNew()#">

<cfset times = [
				{value="0.0417", label="1 hour"},
				{value="0.125", label="3 hours"},
				{value="0.25", label="6 hours"},
				{value="0.5", label="12 hours"},
				{value="1", label="24 hours"},
				{value="7", label="7 days"},
				{value="30", label="30 days"},
				{value="60", label="60 days"},
				{value="120", label="120 days"},
				{value="360", label="360 days"}
			]>

<cfif rs.criteria.groupByApp>
	<cfquery name="qryApplicationsCurrent" dbtype="query">
		SELECT DISTINCT applicationID, applicationCode as code
			FROM rs.qryEntries
			ORDER BY applicationCode
	</cfquery>
<cfelse>
	<cfset qryApplicationsCurrent = queryNew("")>
</cfif>

<cfif rs.criteria.groupByHost>
	<cfquery name="qryHostsCurrent" dbtype="query">
		SELECT DISTINCT hostID, hostName
			FROM rs.qryEntries
			ORDER BY hostName
	</cfquery>
<cfelse>
	<cfset qryHostsCurrent = queryNew("")>
</cfif>

<cfoutput>
	<form name="frmSearch" id="frmSearch" action="index.cfm" method="get" style="margin:0px;padding-top:10px;" class="form-inline">
		<input type="hidden" name="groupByApp" value="#rs.criteria.groupByApp#">
		<input type="hidden" name="groupByHost" value="#rs.criteria.groupByHost#">
		<input type="hidden" name="event" value="#rs.event#" id="currentEvent">
		
		<table  width="100%" class="well" cellpadding="0" cellspacing="0">
			<tr align="center">
				<td style="padding-top:5px;">
					Show for last: &nbsp;&nbsp;
					<select name="numDays" style="width:100px;" class="searchSelector">
						<cfloop array="#times#" index="item">
							<option value="#item.value#" <cfif rs.criteria.numDays eq item.value>selected</cfif>>#item.label#</option>
						</cfloop>
					</select>				
				</td>
				<td style="padding-top:5px;">
					<span <cfif rs.criteria.searchTerm neq "">style="color:red;"</cfif>>Search:</span> &nbsp;&nbsp;
					<input type="text" name="searchTerm" value="#rs.criteria.searchTerm#" style="width:200px;" class="searchSelector">

				</td>
				<td style="padding-top:5px;">
					<span <cfif rs.criteria.applicationID gt 0>style="color:red;"</cfif>>Application:</span> &nbsp;&nbsp;
					<select name="applicationID" style="width:200px;" class="searchSelector">
						<option value="0">All</option>
						<cfset found = false>
						<cfloop query="qryApplicationsCurrent">
							<cfset isSelected = (qryApplicationsCurrent.applicationID eq rs.criteria.applicationID or qryApplicationsCurrent.code eq rs.criteria.applicationID)>
							<option value="#qryApplicationsCurrent.applicationid#"  <cfif isSelected>selected</cfif>>#qryApplicationsCurrent.code#</option>
							<cfif isSelected>
								<cfset found = true>
							</cfif>
						</cfloop>
						<cfif rs.criteria.applicationID gt 0 and not found>
							<option value="0" selected>No Match Found</option>
						</cfif>
					</select>
				</td>
				<td style="padding-top:5px;">
					<span <cfif rs.criteria.hostID gt 0>style="color:red;"</cfif>>Host:</span> &nbsp;&nbsp;
					<select name="hostID" style="width:200px;" class="searchSelector">
						<option value="0">All</option>
						<cfset found = false>
						<cfloop query="qryHostsCurrent">
							<cfset isSelected = (qryHostsCurrent.hostID eq rs.criteria.hostID or qryHostsCurrent.hostName eq rs.criteria.hostID)>
							<option value="#qryHostsCurrent.hostID#"  <cfif isSelected>selected</cfif>>#qryHostsCurrent.hostName#</option>
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
				<td>&nbsp;</td>
				<td style="text-align:center;">
					<label style="font-size:11px;">
						<input type="checkbox" 
								name="searchHTMLReport" 
								value="true"
								class="searchCheckbox" 
								<cfif rs.criteria.searchHTMLReport>checked</cfif>>
						Search HTML Report content
					</label>				
				</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td colspan="4" align="center">
					<div style="float:right;margin-right:10px;font-size:10px;">
						<a href="index.cfm?event=#rs.event#&resetCriteria=1">Reset</a>
						&nbsp;|&nbsp;
						<a href="#rs.criteria.url#" title="Generate a link with the full search criteria on this page"><img src="#rs.assetsPath#/images/icons/link.png"></a>
					</div>
					<div class="control-group">
					<span <cfif rs.criteria.severityID neq "_ALL_">style="color:red;"</cfif>>Severity:</span> &nbsp;&nbsp;
					<cfloop query="rs.qrySeverities">
						<cfset tmpImgName = "#rs.assetsPath#images/severity/#lcase(rs.qrySeverities.name)#.png">
						<cfset tmpDefImgName = "#rs.assetsPath#images/severity/default.png">

						<label class="inline">
							<input type="checkbox" 
									class="searchSeverityCheckbox"
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
					</div>
				</td>
			</tr>
		</table>
	</form>
</cfoutput>