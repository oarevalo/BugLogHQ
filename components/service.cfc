<cfcomponent>
	
	<cfset variables.serviceName = "_bugLogListener">
	<cfset variables.configDoc = "/bugLog/config/buglog-config.xml.cfm">
	<cfset variables.DEFAULT_SERVICE_CFC = "bugLog.components.bugLogListener">

	<cffunction name="init" returntype="service" access="public" hint="constructor">
		<cfargument name="reloadConfig" type="boolean" required="false" default="false">
		<cfif arguments.reloadConfig or Not isConfigLoaded()>
			<cfset loadConfig()>
		</cfif>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="start" returntype="void" access="public" hint="Starts the service">
		<cfscript>
			var oListener = 0;
			var serviceCFC = "";
			
			// read config to get which class to instantiate
			serviceCFC = getSetting("serviceCFC", variables.DEFAULT_SERVICE_CFC);
			
			// create the bug log listener
			oListener = createObject("component", serviceCFC);
			oListener.init( getConfig() );
			
			// store the service on the application scope
			server[variables.serviceName] = oListener;				
		</cfscript>
	</cffunction>

	<cffunction name="stop" returntype="void" access="public" hint="Stops the service">
		<cftry>
			<cfset getService().shutDown()>
			<cfset structDelete(server, variables.serviceName)>
			<cfcatch type="any">
				<cfset structDelete(server, variables.serviceName)>
				<cfrethrow>						
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getService" returntype="bugLogListener" access="public" hint="Returns the currently running instance of the service">
		<cfif not isRunning()>
			<cfthrow message="BugLogListener service is not running." type="bugLog.listenerNotRunning">
		</cfif>
		<cfreturn server[variables.serviceName]>
	</cffunction>

	<cffunction name="isRunning" returntype="boolean" access="public" hint="Returns whether the service is running or not">
		<cfreturn structKeyExists(server, variables.serviceName)>
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
	
	
	<!--- Private Methods --->

	<cffunction name="isConfigLoaded" returnType="boolean" access="private" hint="Returns whether config settings have been loaded or not">
		<cfreturn structKeyExists(server, variables.serviceName & "Config")>
	</cffunction>
	
	<cffunction name="loadConfig" returntype="void" access="private" hint="loads config settings into memory">
		<cfset server[variables.serviceName & "Config"] = createObject("component","config").init(configProviderType = "xml",
																									configDoc = variables.configDoc)>
	</cffunction>
	
	<cffunction name="getConfig" returnType="any" access="private" hint="returns the config settings">
		<cfreturn server[variables.serviceName & "Config"]>
	</cffunction>

</cfcomponent>