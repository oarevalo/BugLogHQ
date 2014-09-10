<cfcomponent extends="bugLog.components.lib.dao.DAO">
	
	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("bl_Domain")>
		<cfset setPrimaryKey("DomainID","cf_sql_numeric")>
		<cfset setLabelField("domain","cf_sql_varchar")>
		<cfset addColumn("domain", "cf_sql_varchar")>
		<cfset addColumn("CreatedOn", "cf_sql_timestamp")>
	</cffunction>
	
</cfcomponent>