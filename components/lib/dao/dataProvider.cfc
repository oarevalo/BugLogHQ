<cfcomponent>

	<cfset variables.oConfigBean = 0>
	<cfset variables.dataProviderType = "">
	
	<cffunction name="init" returntype="dataProvider" access="public">
		<cfargument name="configBean" type="configBean" required="true">
		
		<!--- store a local reference to the config bean --->
		<cfset variables.oConfigBean = arguments.configBean>
		
		<!--- call a procedure to setup the dataprovider 
			(in case childs need to do anything special)
		--->
		<cfset setup()>

		<cfreturn this>
	</cffunction>

	
	<cffunction name="setup" access="public" returntype="void">
		<!--- implementation of this method is optional --->
	</cffunction>
	
	<cffunction name="get" access="public" returntype="query">
		<cfargument name="id" type="any" required="true">
		<cfargument name="_mapTableInfo" type="struct" required="true">
		<cfargument name="_mapColumns" type="struct" required="true">
		<cfthrow message="method not defined">
	</cffunction>
	
	<cffunction name="getAll" access="public" returntype="query">
		<cfargument name="_mapTableInfo" type="struct" required="true">
		<cfargument name="_mapColumns" type="struct" required="true">
		<cfthrow message="method not defined">
	</cffunction>

	<cffunction name="delete" access="public" returntype="void">
		<cfargument name="id" type="any" required="true">
		<cfargument name="_mapTableInfo" type="struct" required="true">
		<cfargument name="_mapColumns" type="struct" required="true">
		<cfthrow message="method not defined">
	</cffunction>
				
	<cffunction name="save" access="public" returntype="any">
		<cfargument name="id" type="any" required="false" default="0">
		<cfargument name="_mapTableInfo" type="struct" required="true">
		<cfargument name="_mapColumns" type="struct" required="true">
		<cfthrow message="method not defined">
	</cffunction>
	
	<cffunction name="search" returntype="query" access="public">
		<cfargument name="_mapTableInfo" type="struct" required="true">
		<cfargument name="_mapColumns" type="struct" required="true">
		<cfthrow message="method not defined">
	</cffunction>
	
	<cffunction name="exec" returntype="query" access="public">
		<cfargument name="sql" type="string" required="true">
		<cfthrow message="method not defined">
	</cffunction>
	
	
	<!--- These methods do not need to be overloaded --->
	<cffunction name="getType" returntype="string" access="public">
		<cfreturn variables.dataProviderType>
	</cffunction>
	
	<cffunction name="getConfig" returntype="configBean" access="public">
		<cfreturn variables.oConfigBean>
	</cffunction>
	
</cfcomponent>