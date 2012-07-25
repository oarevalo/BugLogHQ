<cfcomponent>
	<!---
		service.cfc
		
		This component acts as the main loader/unloader for the main BugLog service. This cfc
		handles the persistence of the service internally, so there is no need to keep an instance
		of this cfc on a persistent scope. Callers should always create a fresh instance of this cfc
		on each request.
		
		The loader also supports multiple buglog instances loaded at the same time, each with its
		own configuration. Just pass the desired instance name on the init and the loader will do 
		the rest.
		
		oarevalo 5/2012 
	--->
	
	<cfset variables.serviceName = "_bugLogListener">
	<cfset variables.instanceName = "">
	<cfset variables.DEFAULT_SERVICE_CFC = "bugLog.components.bugLogListener">

	<cffunction name="init" returntype="service" access="public" hint="constructor">
		<cfargument name="reloadConfig" type="boolean" required="false" default="false">
		<cfargument name="instanceName" type="string" required="false" default="">
		
		<!--- Remember the instance name. Each service.cfc instance needs to be
				mapped to a single buglog instance --->
		<cfset variables.instanceName = arguments.instanceName>
		<cfif variables.instanceName eq "">
			<cfset variables.instanceName = "default">
		</cfif>
		
		<!--- Make sure we have a config in memory --->
		<cfif arguments.reloadConfig or Not isConfigLoaded()>
			<cfset loadConfig()>
		</cfif>
				
		<cfreturn this>
	</cffunction>
	
	<cffunction name="start" returntype="void" access="public" hint="Starts the service">
		<cfset loadInstance()>
	</cffunction>

	<cffunction name="stop" returntype="void" access="public" hint="Stops the service">
		<cfset unloadInstance()>
	</cffunction>

	<cffunction name="getService" returntype="bugLogListener" access="public" hint="Returns the currently running instance of the service">
		<!--- See if we want to auto-start the service --->
		<cfif  !isRunning() and getSetting("autoStart")>
			<cfset loadInstance()>
		</cfif>
		<cfreturn getInstance()>
	</cffunction>

	<cffunction name="isRunning" returntype="boolean" access="public" hint="Returns whether the service is running or not">
		<cfreturn isInstanceLoaded()>
	</cffunction>
	
	<cffunction name="getSetting" returnType="string" access="public" hint="Returns the given config setting, if doesnt exist, returns empty or default value">
		<cfargument name="settingName" type="string" required="true">
		<cfargument name="defaultValue" type="string" required="false" default="">
		<cfreturn getConfig().getSetting("service." & arguments.settingName, arguments.defaultValue)>
	</cffunction>

	<cffunction name="setSetting" returntype="void" access="public" hint="Sets a config setting within the 'service' block">
		<cfargument name="settingName" type="string" required="true">
		<cfargument name="settingValue" type="string" required="true">
		<cfset getConfig().setSetting("service." & arguments.settingName, arguments.settingValue)>
	</cffunction>
	
	<cffunction name="validateAPIKey" returntype="boolean" access="public" hint="Validates that an API key is valid, if not throws an error. This only applies when the requireAPIKey setting is true, otherwise returns True always">
		<cfargument name="apiKeyToCheck" type="string" required="true">
		<cfif getSetting("requireAPIKey",false) and apiKeyToCheck neq getSetting("APIKey")>
			<cfthrow message="Invalid API Key." type="bugLog.invalidAPIKey">
		</cfif>
		<cfreturn True>
	</cffunction>

	<cffunction name="getInstanceName" returntype="string" access="public" hint="Returns the name of the associated buglog instance">
		<cfreturn variables.instanceName>
	</cffunction>

	<cffunction name="getConfig" returnType="any" access="public" hint="returns the config settings">
		<cfset var name = getServiceConfigName()>
		<cfreturn server[name]>
	</cffunction>

	
	
	<!--- Private Methods --->

	<cffunction name="getInstance" returnType="any" access="private" hint="returns the buglog instance">
		<cfset var name = getServiceName()>
		<cfif Not structKeyExists(server, name)>
			<cfthrow message="The requested BugLogListener instance is not available." type="bugLog.listenerNotRunning">
		</cfif>
		<cfreturn server[name]>
	</cffunction>

	<cffunction name="isInstanceLoaded" returntype="boolean" access="private" hint="Returns whether the buglog instance has been loaded into memory">
		<cfset var name = getServiceName()>
		<cfreturn structKeyExists(server, name)>
	</cffunction>

	<cffunction name="loadInstance" returntype="void" access="private" hint="loads buglog instance into memory">
		<cfscript>
			var oListener = 0;
			var name = getServiceName();
			
			// read config to get which class to instantiate
			var serviceCFC = getSetting("serviceCFC", variables.DEFAULT_SERVICE_CFC);
			
			lock type="exclusive" name="bugLogListener_start_#instanceName#" timeout="10" {
				// create the bug log listener
				oListener = createObject("component", serviceCFC)
									.init( getConfig() , instanceName );

				// store the service on a persistent scope
				server[name] = oListener;				
			}
			
		</cfscript>
	</cffunction>
	
	<cffunction name="unloadInstance" returntype="void" access="private" hint="removes the buglog instance from memory">
		<cfset var name = getServiceName()>
		<cftry>
			<cfset getService().shutDown()>
			<cfset structDelete(server, name)>
			<cfcatch type="any">
				<cfset structDelete(server, name)>
				<cfrethrow>						
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="isConfigLoaded" returnType="boolean" access="private" hint="Returns whether config settings have been loaded or not">
		<cfset var name = getServiceConfigName()>
		<cfreturn structKeyExists(server, name)>
	</cffunction>
	
	<cffunction name="loadConfig" returntype="void" access="private" hint="loads config settings into memory">
		<cfset var name = getServiceConfigName()>
		<cfset server[name] = createObject("component","configFactory").init().getConfig(variables.instanceName)>
	</cffunction>
	
	<cffunction name="getServiceName" returntype="string" access="private" hint="returns the name to use for the service instance in the server scope">
		<cfreturn variables.serviceName & "_" & variables.instanceName>
	</cffunction>

	<cffunction name="getServiceConfigName" returntype="string" access="private" hint="returns the name to use for the service instance in the server scope">
		<cfreturn variables.serviceName & "Config" & "_" & variables.instanceName>
	</cffunction>

</cfcomponent>