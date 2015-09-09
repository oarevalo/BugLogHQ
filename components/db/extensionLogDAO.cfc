<cfcomponent extends="bugLog.components.lib.dao.DAO">
	
	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("bl_extensionlog")>
		<cfset setPrimaryKey("extensionLogID","cf_sql_numeric")>
		
		<cfset addColumn("extensionID", "cf_sql_numeric")>
		<cfset addColumn("entryID", "cf_sql_numeric")>
		<cfset addColumn("createdOn", "cf_sql_timestamp")>
	</cffunction>

	<cffunction name="getLastTrigger" access="public" returntype="query" hint="Returns a query object with information about the last time a rule was triggered">
		<cfargument name="extensionID" type="numeric" required="true" />
		<cfset var qry = 0>
		<cfset var dsn = getDataProvider().getConfig().getDSN()>
		<cfset var username = getDataProvider().getConfig().getUsername()>
		<cfset var password = getDataProvider().getConfig().getPassword()>
		<cfquery name="qry" datasource="#dsn#" username="#username#" password="#password#">
			SELECT extensionLogID, extensionID, entryID, createdOn
				FROM #getTableName()#
				WHERE extensionID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#extensionID#">
				ORDER BY createdOn DESC
		</cfquery>
		<cfreturn qry>
	</cffunction>

	<cffunction name="getTriggers" access="public" returntype="query" hint="Returns a query with extensions triggered by a given entryID">
		<cfargument name="entryID" type="numeric" required="true" />
		<cfset var qry = 0>
		<cfset var dsn = getDataProvider().getConfig().getDSN()>
		<cfset var username = getDataProvider().getConfig().getUsername()>
		<cfset var password = getDataProvider().getConfig().getPassword()>
		<cfquery name="qry" datasource="#dsn#" username="#username#" password="#password#">
			SELECT extensionLogID, extensionID, entryID, createdOn
				FROM #getTableName()#
				WHERE entryID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#entryID#">
				ORDER BY createdOn DESC
		</cfquery>
		<cfreturn qry>
	</cffunction>

</cfcomponent>
