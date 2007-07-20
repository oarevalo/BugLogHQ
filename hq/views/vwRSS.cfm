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

<cfset rssFeedURL = "http://#cgi.HTTP_HOST##cgi.script_name#?event=ehRSS.dspRSS">

<h2 style="margin-bottom:3px;">BugLog RSS Feeds</h2>
<cfinclude template="../includes/menu.cfm">

<cfoutput>

<br><br>

<div style="font-size:14px;">
<strong>General RSS Feed:</strong>
<ul>
	<li><a href="#rssFeedURL#" target="_blank">#rssFeedURL#</a></li>
</ul>
<br>
<b>Application Feeds:</b>
<ul>
 	<cfloop query="qryApplications">
		<li><b>#Code#: </b><a href="#rssFeedURL#&applicationID=#applicationID#">#rssFeedURL#&applicationID=#applicationID#</a></li>
	</cfloop>
</ul>

<b>Host Feeds:</b>
<ul>
	<cfloop query="qryHosts">
		<li><b>#HostName#: </b><a href="#rssFeedURL#&hostID=#hostID#">#rssFeedURL#&hostID=#hostID#</a></li>
	</cfloop>
</ul>

</div>
</cfoutput>
