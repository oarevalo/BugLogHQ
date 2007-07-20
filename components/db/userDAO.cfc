<cfcomponent extends="DAO">
	
	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset variables.tableName = "bl_User">
		<cfset variables.PKName = "UserID">
		<cfset variables.LabelFieldName = "Username">
		
		<cfset addColumn("Username", "cf_sql_varchar")>
		<cfset addColumn("Password", "cf_sql_varchar")>

	</cffunction>
	
	<cffunction name="save" access="public" returntype="numeric">
		<cfargument name="userID" type="numeric" required="true">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		
		<cfscript>
			var stColumns = getColumnStruct();
			var arg = "";
			
			stColumns.username.value = arguments.hostName;
			stColumns.password.value = arguments.password;
			
			if(arguments.userID eq 0)
				arguments.userID = insertRecord(stColumns);
			else
				updateRecord(arguments.userID, stColumns);
		</cfscript>		
		
		<cfreturn arguments.userID>
	</cffunction>
	
</cfcomponent>