<cfcomponent extends="DAO">
	
	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset variables.tableName = "bl_Source">
		<cfset variables.PKName = "sourceID">
		<cfset variables.LabelFieldName = "name">
		
		<cfset addColumn("name", "cf_sql_varchar")>

	</cffunction>
	
	<cffunction name="save" access="public" returntype="numeric">
		<cfargument name="sourceID" type="numeric" required="true">
		<cfargument name="name" type="string" required="true">
		
		<cfscript>
			var stColumns = getColumnStruct();
			var arg = "";
			
			for(arg in arguments) {
				stColumns[arg].value = arguments[arg];
			}
			
			if(arguments.sourceID eq 0)
				arguments.sourceID = insertRecord(stColumns);
			else
				updateRecord(arguments.sourceID, stColumns);
		</cfscript>		
		
		<cfreturn arguments.sourceID>
	</cffunction>
	
</cfcomponent>