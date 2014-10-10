<!--- client.cfm

	This template tests the client portion of bugLogHQ. It also serves as a sample
	of how to use the buglog client.

	URL Parameters:
		protocol: determines which buglog listener to use. values are cfc, soap and rest
		severity: type of error to send. Values are ERROR, FATAL, CRITICAL and INFO
--->

<cfparam name="protocol" default="rest">
<cfparam name="pathToService" default="bugLog.client.bugLogService">
<cfparam name="severity" default="FATAL">
<cfparam name="apikey" default="">
<cfparam name="instance" default="">
<cfparam name="bugLogHREF" default="">
<cfparam name="returnTo" default="">

<cfif bugLogHREF neq "">
	<cfset path = bugLogHREF>
<cfelse>
	<cfset path = "http://#cgi.HTTP_HOST#/bugLog/">
</cfif>

<cfset bugLogListener = structNew()>

<cfif instance neq "default" and instance neq "">
	<cfset bugLogListener.soap = "#path#listener.cfc?wsdl">
	<cfset bugLogListener.rest = "#path#listener.cfm">
	<cfset adminPath = "">
<cfelse>
	<cfset bugLogListener.soap = "#path#listeners/bugLogListenerWS.cfc?wsdl">
	<cfset bugLogListener.rest = "#path#listeners/bugLogListenerREST.cfm">
	<cfset adminPath = "hq/">
</cfif>

<cfoutput>
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

		<cfif returnTo eq "">
			<p><b style="color:red;">IMPORTANT:</b> <b>This test assumes that your bugLog instance is located on a directory named <u>/bugLog</u>. If
			you have deployed bugLog to a different directory you need to use the bugloghref URL parameter to indicate the full URL to
			the BugLog app.</b></p>
		</cfif>

		<!--- Initializing bugLog client instance --->
		Creating client instance... <br>
		... Listener type is: <b>#protocol#</b><br />
		... Listener is: <a href="#bugLogListener[protocol]#">#bugLogListener[protocol]#</a><br />
		<cfif apikey neq "">
		... Listener API Key is: <b>#apikey#</b><br />
		</cfif>
		<cfset oBugLogService = createObject("component",pathToService).init(bugLogListener = bugLogListener[protocol],
																			 apiKey = apiKey,
																			 sensitiveFieldNames = "password")>
		... Adding a checkpoint
		<cfset oBugLogService.checkpoint("BugLogHQ client created") />
		<br />

		<cftry>
			<!--- throw an error --->
			Throwing sample error message...<br>
			<cfset oBugLogService.checkpoint("About to throw an error...") />
			<cfthrow message="Test message via #protocol#">	
			
			<cfcatch type="any">
				<!--- notify bugLog of error --->
				Notify service via  <strong>[#protocol#]</strong> using severity <strong>[#severity#]</strong>....<br>

				<!--- create some sample additional info to include on the bug report --->
				<cfset extraInfo = { 
						username = "someone@testing.org",
						password = "1234568",
						credit_card = "4111111111111111",
						user_level = "visitor"
					} />
					
				<cfset oBugLogService.notifyService(cfcatch.message, cfcatch, extraInfo, severity)>
			</cfcatch>
		</cftry>
		
		<br>
		Done.
	
		<br /><br />
		
		<strong>Send test bug report via:</strong> 
		<cfloop collection="#bugLogListener#" item="key">
			<a href="client.cfm?protocol=#key#&instance=#instance#&bugloghref=#bugloghref#&returnTo=#returnTo#&apiKey=#apiKey#">#key#</a>
			&nbsp;|&nbsp;
		</cfloop>

		<br /><br />
	
		<cfif returnTo eq "admin">
			<a href="#path##adminPath#index.cfm?event=admin.main&panel=listeners">Return</a>
		<cfelse>
			<a href="index.cfm">Return</a>
		</cfif>
	</body>
</html>
</cfoutput>
