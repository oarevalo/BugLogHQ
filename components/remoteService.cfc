<cfcomponent>
	<!---
		remoteService.cfc
		
		This component allows controlling the bugLog listener service via a webservice. The primary goal is 
		to be used in tandem with the "Remote" listener (bugLogListenerRemote.cfc) so that the listening endpoints
		can be located on a separate machine than the buglog application.
		Remote control of a BugLog instance is disabled by default, to enable it make sure to set the value
		of "service.allowRemoteControl" to "true" in the BugLog config.
		
		oarevalo 3/2013 
	--->	
	
	<cffunction name="start" access="remote" returntype="boolean" hint="starts the listener service. returns true if started succesfully">
		<cfargument name="instanceName" type="string" required="true">
		<cfset var loader = getLoader(instanceName)>
		<cfset loader.start()>
		<cfreturn loader.isRunning()>
	</cffunction>

	<cffunction name="stop" access="remote" returntype="boolean" hint="starts the listener service. returns true if stopped succesfully">
		<cfargument name="instanceName" type="string" required="true">
		<cfset var loader = getLoader(instanceName)>
		<cfset loader.stop()>
		<cfreturn !loader.isRunning()>
	</cffunction>

	<cffunction name="getMessageLog" access="remote" returntype="array">
		<cfargument name="instanceName" type="string" required="true">
		<cfreturn getLoader(instanceName).getService().getMessageLog()>
	</cffunction>

	<cffunction name="getEntryQueue" access="remote" returntype="array">
		<cfargument name="instanceName" type="string" required="true">
		<cfset var queue = getLoader(instanceName).getService().getEntryQueue()>
		<cfset var response = []>
		<cfloop array="#queue#" index="i">
			<cfset arrayAppend(response, i.getMemento())>
		</cfloop>
		<cfdump var="#response#">
		<cfreturn response>
	</cffunction>

	<cffunction name="logMessage" access="remote" returntype="boolean">
		<cfargument name="instanceName" type="string" required="true">
		<cfargument name="message" type="string" required="true">
		<cfset getLoader(instanceName).getService().logMessage(arguments.message)>
		<cfreturn true>
	</cffunction>

	<cffunction name="processQueue" access="remote" returntype="numeric">
		<cfargument name="instanceName" type="string" required="true">
		<cfset var key = getLoader(instanceName).getService().getKey()>
		<cfreturn getLoader(instanceName).getService().processQueue(key)>
	</cffunction>

	<cffunction name="logEntry" access="remote" returntype="boolean">
		<cfargument name="instanceName" type="string" required="true">
		<cfargument name="entryBeanData" type="struct" required="true">
		<cfset var bean = createObject("rawEntryBean").setMemento(arguments.entryBeanData)>
		<cfset getLoader(instanceName).getService().logEntry(bean)>
		<cfreturn true>
	</cffunction>		

	<cffunction name="reloadRules" access="remote" returntype="boolean">
		<cfargument name="instanceName" type="string" required="true">
		<cfset getLoader(instanceName).getService().reloadRules()>
		<cfreturn true>
	</cffunction>		
	
	<cffunction name="getLoader" access="private" returntype="bugLog.components.service">
		<cfargument name="instanceName" type="string" required="true">
		<cfset var loader = createObject("component", "bugLog.components.service").init( instanceName = arguments.instanceName ) >
		<!--- make sure that remote control of service is enabled --->
		<cfif !loader.getConfig().getSetting("service.allowRemoteControl",false)>
			<cfthrow message="Remote control of service is not enabled">
		</cfif>
		<cfreturn loader>
	</cffunction>

</cfcomponent>