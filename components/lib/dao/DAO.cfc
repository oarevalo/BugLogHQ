<cfcomponent name="DAO" hint="this component provides a basic DAO implementation for accessing a backend data store">

	<cfscript>
		variables.oDataProvider = 0;
		variables.mapColumns = structNew();
		variables.mapTableInfo = structNew();
		variables.mapTableInfo.tableName = "";
		variables.mapTableInfo.PKName = "";
		variables.mapTableInfo.PKType = "cf_sql_numeric";
		variables.mapTableInfo.LabelFieldName = "";
		variables.mapTableInfo.LabelFieldType = "cf_sql_varchar";
	</cfscript>
	
	<!--- Constructor --->
	<cffunction name="init" access="public" returntype="DAO">
		<cfargument name="dataProvider" type="dataProvider" required="true">
		
		<!--- init connection params --->
		<cfset variables.oDataProvider = arguments.dataProvider>
		
		<!--- init table specific settings --->
		<cfset initTableParams()>
		
		<cfreturn this>
	</cffunction>
	
	
	<!--- Data Access Methods --->
	<cffunction name="get" access="public" returntype="query">
		<cfargument name="id" type="any" required="true">
		<cfreturn variables.oDataProvider.get(arguments.id, variables.mapTableInfo, variables.mapColumns)>
	</cffunction>
	
	<cffunction name="getAll" access="public" returntype="query">
		<cfreturn variables.oDataProvider.getAll(variables.mapTableInfo, variables.mapColumns)>
	</cffunction>
	
	<cffunction name="getByLabel" access="public" returntype="query">
		<cfargument name="label" type="string" required="true">
		<cfset var st = structNew()>
		<cfset st[variables.mapTableInfo.LabelFieldName] = arguments.label>
		<cfreturn search(argumentCollection = st)>
	</cffunction>

	<cffunction name="delete" access="public" returntype="void">
		<cfargument name="id" type="any" required="true">
		<cfset variables.oDataProvider.delete(arguments.id, variables.mapTableInfo, variables.mapColumns)>
	</cffunction>
				
	<cffunction name="save" access="public" returntype="any">
		<cfargument name="id" type="any" required="false" default="0">
		<cfset var stArgs = arguments>
		<cfset stArgs._mapTableInfo = variables.mapTableInfo>
		<cfset stArgs._mapColumns = variables.mapColumns>
		<cfreturn variables.oDataProvider.save(argumentCollection = stArgs)>
	</cffunction>
	
	<cffunction name="search" returntype="query" access="public">
		<cfset var stArgs = arguments>
		<cfset stArgs._mapTableInfo = variables.mapTableInfo>
		<cfset stArgs._mapColumns = variables.mapColumns>
		<cfreturn variables.oDataProvider.search(argumentCollection = stArgs)>
	</cffunction>
	
	
			
	<!--- Setup Methods --->	
	<cffunction name="initTableParams" access="private" returntype="void" hint="setup table specific settings">
		<cfthrow message="The method initTableParams must be overriden">		
	</cffunction>
		
	<cffunction name="addColumn" access="public">
		<cfargument name="name" type="string" required="true">
		<cfargument name="type" type="string" required="true">
		<cfargument name="default" type="string" required="false" default="">
		<cfset variables.mapColumns[arguments.name] = structNew()>
		<cfset variables.mapColumns[arguments.name].cfsqltype = arguments.type>
		<cfset variables.mapColumns[arguments.name].value = "">
		<cfset variables.mapColumns[arguments.name].isNull = false>
		<cfset variables.mapColumns[arguments.name].default = "">
	</cffunction>			
				
				
				
	<!--- Setters / Getters --->			
	<cffunction name="getPrimaryKeyName" returntype="string" access="public">
		<cfreturn variables.mapTableInfo.pkName>
	</cffunction>

	<cffunction name="getPrimaryKeyType" returntype="string" access="public">
		<cfreturn variables.mapTableInfo.PKType>
	</cffunction>

	<cffunction name="getTableName" returntype="string" access="public">
		<cfreturn variables.mapTableInfo.tableName>
	</cffunction>

	<cffunction name="getDataProvider" returntype="dataProvider" access="public">
		<cfreturn variables.oDataProvider>
	</cffunction>

	<cffunction name="getColumnStruct" access="public" returnType="struct">
		<cfset var st = duplicate(variables.mapColumns)>
		<cfset var key = "">
		<cfloop collection="#st#" item="key">
			<cfset st[key].value = st[key].default>
		</cfloop>
		<cfreturn st>
	</cffunction>			



	<cffunction name="setPrimaryKey" access="public">
		<cfargument name="name" type="string" required="true">
		<cfargument name="type" type="string" required="true">
		<cfset variables.mapTableInfo.PKName = arguments.name>
		<cfset variables.mapTableInfo.PKType = arguments.type>
	</cffunction>			

	<cffunction name="setTableName" access="public">
		<cfargument name="name" type="string" required="true">
		<cfset variables.mapTableInfo.tableName = arguments.name>
	</cffunction>			

	<cffunction name="setLabelField" access="public">
		<cfargument name="name" type="string" required="true">
		<cfargument name="type" type="string" required="true">
		<cfset variables.mapTableInfo.LabelFieldName = arguments.name>
		<cfset variables.mapTableInfo.LabelFieldType = arguments.type>
	</cffunction>			

</cfcomponent>