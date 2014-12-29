<cfsetting requesttimeout="120">    <!--- set request timeout to 120 seconds to minimize overlapping with the next scheduler run --->

<cfparam name="url.key" type="string" default="">
<cfparam name="url.instance" type="string" default="">

<!--- Handle service initialization if necessary --->
<cfset oService = createObject("component", "bugLog.components.service").init( instanceName = url.instance )>

<!--- process queue --->
<cfif oService.isRunning()>
    <cfset oBugLogListener = oService.getService()>
    <cfset oBugLogListener.processRules( url.key )>
</cfif>
