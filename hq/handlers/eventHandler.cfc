<cfcomponent>
	
	<cfscript>
		variables.requestState = structNew();
		
		// setters and getters
		function getView() {return variables.requestState.view;}
		function getEvent() {return variables.requestState.event;}
		function getLayout() {return variables.requestState.layout;}

		function setView(data) {variables.requestState.view = arguments.data;}
		function setEvent(data) {variables.requestState.event = arguments.data;}
		function setLayout(data) {variables.requestState.layout = arguments.data;}
	</cfscript>
	
	<!--- Constructor ---->
	<cffunction name="init">
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

	<!--- access to stored instances of applicatino services  --->
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

	<!--- access to domain-model components  --->
	<cffunction name="getModel" access="private" returntype="WEB-INF.cftags.component">
		<cfargument name="className" type="string" required="true">
		<cfreturn createInstance(variables.requestState["_modelsPath"] & "/" & arguments.className & ".cfc")>
	</cffunction>


	<cffunction name="filterQuery" access="private" hint="Filters a query by the given value">
		<cfargument name="qry" type="query" required="yes">
		<cfargument name="field" type="string" required="yes">
		<cfargument name="value" type="string" required="yes">
		<cfargument name="cfsqltype" type="string" required="no" default="cf_sql_varchar">
		
		<cfset var qryNew = QueryNew("")>
		
		<cfquery name="qryNew" dbtype="query">
			SELECT *
				FROM arguments.qry
				WHERE #arguments.field# = <cfqueryparam cfsqltype="#arguments.cfsqltype#" value="#arguments.value#">
		</cfquery>		
		
		<cfreturn qryNew>
	</cffunction>
	
	<cffunction name="sortQuery" access="private" hint="Sorts a query by the given field">
		<cfargument name="qry" type="query" required="yes">
		<cfargument name="sortBy" type="string" required="yes">
		<cfargument name="sortOrder" type="string" required="no" default="ASC">
		
		<cfset var qryNew = QueryNew("")>
		
		<cfquery name="qryNew" dbtype="query">
			SELECT *
				FROM arguments.qry
				ORDER BY #Arguments.SortBy# #Arguments.SortOrder#
		</cfquery>		
		
		<cfreturn qryNew>
	</cffunction>	

	<cffunction name="createInstance" returntype="Any" access="private">
		<cfargument name="path" type="String" required="true">
		<cfargument name="type" type="String" required="no" default="">

		<cfscript>
			/****************************************************************
			 UDF:    component(path, type)
			 Author: Dan G. Switzer, II
			 Date:   5/26/2004
			
			 Arguments:
			  path - the path to the component. can be standard 
			         dot notation, relative path or absolute path
			  type - the type of path specified. "component" uses
			         the standard CF dot notation. "relative" uses
			         a relative path the the CFC (including file
			         extension.) "absolute" indicates your using
			         the direct OS path to the CFC. By default
			         this tag will either be set to "component"
			         (if no dots or no slashes and dots are found)
			         or it'll be set to "relative". As a shortcut,
			         you can use just the first letter of the type.
			         (i.e. "c" for "component, etc.)
			 Notes:
			  This is based upon some code that has floated around the
			  different CF lists.
			****************************************************************/
				var sPath=Arguments.path;var oProxy="";var oFile="";var sProxyPath = "";
				var sType = lcase(Arguments.type);
			
				// determine a default type	
				if( len(sType) eq 0 ){
					if( (sPath DOES NOT CONTAIN ".") OR ((sPath CONTAINS ".") AND (sPath DOES NOT CONTAIN "/") AND (sPath DOES NOT CONTAIN "\")) ) sType = "component";
					else sType = "relative";
				}
				
				// create the component
				switch( left(sType,1) ){
					case "c":
						return createObject("component", sPath);
					break;
			
					default:
						if( left(sType, 1) neq "a" ) sPath = expandPath(sPath);
						// updated to work w/CFMX v6.1 and v6.0
						// if this code breaks, MACR has either moved the TemplateProxy
						// again or simply prevented it from being publically accessed
						if( left(server.coldFusion.productVersion, 3) eq "6,0") sProxyPath = "coldfusion.runtime.TemplateProxy";
						else sProxyPath = "coldfusion.runtime.TemplateProxyFactory";
						try {
							oProxy = createObject("java", sProxyPath);
							oFile = createObject("java", "java.io.File");
							oFile.init(sPath);
							return oProxy.resolveFile(getPageContext(), oFile);
						}
						catch(Any exception){
							throw("An error occured initializing the component #arguments.path#.");
							return;
						}
					break;
				}
		</cfscript>
	</cffunction>


</cfcomponent>