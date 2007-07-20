
<cfset bugLogListener = structNew()>
<cfset bugLogListener.soap = "http://#cgi.server_name#/bugLog/listeners/bugLogListenerWS.cfc?wsdl">
<cfset bugLogListener.rest = "http://#cgi.server_name#/bugLog/listeners/bugLogListenerREST.cfm">
<cfset bugLogListener.cfc = "bugLog.listeners.bugLogListenerWS">

<cfparam name="protocol" default="soap">
<cfparam name="pathToService" default="bugLog.client.bugLogService">
<cfparam name="reset" default="false">

<cfif not IsDefined("application.oBugLogService")>
	<cflock scope="application" timeout="5" type="exclusive">
		<cfif not IsDefined("application.oBugLogService")>
			<cfset application.oBugLogService = createObject("component",pathToService).init(bugLogListener[protocol])>
		</cfif>
	</cflock>
</cfif>

<cftry>
	<!--- throw an error --->
	<cfthrow message="Test message via #protocol#">	
	
	<cfcatch type="any">
		<cfset application.oBugLogService.notifyService(cfcatch.message, cfcatch)>
	</cfcatch>
</cftry>

<cfif reset>	
	<cfset structDelete(application, "oBugLogService")>
	Instance deleted.<br>
</cfif>

Done.
