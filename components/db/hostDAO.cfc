<cfcomponent extends="bugLog.components.lib.dao.DAO">
	
	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("bl_Host")>
		<cfset setPrimaryKey("hostID","cf_sql_varchar")>
		<cfset setLabelField("hostName","cf_sql_varchar")>

		<cfset addColumn("hostName", "cf_sql_varchar")>

	</cffunction>

</cfcomponent>