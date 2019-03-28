<cfcomponent>
	
	<cfscript>
		variables.requestState = structNew();

		variables.requestState.view = "";
		variables.requestState.event = "";
		variables.requestState.layout = "";
		variables.requestState.module = "";

		variables.APP_KEYS.CORE = "_core";
		variables.APP_KEYS.SERVICES = "services";
		variables.APP_KEYS.SETTINGS = "settings";
		variables.APP_KEYS.PATHS = "paths";

		variables.system = createObject("java", "java.lang.System");
		
		// setters and getters
		function getView() {return variables.requestState.view;}
		function getEvent() {return variables.requestState.event;}
		function getLayout() {return variables.requestState.layout;}
		function getModule() {return variables.requestState.module;}
		
		function setView(data) {variables.requestState.view = arguments.data;}
		function setEvent(data) {variables.requestState.event = arguments.data;}
		function setLayout(data) {variables.requestState.layout = arguments.data;}
		function setModule(data) {variables.requestState.module = arguments.data;}
	</cfscript>
	
	<!--- Constructor ---->
	<cffunction name="init" access="public" hint="Constructor">
		<cfargument name="requestState" type="struct" required="true">
		<cfset variables.requestState = arguments.requestState>
		<cfreturn this>
	</cffunction>
	

	<!--- application-flow functions --->
	<cffunction name="setNextEvent" access="public" returntype="void" hint="I Set the next event to run and relocate the browser to that event."  output="false">
		<cfargument name="event"  			hint="The name of the event to run." 			type="string" required="Yes" >    
		<cfargument name="queryString"  	hint="The query string to append, if needed."   type="string" required="No" default="">  
		<cfargument name="scriptName" 		hint="The name of the script where to redirect." type="string" required="No" default="#cgi.SCRIPT_NAME#">    
		<cflocation url="#arguments.scriptName#?event=#trim(arguments.event)#&#trim(arguments.queryString)#" addtoken="no">
	</cffunction>		


	<!--- utility functions --->	
	<cffunction name="redirect" access="public" hint="Facade for cflocation">
		<cfargument name="url" required="yes">
		<cflocation url="#arguments.url#">
	</cffunction>
	
	<cffunction name="throw" access="public" hint="Facade for cfthrow">
		<cfargument name="message" 		type="String" required="yes">
		<cfargument name="type" 		type="String" required="no" default="custom">
		<cfthrow type="#arguments.type#" message="#arguments.message#">
	</cffunction>
	
	<cffunction name="dump" access="public" hint="Facade for cfmx dump">
		<cfargument name="var" required="yes">
		<cfdump var="#var#">
	</cffunction>
	
	<cffunction name="abort" access="public" hint="Facade for cfabort">
		<cfabort>
	</cffunction>


	<!---- Setter/getter for values set by event handlers --->
	<cffunction name="getValue" returntype="any" access="Public" hint="I Get a value from the request collection." output="false">
		<cfargument name="name" hint="Name of the variable to get from the request collection" type="string" required="Yes"> 
		<cfargument name="default" hint="Default value if the variable is not found." type="any" required="No" default=""> 
		<cfif structKeyExists(variables.requestState, arguments.name)>
			<cfreturn variables.requestState[arguments.name]>
		<cfelse>
			<cfreturn arguments.default>
		</cfif>
	</cffunction>

	<cffunction name="setValue" access="Public" hint="I Set a value in the request state collection" output="false" returntype="void">
		<cfargument name="name"  hint="The name of the variable to set." type="string"  required="Yes" > 
		<cfargument name="value" hint="The value of the variable to set" type="Any" 	required="Yes" >     
		<cfset variables.requestState[arguments.name] = arguments.value>
	</cffunction>
				
				
	<!--- application settings --->	
	<cffunction name="getSetting" access="public" returntype="string">
		<cfargument name="settingName" type="string" required="true">

		<cfif structKeyExists(application,variables.APP_KEYS.CORE)
				and structKeyExists(application[variables.APP_KEYS.CORE],variables.APP_KEYS.SETTINGS)>
			<cfif structKeyExists(application[variables.APP_KEYS.CORE][variables.APP_KEYS.SETTINGS],arguments.settingName)>
				<cfset var envVarSetting = variables.system.getenv(javaCast("string", ucase(arguments.settingName))) />
				<cfif !isNull(envVarSetting)>
					<!--- give preference to environment variables of the same name --->
					<cfreturn envVarSetting />
				<cfelse>
					<!--- otherwise return the variable defined in the config --->
					<cfreturn application[variables.APP_KEYS.CORE][variables.APP_KEYS.SETTINGS][arguments.settingName]>
				</cfif>
			<cfelse>
				<cfthrow message="The requested application setting [#arguments.settingName#] doesn't exist">
			</cfif>
		<cfelse>
			<cfthrow message="Application settings have not been initialized">
		</cfif>
		
	</cffunction>		


	<!--- application paths --->	
	<cffunction name="getPath" access="public" returntype="string">
		<cfargument name="pathName" type="string" required="true">

		<cfif structKeyExists(application,variables.APP_KEYS.CORE)
				and structKeyExists(application[variables.APP_KEYS.CORE],variables.APP_KEYS.PATHS)>
			<cfif structKeyExists(application[variables.APP_KEYS.CORE][variables.APP_KEYS.PATHS],arguments.pathName)>
				<cfreturn application[variables.APP_KEYS.CORE][variables.APP_KEYS.PATHS][arguments.pathName]>
			<cfelse>
				<cfthrow message="The requested application path [#arguments.pathName#] doesn't exist">
			</cfif>
		<cfelse>
			<cfthrow message="Application paths have not been initialized">
		</cfif>
		
	</cffunction>		
							
			
	<!--- cross-requests messages --->		
	<cffunction name="setMessage" access="public" returntype="void">
		<cfargument name="type" type="string" required="true">
		<cfargument name="text" type="string" required="true">
		<cfset cookie.message_type = arguments.type>
		<cfset cookie.message_text = arguments.text>
	</cffunction>


	<!--- access to stored instances of application services  --->
	<cffunction name="getService" access="public" returntype="WEB-INF.cftags.component">
		<cfargument name="serviceName" type="string" required="true">

		<cfif structKeyExists(application,variables.APP_KEYS.CORE)
				and structKeyExists(application[variables.APP_KEYS.CORE],variables.APP_KEYS.SERVICES)>
			<cfif structKeyExists(application[variables.APP_KEYS.CORE][variables.APP_KEYS.SERVICES],arguments.serviceName)>
				<cfreturn application[variables.APP_KEYS.CORE][variables.APP_KEYS.SERVICES][arguments.serviceName]>
			<cfelse>
				<cfthrow message="The requested application service doesn't exist">
			</cfif>
		<cfelse>
			<cfthrow message="Application services have not been initialized">
		</cfif>
	</cffunction>

</cfcomponent>