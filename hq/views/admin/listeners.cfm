<cfif rs.instanceName neq "default">
	<cfset bugLogListener.soap = "#rs.bugLogHREF#listener.cfc?wsdl">
	<cfset bugLogListener.rest = "#rs.bugLogHREF#listener.cfm">
	<cfset testhref.soap = "/bugLog/test/client.cfm?protocol=soap&instance=#rs.instanceName#&bugloghref=#rs.bugLogHREF#&returnTo=admin&apikey=#rs.APIKey#">
	<cfset testhref.rest = "/bugLog/test/client.cfm?protocol=rest&instance=#rs.instanceName#&bugloghref=#rs.bugLogHREF#&returnTo=admin&apikey=#rs.APIKey#">
	<cfset testhref.cfc = "/bugLog/test/client.cfm?protocol=cfc&instance=#rs.instanceName#&bugloghref=#rs.bugLogHREF#&returnTo=admin&apikey=#rs.APIKey#">
<cfelse>
	<cfset bugLogListener.soap = "#rs.bugLogHREF#listeners/bugLogListenerWS.cfc?wsdl">
	<cfset bugLogListener.rest = "#rs.bugLogHREF#listeners/bugLogListenerREST.cfm">
	<cfset testhref.soap = rs.bugLogHREF & "test/client.cfm?protocol=soap&bugloghref=#rs.bugLogHREF#&returnTo=admin&apikey=#rs.APIKey#">
	<cfset testhref.rest = rs.bugLogHREF & "test/client.cfm?protocol=rest&bugloghref=#rs.bugLogHREF#&returnTo=admin&apikey=#rs.APIKey#">
	<cfset testhref.cfc = rs.bugLogHREF & "test/client.cfm?protocol=cfc&bugloghref=#rs.bugLogHREF#&returnTo=admin&apikey=#rs.APIKey#">
</cfif>
<cfset bugLogListener.cfc = "bugLog.listeners.bugLogListenerWS">

<cfoutput>
	<h3>BugLog Listeners:</h3>
	<div style="margin-left:30px;line-height:24px;">
		You can use the following BugLog listeners for this server:<br /><br />
		
		<b>SOAP / Webservice:</b> ( <a href="#testhref.soap#">Test</a> )<br />
		<a href="#bugLogListener.soap#">#bugLogListener.soap#</a><br /><br />
		
		<b>HTTP POST / REST:</b> ( <a href="#testhref.rest#">Test</a> )<br />
		<a href="#bugLogListener.rest#">#bugLogListener.rest#</a><br /><br />

		<b>CFC:</b> ( <a href="#testhref.cfc#">Test</a> )<br />
		<a href="##">#bugLogListener.cfc#</a>
	</div>
</cfoutput>
