<cfcomponent extends="bugLog.components.lib.dao.DAO">
	
	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("bl_extensionlog")>
		<cfset setPrimaryKey("extensionLogID","cf_sql_numeric")>
		
		<cfset addColumn("extensionID", "cf_sql_numeric")>
		<cfset addColumn("entryID", "cf_sql_numeric")>
		<cfset addColumn("createdOn", "cf_sql_timestamp")>
	</cffunction>
	
</cfcomponent>