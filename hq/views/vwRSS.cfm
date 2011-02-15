<cfparam name="request.requestState.qryApplications" default="#queryNew('')#">
<cfparam name="request.requestState.qryHosts" default="#queryNew('')#">

<cfset qryApplications = request.requestState.qryApplications>
<cfset qryHosts = request.requestState.qryHosts>

<cfquery name="qryApplications" dbtype="query">
	SELECT * FROM qryApplications ORDER BY Code
</cfquery>
<cfquery name="qryHosts" dbtype="query">
	SELECT * FROM qryHosts ORDER BY hostname
</cfquery>

<cfscript>
	if(cgi.server_port_secure) thisHost = "https://"; else thisHost = "http://";
	thisHost = thisHost & cgi.server_name;
	if(cgi.server_port neq 80) thisHost = thisHost & ":" & cgi.server_port;
</cfscript>
<cfset rssFeedURL = "#thisHost##cgi.script_name#?event=ehRSS.dspRSS">

<cfquery name="qryApplications" dbtype="query">
	SELECT *, upper(code) as u_code
		FROM qryApplications
		ORDER BY u_code
</cfquery>

<cfquery name="qryHosts" dbtype="query">
	SELECT *, upper(HostName) as u_host
		FROM qryHosts
		ORDER BY u_host
</cfquery>

<cfoutput>
	<h2 style="margin-bottom:3px;">BugLog RSS Feeds</h2>
	<cfinclude template="../includes/menu.cfm">

	<br><br>
	
	<div style="font-size:14px;">
		<strong>Global RSS Feed:</strong>
		<ul>
			<li><a href="#rssFeedURL#" target="_blank">#rssFeedURL#</a></li>
		</ul>
		<br>
		
		<table class="browseTable" style="width:100%">
			<tr><th colspan="2" style="text-align:left">Application Feeds</th></tr>
			<cfloop query="qryApplications">
			<tr <cfif currentRow mod 2>class="altRow"</cfif>>
				<td style="width:100px;"><strong>#code#</strong></td>
				<td><a href="#rssFeedURL#&applicationID=#applicationID#">#rssFeedURL#&applicationID=#applicationID#</a></td>
			</tr>
			</cfloop>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr><th colspan="2" style="text-align:left">Host Feeds</th></tr>
			<cfloop query="qryHosts">
			<tr <cfif currentRow mod 2>class="altRow"</cfif>>
				<td style="width:100px;"><strong>#HostName#</strong></td>
				<td><a href="#rssFeedURL#&hostID=#hostID#">#rssFeedURL#&hostID=#hostID#</a></td>
			</tr>
			</cfloop>
		</table>
	</div>
</cfoutput>
