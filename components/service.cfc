<cfcomponent>
	
	<cfset variables.serviceName = "_bugLogListener">

	<cffunction name="init" returntype="service" access="public" hint="constructor">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="start" returntype="void" access="public" hint="Starts the service">
		<cfscript>
			var oListener = 0;
			
			// create the bug log listener
			oListener = createObject("component", "bugLogListener");
			oListener.init();
			
			// store the service on the application scope
			server[variables.serviceName] = oListener;				
		</cfscript>
	</cffunction>

	<cffunction name="stop" returntype="void" access="public" hint="Stops the service">
		<cfset structDelete(server, variables.serviceName)>
	</cffunction>

	<cffunction name="getService" returntype="bugLogListener" access="public" hint="Returns the currently running instance of the service">
		<cfreturn server[variables.serviceName]>
	</cffunction>

	<cffunction name="isRunning" returntype="boolean" access="public" hint="Returns whether the service is running or not">
		<cfreturn structKeyExists(server, variables.serviceName)>
	</cffunction>

</cfcomponent>