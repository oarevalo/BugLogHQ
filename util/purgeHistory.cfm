<cfparam name="instance" type="string" default="">

<!--- Handle service initialization if necessary --->
<cfset oService = createObject("component", "bugLog.components.service").init( instanceName = instance )>

<cfset oConfig = oService.getConfig()>
<cfset days = oConfig.getSetting("purging.numberOfDays")>
<cfset enabled = oConfig.getSetting("purging.enabled")>

<cfif isBoolean(enabled) and enabled>
	<cfdump var="Purging buglog history for records older than #days# days" output="console" />
	<cfset oAppService = createObject("component","bugLog.hq.components.services.appService").init(config = oConfig, instanceName = instance)>
	<cfset oAppService.purgeHistory(days) />
</cfif>
