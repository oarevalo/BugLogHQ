<cfparam name="key" type="string" default="">
<cfparam name="instance" type="string" default="">

<!--- Handle service initialization if necessary --->
<cfset oService = createObject("component", "bugLog.components.service").init( instanceName = instance )>

<!--- process queue --->
<cfif oService.isRunning()>
	<cfset oBugLogListener = oService.getService()>
	<cfset oBugLogListener.processQueue( key )>
</cfif>
