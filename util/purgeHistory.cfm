<cfset oConfig = createObject("component","bugLog.components.config").init(configProviderType = "xml", 
																			configDoc = "/bugLog/config/buglog-config.xml.cfm")>

<cfset oAppService = createObject("component","bugLog.hq.components.services.appService").init("/bugLog", oConfig)>

<cfset days = oConfig.getSetting("purging.numberOfDays")>
<cfset enabled = oConfig.getSetting("purging.enabled")>

<cfif isBoolean(enabled) and enabled>
	<cfdump var="Purging buglog history for records older than #days# days" output="console" />
	<cfset oAppService.purgeHistory(days) />
</cfif>
