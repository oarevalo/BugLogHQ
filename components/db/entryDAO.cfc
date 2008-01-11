<cfcomponent extends="bugLog.components.lib.dao.DAO">
	
	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("bl_Entry")>
		<cfset setPrimaryKey("entryID","cf_sql_varchar")>
		<cfset setLabelField("entryID","cf_sql_varchar")>
		
		<cfset addColumn("mydateTime", "cf_sql_timestamp")>
		<cfset addColumn("message", "cf_sql_varchar")>
		<cfset addColumn("applicationID", "cf_sql_numeric")>
		<cfset addColumn("sourceID", "cf_sql_numeric")>
		<cfset addColumn("severityID", "cf_sql_numeric")>
		<cfset addColumn("hostID", "cf_sql_numeric")>
		<cfset addColumn("exceptionMessage", "cf_sql_varchar")>
		<cfset addColumn("exceptionDetails", "cf_sql_varchar")>
		<cfset addColumn("CFID", "cf_sql_varchar")>
		<cfset addColumn("CFTOKEN", "cf_sql_varchar")>
		<cfset addColumn("UserAgent", "cf_sql_varchar")>
		<cfset addColumn("TemplatePath", "cf_sql_varchar")>
		<cfset addColumn("HTMLReport", "cf_sql_varchar")>
		<cfset addColumn("CreatedOn", "cf_sql_timestamp")>
	</cffunction>

</cfcomponent>