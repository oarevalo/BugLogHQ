<cfcomponent name="DAO">
	<cfscript>
		variables.DSN = "";
		variables.username = "";
		variables.password = "";
		variables.tableName = "";
		variables.PKName = "";
		variables.PKType = "cf_sql_numeric";
		variables.LabelFieldName = "";
		variables.LabelFieldType = "cf_sql_varchar";
		variables.mapColumns = structNew();
		variables.lstFields = "";
	</cfscript>

	<cffunction name="init" access="public" returntype="DAO">
		<cfargument name="DSN" type="string" required="true">
		<cfargument name="username" type="string" required="false" default="">
		<cfargument name="password" type="string" required="false" default="">
		
		<!--- init connection params --->
		<cfset variables.DSN = arguments.DSN>
		<cfset variables.username = arguments.username>
		<cfset variables.password = arguments.password>
		
		<!--- init table specific settings --->
		<cfset initTableParams()>
		
		<cfreturn this>
	</cffunction>	

	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfthrow message="The method initTableParams must be overriden">		
	</cffunction>
	
	<cffunction name="get" access="public" returntype="query">
		<cfargument name="id" type="any" required="true">
		<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			SELECT *
				FROM #variables.tableName#
				WHERE #variables.PKName# = <cfqueryparam cfsqltype="#variables.PKType#" value="#arguments.id#">
		</cfquery>
		<cfreturn qry>
	</cffunction>
	
	<cffunction name="getAll" access="public" returntype="query">
		<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			SELECT *
				FROM #variables.tableName#
		</cfquery>
		<cfreturn qry>
	</cffunction>

	<cffunction name="getByLabel" access="public" returntype="query">
		<cfargument name="label" type="string" required="true">
		<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			SELECT *
				FROM #variables.tableName#
				WHERE #variables.LabelFieldName# = <cfqueryparam cfsqltype="#variables.LabelFieldType#" value="#arguments.label#">
		</cfquery>
		<cfreturn qry>
	</cffunction>
	
	<cffunction name="delete" access="public" returntype="void">
		<cfargument name="id" type="any" required="true">
		<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			DELETE FROM #variables.tableName#
				WHERE #variables.PKName# = <cfqueryparam cfsqltype="#variables.PKType#" value="#arguments.id#">
		</cfquery>
	</cffunction>
				
				
	<!---- Private Methods ---->			
				
	<cffunction name="addColumn" access="private">
		<cfargument name="name" type="string" required="true">
		<cfargument name="type" type="string" required="true">
		<cfset variables.mapColumns[arguments.name] = structNew()>
		<cfset variables.mapColumns[arguments.name].cfsqltype = arguments.type>
		<cfset variables.mapColumns[arguments.name].value = "">
		<cfset variables.mapColumns[arguments.name].isNull = false>
		<cfset variables.lstFields = listAppend(variables.lstFields, arguments.name)>
	</cffunction>			
				
	<cffunction name="getColumnStruct" access="private" returnType="struct">
		<cfreturn duplicate(variables.mapColumns)>
	</cffunction>			
				
				
	<cffunction name="insertRecord" access="private" returntype="numeric">
		<cfargument name="columns" required="true" type="struct">

		<cfset var qry = 0>
		<cfset var i = 1>
		<cfset var col = "">

		<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			INSERT INTO #variables.tableName# (#variables.lstFields#)
				VALUES (
					<cfloop list="#variables.lstFields#" index="col">
						<cfqueryparam cfsqltype="#arguments.columns[col].cfsqltype#" 
										value="#arguments.columns[col].value#" 
										null="#arguments.columns[col].isNull#">
						<cfif i neq listLen(variables.lstFields)>,</cfif>
						<cfset i = i + 1>
					</cfloop>
				)
		</cfquery>		

		<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			SELECT LAST_INSERT_ID() AS lastID
		</cfquery>		
		
		<cfreturn qry.lastID>
	</cffunction>			

	<cffunction name="updateRecord" access="private">
		<cfargument name="id" type="any" required="true">
		<cfargument name="columns" required="true" type="struct">

		<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			UPDATE #variables.tableName#
				SET
					<cfloop collection="#arguments.columns#" item="col">
						<cfset col = aColumns[i]>
						#col# = <cfqueryparam cfsqltype="#arguments.columns[col].cfsqltype#" value="#arguments.columns[col].value#" null="#arguments.columns[col].isNull#">
						<cfif i neq listLen(variables.lstFields)>,</cfif>
						<cfset i = i + 1>
					</cfloop>
				WHERE
					 #variables.PKName# = <cfqueryparam cfsqltype="#variables.PKType#" value="#arguments.id#">			
		</cfquery>

	</cffunction>			
					
</cfcomponent>