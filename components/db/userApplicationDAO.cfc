<cfcomponent extends="bugLog.components.lib.dao.DAO">
	
	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("bl_UserApplication")>
		<cfset setPrimaryKey("UserApplicationID","cf_sql_varchar")>
		
		<cfset addColumn("UserID", "cf_sql_numeric")>
		<cfset addColumn("ApplicationID", "cf_sql_numeric")>
	</cffunction>
	
</cfcomponent>