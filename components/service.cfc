<cfcomponent>
	
	<cfset variables.serviceName = "_bugLogListener">
	<cfset variables.serviceCFC = "bugLog.components.bugLogListener">
	<cfset variables.configDoc = "/bugLog/config/service-config.xml.cfm">

	<cffunction name="init" returntype="service" access="public" hint="constructor">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="start" returntype="void" access="public" hint="Starts the service">
		<cfscript>
			var oListener = 0;
			
			// read config to get which class to instantiate
			// ** this is so that the listener class can be overriden without having to change the code
			if(fileExists(expandPath(variables.configDoc))) {
				xmlDoc = xmlParse(expandPath(variables.configDoc));
				if(structKeyExists(xmlDoc.xmlRoot,"serviceCFC")) {
					variables.serviceCFC = xmlDoc.xmlRoot.serviceCFC.xmlText;
				}
			}
			
			// create the bug log listener
			oListener = createObject("component", variables.serviceCFC);
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
		<cfreturn server[variables.serviceName]>
	</cffunction>

	<cffunction name="isRunning" returntype="boolean" access="public" hint="Returns whether the service is running or not">
		<cfreturn structKeyExists(server, variables.serviceName)>
	</cffunction>

</cfcomponent>