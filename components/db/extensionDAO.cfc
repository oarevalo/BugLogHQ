<cfcomponent extends="bugLog.components.lib.dao.DAO">
	
	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("bl_Extension")>
		<cfset setPrimaryKey("extensionID","cf_sql_numeric")>
		<cfset setLabelField("name","cf_sql_varchar")>
		
		<cfset addColumn("name", "cf_sql_varchar")>
		<cfset addColumn("type", "cf_sql_varchar")>
		<cfset addColumn("enabled", "cf_sql_numeric")>
		<cfset addColumn("description", "cf_sql_varchar")>
		<cfset addColumn("properties", "cf_sql_varchar")>
		<cfset addColumn("createdBy", "cf_sql_numeric")>
		<cfset addColumn("createdOn", "cf_sql_timestamp")>
	</cffunction>
	
</cfcomponent>