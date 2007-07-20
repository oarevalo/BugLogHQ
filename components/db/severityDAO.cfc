<cfcomponent extends="DAO">
	
	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset variables.tableName = "bl_Severity">
		<cfset variables.PKName = "severityID">
		<cfset variables.LabelFieldName = "code">
		
		<cfset addColumn("code", "cf_sql_varchar")>
		<cfset addColumn("name", "cf_sql_varchar")>

	</cffunction>
	
	<cffunction name="save" access="public" returntype="numeric">
		<cfargument name="severityID" type="numeric" required="true">
		<cfargument name="code" type="string" required="true">
		<cfargument name="name" type="string" required="true">
		
		<cfscript>
			var stColumns = getColumnStruct();
			
			stColumns.code.value = arguments.code;
			stColumns.name.value = arguments.name;
			
			if(arguments.severityID eq 0)
				arguments.severityID = insertRecord(stColumns);
			else
				updateRecord(arguments.severityID, stColumns);
		</cfscript>		
		
		<cfreturn arguments.severityID>
	</cffunction>
	
</cfcomponent>