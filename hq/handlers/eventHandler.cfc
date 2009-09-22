<cfcomponent>
	
	<cfscript>
		variables.requestState = structNew();
		
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
	<cffunction name="setNextEvent" access="private" returntype="void" hint="I Set the next event to run and relocate the browser to that event."  output="false">
		<cfargument name="event"  			hint="The name of the event to run." 			type="string" required="Yes" >    
		<cfargument name="queryString"  	hint="The query string to append, if needed."   type="string" required="No" default="">  
		<cfargument name="scriptName" 		hint="The name of the script where to redirect." type="string" required="No" default="#cgi.SCRIPT_NAME#">    
		<cflocation url="#arguments.scriptName#?event=#trim(arguments.event)#&#trim(arguments.queryString)#" addtoken="no">
	</cffunction>		

	<cffunction name="setNextView" access="private" returntype="void" hint="I Set the next view to run and relocate the browser to that view."  output="false">
		<cfargument name="view"  			hint="The name of the view to display." 		type="string" required="Yes" >    
		<cfargument name="queryString"  	hint="The query string to append, if needed."   type="string" required="No" default="">  
		<cfargument name="scriptName" 		hint="The name of the script where to redirect." type="string" required="No" default="#cgi.SCRIPT_NAME#">    
		<cflocation url="#arguments.scriptName#?view=#trim(arguments.view)#&#trim(arguments.queryString)#" addtoken="no">
	</cffunction>		
	

	<!--- utility functions --->	
	<cffunction name="redirect" access="private" hint="Facade for cflocation">
		<cfargument name="url" required="yes">
		<cflocation url="#arguments.url#">
	</cffunction>
	
	<cffunction name="throw" access="private" hint="Facade for cfthrow">
		<cfargument name="message" 		type="String" required="yes">
		<cfargument name="type" 		type="String" required="no" default="custom">
		<cfthrow type="#arguments.type#" message="#arguments.message#">
	</cffunction>
	
	<cffunction name="dump" access="private" hint="Facade for cfmx dump">
		<cfargument name="var" required="yes">
		<cfdump var="#var#">
	</cffunction>
	
	<cffunction name="abort" access="private" hint="Facade for cfabort">
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
	<cffunction name="getSetting" access="private" returntype="string">
		<cfargument name="settingName" type="string" required="true">

		<cfif structKeyExists(application,"_appSettings")>
			<cfif structKeyExists(application["_appSettings"],arguments.settingName)>
				<cfreturn application["_appSettings"][arguments.settingName]>
			<cfelse>
				<cfthrow message="The requested application setting doesn't exist">
			</cfif>
		<cfelse>
			<cfthrow message="Application settings have not been initialized">
		</cfif>
		
	</cffunction>		
			
	<!--- cross-requests messages --->		
	<cffunction name="setMessage" access="private" returntype="void">
		<cfargument name="type" type="string" required="true">
		<cfargument name="text" type="string" required="true">
		<cfset cookie.message_type = arguments.type>
		<cfset cookie.message_text = arguments.text>
	</cffunction>

	<!--- access to stored instances of application services  --->
	<cffunction name="getService" access="private" returntype="WEB-INF.cftags.component">
		<cfargument name="serviceName" type="string" required="true">

		<cfif structKeyExists(application,"_appServices")>
			<cfif structKeyExists(application["_appServices"],arguments.serviceName)>
				<cfreturn application["_appServices"][arguments.serviceName]>
			<cfelse>
				<cfthrow message="The requested application service doesn't exist">
			</cfif>
		<cfelse>
			<cfthrow message="Application services have not been initialized">
		</cfif>
	</cffunction>

</cfcomponent>