<cfparam name="rs.event">
<cfparam name="rs.stInfo">
<cfparam name="rs.pageTitle" default="">
<cfset __eventPkg = listFirst(rs.event,".")>
<cfset __isAdmin = structKeyExists(rs,"currentUser") and rs.currentUser.getIsAdmin()>

<cfoutput>
	<table width="100%">
		<tr>	
			<td>
				<h2 class="pageTitle breakable">#rs.pageTitle#</h2>
				<div style="font-size:12px;">
					[ <a href="index.cfm?event=dashboard" <cfif rs.event eq "dashboard" or rs.event eq "dashboard">style="font-weight:bold;"</cfif>>Dashboard</a> ]
					&nbsp;&nbsp;&nbsp;
					[ <a href="index.cfm?event=main" <cfif rs.event eq "main" or rs.event eq "main">style="font-weight:bold;"</cfif>>Summary</a> ] 
					&nbsp;&nbsp;&nbsp;
					[ <a href="index.cfm?event=log" <cfif rs.event eq "log" or rs.event eq "log">style="font-weight:bold;"</cfif>>Detail</a> ] 
					&nbsp;&nbsp;&nbsp;
					[ <a href="index.cfm?event=extensions.main" <cfif __eventPkg eq "extensions">style="font-weight:bold;"</cfif>>Rules</a> ]
				</div>
			</td>
			<td align="right" width="300" style="font-size:13px;">
				<b>BugLogListener Service is: </b>
				<cfif rs.stInfo.isRunning>
					<span style="color:green;font-weight:bold;">Running</span>
					<cfif __isAdmin>
						<span style="font-size:12px;">(<a href="index.cfm?event=doStop&nextEvent=#rs.event#">Stop</a>)</span>
						<a href="index.cfm?event=serviceMonitor.main"><img src="#rs.assetsPath#images/icons/server_connect.png" border="0" align="absmiddle"></a>
					</cfif>
					<div style="font-size:9px;">
						<strong>Last Start:</strong> 
						#showDateTime(rs.stInfo.startedOn)#
					</div>
				<cfelse>
					<span style="color:red;font-weight:bold;">Stopped</span>
					<cfif __isAdmin>
						<span style="font-size:12px;">(<a href="index.cfm?event=doStart&nextEvent=#rs.event#">Start</a>)</span>
					</cfif>
				</cfif>
			</td>
		</tr>
	</table>	

</cfoutput>
