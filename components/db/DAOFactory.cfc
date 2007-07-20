<cfcomponent>
	<cfscript>
		variables.dsn = "buglog";
		variables.username = "";
		variables.password = "";
	</cfscript>
	
	<cffunction name="init" access="public" returntype="DAOFactory">
		<cfargument name="DSN" type="string" required="true">
		<cfargument name="username" type="string" required="false" default="">
		<cfargument name="password" type="string" required="false" default="">
		
		<!--- init connection params --->
		<cfset variables.DSN = arguments.DSN>
		<cfset variables.username = arguments.username>
		<cfset variables.password = arguments.password>
		
		<cfreturn this>
	</cffunction>	
	
	<cffunction name="getDAO" access="public" returntype="DAO">
		<cfargument name="name" type="string" required="true">
		<cfreturn createObject("component", arguments.name & "DAO").init(variables.dsn, variables.username, variables.password)>
	</cffunction>
		
</cfcomponent>