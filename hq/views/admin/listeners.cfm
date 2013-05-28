<cfset isAdmin = currentUser.getIsAdmin()>
<cfif rs.instanceName neq "default">
	<cfset bugLogListener.soap = "#rs.bugLogHREF#listener.cfc?wsdl">
	<cfset bugLogListener.rest = "#rs.bugLogHREF#listener.cfm">
	<cfset testhref.soap = "/bugLog/test/client.cfm?protocol=soap&instance=#rs.instanceName#&bugloghref=#rs.bugLogHREF#&returnTo=admin&apikey=#rs.apiKey#">
	<cfset testhref.rest = "/bugLog/test/client.cfm?protocol=rest&instance=#rs.instanceName#&bugloghref=#rs.bugLogHREF#&returnTo=admin&apikey=#rs.apiKey#">
<cfelse>
	<cfset bugLogListener.soap = "#rs.bugLogHREF#listeners/bugLogListenerWS.cfc?wsdl">
	<cfset bugLogListener.rest = "#rs.bugLogHREF#listeners/bugLogListenerREST.cfm">
	<cfset testhref.soap = rs.bugLogHREF & "test/client.cfm?protocol=soap&bugloghref=#rs.bugLogHREF#&returnTo=admin&apikey=#rs.apiKey#">
	<cfset testhref.rest = rs.bugLogHREF & "test/client.cfm?protocol=rest&bugloghref=#rs.bugLogHREF#&returnTo=admin&apikey=#rs.apiKey#">
</cfif>
<cfset bugLogListener.cfc = "bugLog.listeners.bugLogListenerWS">

<cfoutput>
	<h3>BugLog Listeners:</h3>
	<div style="margin-left:30px;line-height:24px;">
		You can use the following BugLog listeners for this server:<br /><br />
		
		<b>SOAP / Webservice:</b> <cfif isAdmin>( <a href="#testhref.soap#">Test</a> )</cfif><br />
		<a href="#bugLogListener.soap#">#bugLogListener.soap#</a><br /><br />
		
		<b>HTTP POST / REST:</b> <cfif isAdmin>( <a href="#testhref.rest#">Test</a> )</cfif><br />
		<a href="#bugLogListener.rest#">#bugLogListener.rest#</a><br /><br />
	</div>
</cfoutput>
