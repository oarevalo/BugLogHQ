<cfcomponent extends="DAO">
	
	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset variables.tableName = "bl_Host">
		<cfset variables.PKName = "hostID">
		<cfset variables.LabelFieldName = "hostName">
		
		<cfset addColumn("hostName", "cf_sql_varchar")>

	</cffunction>
	
	<cffunction name="save" access="public" returntype="numeric">
		<cfargument name="hostID" type="numeric" required="true">
		<cfargument name="hostName" type="string" required="true">
		
		<cfscript>
			var stColumns = getColumnStruct();
			var arg = "";
			
			stColumns.hostName.value = arguments.hostName;
			
			if(arguments.hostID eq 0)
				arguments.hostID = insertRecord(stColumns);
			else
				updateRecord(arguments.hostID, stColumns);
		</cfscript>		
		
		<cfreturn arguments.hostID>
	</cffunction>
	
</cfcomponent>