<cfcomponent extends="DAO">
	
	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset variables.tableName = "bl_Application">
		<cfset variables.PKName = "applicationID">
		<cfset variables.LabelFieldName = "code">
		
		<cfset addColumn("code", "cf_sql_varchar")>
		<cfset addColumn("name", "cf_sql_varchar")>

	</cffunction>
	
	<cffunction name="save" access="public" returntype="numeric">
		<cfargument name="applicationID" type="numeric" required="true">
		<cfargument name="code" type="string" required="true">
		<cfargument name="name" type="string" required="true">
		
		<cfscript>
			var stColumns = getColumnStruct();
			
			stColumns.code.value = arguments.code;
			stColumns.name.value = arguments.name;
			
			if(arguments.applicationID eq 0)
				arguments.applicationID = insertRecord(stColumns);
			else
				updateRecord(arguments.applicationID, stColumns);
		</cfscript>		
		
		<cfreturn arguments.applicationID>
	</cffunction>
	
</cfcomponent>