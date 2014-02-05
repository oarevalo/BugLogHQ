<cfcomponent extends="bugLog.components.lib.dao.DAO">
	
	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("bl_Source")>
		<cfset setPrimaryKey("sourceID","cf_sql_numeric")>
		<cfset setLabelField("name","cf_sql_varchar")>
		
		<cfset addColumn("name", "cf_sql_varchar")>
	</cffunction>

</cfcomponent>