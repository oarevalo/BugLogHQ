<cfcomponent>
	
	<cfset variables.serviceName = "_bugLogListener">
	<cfset variables.configDoc = "/bugLog/config/service-config.xml.cfm">
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
			oListener.init();
			
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
		<cfset var cfg = getConfig()>
		<cfset var rtn = arguments.defaultValue>
		<cfif structKeyExists(cfg, arguments.settingName)>
			<cfset rtn = cfg[arguments.settingName]>
		</cfif>
		<cfreturn rtn>
	</cffunction>
	
	
	<!--- Private Methods --->

	<cffunction name="isConfigLoaded" returnType="boolean" access="private" hint="Returns whether config settings have been loaded or not">
		<cfreturn structKeyExists(server, variables.serviceName & "Config")>
	</cffunction>
	
	<cffunction name="loadConfig" returntype="void" access="private" hint="loads config settings into memory">
		<cfscript>
			var cfg = structNew();
			var xmlDoc = xmlParse(expandPath(variables.configDoc));
			var xmlNode = 0;
			
			for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				xmlNode = xmlDoc.xmlRoot.xmlChildren[i];
				cfg[xmlNode.xmlName] = xmlNode.xmlText;
			}

			server[variables.serviceName & "Config"] = cfg;		
		</cfscript>
	</cffunction>
	
	<cffunction name="getConfig" returnType="struct" access="private" hint="returns the struct with the config settings">
		<cfreturn server[variables.serviceName & "Config"]>
	</cffunction>

</cfcomponent>