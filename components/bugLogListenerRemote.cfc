<cfcomponent extends="bugLogListener" hint="This listener acts as a proxy to a listener executing on a separate machine">
	<!---
		bugLogListenerRemote.cfc
		
		Use this listener to create a distributed environment in which the Listeners execute on a 
		separate location than the rest of the buglog application. 
		Communication with the remote listener is done via SOAP calls to remoteService.cfc
		For this approach to work, both local and remote buglogs must be connected to the same database.

		To use this listener, use the following settings on the local config:
			service.serviceCFC : "bugLog.components.bugLogListenerRemote"
			service.remote.wsdl : "http://{remote server}/bugLog/components/remoteService.cfc?wsdl"
			service.remote.instance : The instance name to connect on the remote side (i.e. "default")
		
		On the receiving end, the setting "service.allowRemoteControl" must be set to True.
		
		oarevalo 3/2013 
	--->	

	<cfset variables.remoteWSDL = "">
	<cfset variables.remoteInstance = "">
	<cfset variables.instanceName = "">

	<!--- Constructor --->

	<cffunction name="init" access="public" returntype="bugLogListenerRemote">
		<cfargument name="config" required="true" type="config">
		<cfargument name="instanceName" type="string" required="true">
		<cfset variables.remoteWSDL = arguments.config.getSetting("service.remote.wsdl")>
		<cfset variables.remoteInstance = arguments.config.getSetting("service.remote.instance", arguments.instanceName)>
		<cfset variables.instanceName = arguments.instanceName>
		<cfset var ok = getRemoteService().start(variables.remoteInstance)>
		<cfif !ok>
			<cfthrow message="Remote listener service could not be started">
		</cfif>
		<cfreturn this />
	</cffunction>


	<!--- Public Methods --->
	
	<cffunction name="shutDown" access="public" returntype="void">
		<cfset var ok = getRemoteService().stop(variables.remoteInstance)>
		<cfif !ok>
			<cfthrow message="Remote listener service could not be stopped">
		</cfif>
	</cffunction>	

	<cffunction name="getMessageLog" access="public" returntype="array">
		<cfreturn getRemoteService().getMessageLog(variables.remoteInstance)>
	</cffunction>

	<cffunction name="getEntryQueue" access="public" returntype="array">
		<cfset var response = getRemoteService().getEntryQueue(variables.remoteInstance)>
		<cfset var queue = []>
		<cfloop array="#response#" index="i">
			<cfset arrayAppend(queue, createObject("rawEntryBean").setMemento(i))>
		</cfloop>
		<cfreturn queue>
	</cffunction>

	<cffunction name="logMessage" access="public" output="false" returntype="void">
		<cfargument name="msg" type="string" required="true" />
		<cfset getRemoteService().logMessage(variables.remoteInstance, arguments.msg)>
	</cffunction>
	
	<cffunction name="processQueue" access="public" returntype="numeric">
		<cfreturn getRemoteService().processQueue(variables.remoteInstance)>
	</cffunction>	

	<cffunction name="logEntry" access="public" returntype="void">
		<cfargument name="entryBean" type="rawEntryBean" required="true">
		<cfset getRemoteService().logEntry(variables.remoteInstance, arguments.entryBean.getMemento())>
	</cffunction>	
	
	<cffunction name="getKey" access="public" returntype="string">
		<cfreturn "n/a">
	</cffunction>	

	<cffunction name="reloadRules" access="public" returntype="void">
		<cfset getRemoteService().reloadRules(variables.remoteInstance)>
	</cffunction>		

	<!--- Private Methods --->
	
	<cffunction name="getRemoteService" access="private" returntype="any">
		<cfset var rtn = createObject("webservice",variables.remoteWSDL,{refreshWsdl=true})>
		<cfreturn rtn>
	</cffunction>

</cfcomponent>