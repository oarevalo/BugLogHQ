<!--- client.cfm

	This template tests the client portion of bugLogHQ. It also serves as a sample
	of how to use the buglog client.

	URL Parameters:
		protocol: determines which buglog listener to use. values are cfc, soap and rest
		severity: type of error to send. Values are ERROR, FATAL, CRITICAL and INFO
		reset: unloads the buglog client from memory after the test
--->

<cfset bugLogListener = structNew()>
<cfset bugLogListener.soap = "http://#cgi.HTTP_HOST#/bugLog/listeners/bugLogListenerWS.cfc?wsdl">
<cfset bugLogListener.rest = "http://#cgi.HTTP_HOST#/bugLog/listeners/bugLogListenerREST.cfm">
<cfset bugLogListener.cfc = "bugLog.listeners.bugLogListenerWS">

<cfparam name="protocol" default="cfc">
<cfparam name="pathToService" default="bugLog.client.bugLogService">
<cfparam name="severity" default="FATAL">
<cfparam name="reset" default="true">
<cfparam name="apikey" default="">

<html>
	<head>
		<style type="text/css">
			body {
				font-size:12px;
				font-family: "trebuchet MS", Arial, Helvetica, "Sans Serif";
				line-height:24px;
				margin:20px;
			}
		</style>
	</head>
	<body>
		<h1><span style="color:red;">BugLog</span>HQ: Test Client</h1>

		<!--- Load bugLog client into application scope (if needed) --->
		Checking if buglog client is in memory...<br>
		<cfif not IsDefined("application.oBugLogService") or reset>
			<cflock name="buglogservice" timeout="5" type="exclusive">
				<cfif not IsDefined("application.oBugLogService") or reset>
					BugLog client not loaded. Creating instance and loading into Application scope now... <br>
					<cfoutput>
						... Listener type is: <b>#protocol#</b><br />
						... Listener is: <a href="#bugLogListener[protocol]#">#bugLogListener[protocol]#</a><br />
						<cfif apikey neq "">
						... Listener API Key is: <b>#apikey#</b><br />
						</cfif>
					</cfoutput>
					<cfset application.oBugLogService = createObject("component",pathToService).init(bugLogListener = bugLogListener[protocol],
																									 apiKey = apiKey)>
				</cfif>
			</cflock>
		</cfif>

		<br />

		<cftry>
			<!--- throw an error --->
			Throwing sample error message...<br>
			<cfthrow message="Test message via #protocol#">	
			
			<cfcatch type="any">
				<!--- notify bugLog of error --->
				<cfoutput>Notify service via  <strong>[#protocol#]</strong> using severity <strong>[#severity#]</strong>....</cfoutput> <br>
				<cfset application.oBugLogService.notifyService(cfcatch.message, cfcatch, "", severity)>
			</cfcatch>
		</cftry>
		
		<cfif reset>	
			<!--- remove bugLog from application scope --->
			Removing bugLog client from memory...<br>
			<cfset structDelete(application, "oBugLogService")>
		</cfif>
		
		<br>
		Done.
	
		<br /><br />
		
		<strong>Send test bug report via:</strong> 
		<cfoutput>
			<cfloop collection="#bugLogListener#" item="key">
				<a href="client.cfm?protocol=#key#">#key#</a>
				&nbsp;|&nbsp;
			</cfloop>
		</cfoutput>

		<br /><br />

		<a href="index.cfm">Return</a>
	</body>
</html>

