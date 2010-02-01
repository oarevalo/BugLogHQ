<cfset bugLogListener.soap = "http://#cgi.HTTP_HOST#/bugLog/listeners/bugLogListenerWS.cfc?wsdl">
<cfset bugLogListener.rest = "http://#cgi.HTTP_HOST#/bugLog/listeners/bugLogListenerREST.cfm">
<cfset bugLogListener.cfc = "bugLog.listeners.bugLogListenerWS">

<cfoutput>
	<h3>Change Password:</h3>
	<div style="margin-left:30px;line-height:24px;">
		You can use the following BugLog listeners for this server:<br /><br />
		
		<b>SOAP / Webservice:</b><br />
		<a href="#bugLogListener.soap#">#bugLogListener.soap#</a><br /><br />
		
		<b>HTTP POST / REST:</b><br />
		<a href="#bugLogListener.rest#">#bugLogListener.rest#</a><br /><br />

		<b>CFC:</b><br />
		<a href="#bugLogListener.cfc#">#bugLogListener.cfc#</a>
	</div>
</cfoutput>
