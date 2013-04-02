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
		<cfset addColumn("CFID", "cf_sql_varchar")>
		<cfset addColumn("CFTOKEN", "cf_sql_varchar")>
		<cfset addColumn("UserAgent", "cf_sql_varchar")>
		<cfset addColumn("TemplatePath", "cf_sql_varchar")>
		<cfset addColumn("CreatedOn", "cf_sql_timestamp")>
		
		<cfif variables.oDataProvider.getConfig().getDBType() EQ "oracle">
			<cfset addColumn("exceptionDetails", "cf_sql_clob")>
			<cfset addColumn("HTMLReport", "cf_sql_clob")>
		<cfelse>
			<cfset addColumn("exceptionDetails", "cf_sql_varchar")>
			<cfset addColumn("HTMLReport", "cf_sql_varchar")>
		</cfif>
		
	</cffunction>

	<cffunction name="deleteByApplicationID" access="public" returntype="void" hint="Deletes all entries that belong to the given ApplicationID">
		<cfargument name="applicationID" type="numeric" required="true">
		<cfset var dsn = getDataProvider().getConfig().getDSN()>
		<cfset var username = getDataProvider().getConfig().getUsername()>
		<cfset var password = getDataProvider().getConfig().getPassword()>
		<cfquery name="qry" datasource="#dsn#" username="#username#" password="#password#">
			DELETE
				FROM #getTableName()#
				WHERE applicationID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.applicationID#">
		</cfquery>	
	</cffunction>

	<cffunction name="updateApplicationID" access="public" returntype="void" hint="Updates all entries that belong to the given ApplicationID to a new applicationID">
		<cfargument name="fromApplicationID" type="numeric" required="true">
		<cfargument name="toApplicationID" type="numeric" required="true">
		<cfset var dsn = getDataProvider().getConfig().getDSN()>
		<cfset var username = getDataProvider().getConfig().getUsername()>
		<cfset var password = getDataProvider().getConfig().getPassword()>
		<cfquery name="qry" datasource="#dsn#" username="#username#" password="#password#">
			UPDATE #getTableName()#
				SET applicationID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.toApplicationID#">
				WHERE applicationID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.fromApplicationID#">
		</cfquery>	
	</cffunction>

	<cffunction name="deleteByHostID" access="public" returntype="void" hint="Deletes all entries that belong to the given HostID">
		<cfargument name="HostID" type="numeric" required="true">
		<cfset var dsn = getDataProvider().getConfig().getDSN()>
		<cfset var username = getDataProvider().getConfig().getUsername()>
		<cfset var password = getDataProvider().getConfig().getPassword()>
		<cfquery name="qry" datasource="#dsn#" username="#username#" password="#password#">
			DELETE
				FROM #getTableName()#
				WHERE hostID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostID#">
		</cfquery>	
	</cffunction>

	<cffunction name="updateHostID" access="public" returntype="void" hint="Updates all entries that belong to the given HostID to a new HostID">
		<cfargument name="fromHostID" type="numeric" required="true">
		<cfargument name="toHostID" type="numeric" required="true">
		<cfset var dsn = getDataProvider().getConfig().getDSN()>
		<cfset var username = getDataProvider().getConfig().getUsername()>
		<cfset var password = getDataProvider().getConfig().getPassword()>
		<cfquery name="qry" datasource="#dsn#" username="#username#" password="#password#">
			UPDATE #getTableName()#
				SET hostID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.toHostID#">
				WHERE hostID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.fromHostID#">
		</cfquery>	
	</cffunction>

	<cffunction name="deleteBySeverityID" access="public" returntype="void" hint="Deletes all entries that belong to the given SeverityID">
		<cfargument name="severityID" type="numeric" required="true">
		<cfset var dsn = getDataProvider().getConfig().getDSN()>
		<cfset var username = getDataProvider().getConfig().getUsername()>
		<cfset var password = getDataProvider().getConfig().getPassword()>
		<cfquery name="qry" datasource="#dsn#" username="#username#" password="#password#">
			DELETE
				FROM #getTableName()#
				WHERE severityID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.severityID#">
		</cfquery>	
	</cffunction>

	<cffunction name="updateSeverityID" access="public" returntype="void" hint="Updates all entries that belong to the given SeverityID to a new SeverityID">
		<cfargument name="fromSeverityID" type="numeric" required="true">
		<cfargument name="toSeverityID" type="numeric" required="true">
		<cfset var dsn = getDataProvider().getConfig().getDSN()>
		<cfset var username = getDataProvider().getConfig().getUsername()>
		<cfset var password = getDataProvider().getConfig().getPassword()>
		<cfquery name="qry" datasource="#dsn#" username="#username#" password="#password#">
			UPDATE #getTableName()#
				SET severityID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.toSeverityID#">
				WHERE severityID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.fromSeverityID#">
		</cfquery>	
	</cffunction>

</cfcomponent>
