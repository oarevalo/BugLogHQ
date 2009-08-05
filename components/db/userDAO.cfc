<cfcomponent extends="bugLog.components.lib.dao.DAO">
	
	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("bl_User")>
		<cfset setPrimaryKey("UserID","cf_sql_varchar")>
		<cfset setLabelField("Username","cf_sql_varchar")>
		
		<cfset addColumn("Username", "cf_sql_varchar")>
		<cfset addColumn("Password", "cf_sql_varchar")>
		<cfset addColumn("IsAdmin", "cf_sql_numeric")>
	</cffunction>
	
</cfcomponent>