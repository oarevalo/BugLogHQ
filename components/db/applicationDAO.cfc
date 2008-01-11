<cfcomponent extends="bugLog.components.lib.dao.DAO">
	
	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("bl_Application")>
		<cfset setPrimaryKey("applicationID","cf_sql_varchar")>
		<cfset setLabelField("code","cf_sql_varchar")>
		
		<cfset addColumn("code", "cf_sql_varchar")>
		<cfset addColumn("name", "cf_sql_varchar")>
	</cffunction>
	
</cfcomponent>