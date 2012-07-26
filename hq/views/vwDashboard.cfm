<cfset qryData = rs.qryData>
<cfset dateMask = rs.dateFormatMask>
<cfset applicationID = rs.applicationID>
<cfset hostID = rs.hostID>
<cfset numDays = rs.numDays>
<cfset qryApplications = rs.qryApplications>
<cfset qryHosts = rs.qryHosts>
<cfset qrySeverities = rs.qrySeverities>
<cfset severityID = rs.severityID>

<cfquery name="qryApplications" dbtype="query">
    SELECT applicationID, code as applicationCode, name FROM qryApplications ORDER BY code
</cfquery>

<cfquery name="qryHosts" dbtype="query">
    SELECT hostID, hostName FROM qryHosts ORDER BY hostName
</cfquery>

<cfquery name="qrySeverities" dbtype="query">
	SELECT severityID, name FROM qrySeverities ORDER BY name
</cfquery>

<cfsavecontent variable="tmpHead">
	<cfoutput>
		<cfif rs.refreshSeconds gt 0>
			<!-- refresh every X seconds -->
			<meta http-equiv="refresh" content="#rs.refreshSeconds#">
		</cfif>
		
		<script type="text/javascript">
			function doSearch() {
				var frm = document.frmSearch;
				frm.submit();
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
				<h2 style="margin-bottom:3px;">Dashboard</h2>
				<cfinclude template="../includes/menu.cfm">
			</td>
			<td align="right" width="300" style="font-size:13px;">
				<b>BugLogListener Service is: </b>
				<cfif rs.stInfo.isRunning>
					<span style="color:green;font-weight:bold;">Running</span>
					<span style="font-size:12px;">(<a href="index.cfm?event=ehGeneral.doStop">Stop</a>)</span>
					<a href="index.cfm?event=ehServiceMonitor.dspMain"><img src="#rs.assetsPath#images/icons/server_connect.png" border="0" align="absmiddle"></a>
					<div style="font-size:9px;">
						<strong>Last Start:</strong> 
						#lsdateformat(rs.stInfo.startedOn)# #lstimeformat(rs.stInfo.startedOn)#
					</div>
				<cfelse>
					<span style="color:red;font-weight:bold;">Stopped</span>
					<span style="font-size:12px;">(<a href="index.cfm?event=ehGeneral.doStart">Start</a>)</span>
				</cfif>
			</td>
		</tr>
	</table>	
	
	<!--- Search Criteria / Filters --->			
	<form name="frmSearch" action="index.cfm" method="get" style="margin:0px;padding-top:10px;">
		<input type="hidden" name="event" value="ehGeneral.dspDashboard">
		
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
					<span <cfif applicationID gt 0>style="color:red;"</cfif>>Application:</span> &nbsp;&nbsp;
					<select name="applicationID" style="width:200px;" onchange="doSearch()">
						<option value="0">All</option>
						<cfset tmp = applicationID>
						<cfset found = false>
						<cfloop query="qryApplications">
							<option value="#qryApplications.applicationID#" <cfif qryApplications.applicationID eq tmp>selected</cfif>>#qryApplications.applicationCode#</option>
							<cfif qryApplications.applicationID eq tmp>
								<cfset found = true>
							</cfif>
						</cfloop>
						<cfif applicationID gt 0 and not found>
							<option value="0" selected>No Match Found</option>
						</cfif>
					</select>
				</td>
				<td>
					<span <cfif hostID gt 0>style="color:red;"</cfif>>Host:</span> &nbsp;&nbsp;
					<select name="hostID" style="width:200px;" onchange="doSearch()">
						<option value="0">All</option>
						<cfset tmp = hostID>
						<cfset found = false>
						<cfloop query="qryHosts">
							<option value="#qryHosts.hostID#" <cfif qryHosts.hostID eq tmp>selected</cfif>>#qryHosts.hostName#</option>
							<cfif qryHosts.hostID eq tmp>
								<cfset found = true>
							</cfif>
						</cfloop>
						<cfif hostID gt 0 and not found>
							<option value="0" selected>No Match Found</option>
						</cfif>
					</select>
				</td>
			</tr>
			<tr>
				<td colspan="4" align="center">
					<span <cfif severityID neq "_ALL_">style="color:red;"</cfif>>Severity:</span> &nbsp;&nbsp;
					<cfset tmp = severityID>
					<cfloop query="qrySeverities">
						<cfset tmpImgName = "#rs.assetsPath#images/severity/#lcase(qrySeverities.name)#.png">
						<cfset tmpDefImgName = "#rs.assetsPath#images/severity/default.png">

						<input type="checkbox" 
								onclick="doSearch()"
								name="severityID" 
								value="#qrySeverities.severityID#"
								<cfif tmp eq "_ALL_" or listFind(tmp,qrySeverities.severityID)>checked</cfif>
								>
						<cfif fileExists(expandPath(tmpImgName))>
							<img src="#tmpImgName#" 
									alt="#lcase(qrySeverities.name)#" 
									title="#lcase(qrySeverities.name)#">
						<cfelse>
							<img src="#tmpDefImgName#" 
									alt="#lcase(qrySeverities.name)#" 
									title="#lcase(qrySeverities.name)#">
						</cfif>
						 #lcase(qrySeverities.name)#
						&nbsp;&nbsp;&nbsp;
					</cfloop>
				</td>
			</tr>
		</table>
	</form>	
	
	<!--- Dashboard --->
	<br />
	<cfinclude template="dashboard/bugs_by_severity.cfm">
	<br />
	<table width="100%" border="0">
		<tr valign="top">
			<td width="49%" align="center">
				<cfinclude template="dashboard/bugs_by_app_severity.cfm">
			</td>
			<td>&nbsp;</td>
			<td width="49%" align="center">
				<cfinclude template="dashboard/bugs_by_host.cfm">
			</td>
		</tr>
	</table>
	<br /><br />
	<cfinclude template="dashboard/bugs_by_msg.cfm">	
	
	<cfif rs.refreshSeconds gt 0>
		<p style="margin-top:10px;font-size:10px;">* Page will refresh automatically every #rs.refreshSeconds# seconds.</p>
	</cfif>	
</cfoutput>


<cffunction name="getSeverityIconURL" returntype="string">
	<cfargument name="severityCode" type="string" required="true">
	<cfset var tmpURL = "images/severity/#lcase(severityCode)#.png">
	<cfif not fileExists(expandPath(tmpURL))>
		<cfset tmpURL = "images/severity/default.png">
	<cfelse>
		<cfset tmpURL = "images/severity/#lcase(severityCode)#.png">
	</cfif>
	<cfreturn tmpURL>
</cffunction>
