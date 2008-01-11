<cfcomponent extends="configBean">
	
	<cfproperty name="DSN" type="string" required="false" default="">
	<cfproperty name="username" type="string" required="false" default="">
	<cfproperty name="password" type="string" required="false" default="">
	<cfproperty name="dbtype" type="string" required="false" default="">
	
	<cffunction name="init" access="public" returntype="dbDataProviderConfigBean">
		<cfscript>
			variables.instance = structNew();
			variables.instance.DSN = "";
			variables.instance.username = "";
			variables.instance.password = "";
			variables.instance.dbtype = "";
		</cfscript>
		<cfreturn this>
	</cffunction>

	<cffunction name="getDSN" returntype="string" access="public">
		<cfreturn getProperty("DSN")>
	</cffunction>

	<cffunction name="getUsername" returntype="string" access="public">
		<cfreturn getProperty("username")>
	</cffunction>

	<cffunction name="getPassword" returntype="string" access="public">
		<cfreturn getProperty("password")>
	</cffunction>

	<cffunction name="getDBType" returntype="string" access="public">
		<cfreturn getProperty("dbtype")>
	</cffunction>



	<cffunction name="setDSN" returntype="void" access="public">
		<cfargument name="data" type="string" required="true">
		<cfset setProperty("DSN", arguments.data)>
	</cffunction>

	<cffunction name="setUsername" returntype="void" access="public">
		<cfargument name="data" type="string" required="true">
		<cfset setProperty("username", arguments.data)>
	</cffunction>

	<cffunction name="setPassword" returntype="void" access="public">
		<cfargument name="data" type="string" required="true">
		<cfset setProperty("password", arguments.data)>
	</cffunction>

	<cffunction name="setDBType" returntype="void" access="public">
		<cfargument name="data" type="string" required="true">
		<cfset setProperty("dbtype", arguments.data)>
	</cffunction>

</cfcomponent>