<cfcomponent extends="DAO">
	
	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset variables.tableName = "bl_Entry">
		<cfset variables.PKName = "entryID">
		<cfset variables.LabelFieldName = "EntryID">
		
		<cfset addColumn("dateTime", "cf_sql_timestamp")>
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

	</cffunction>
	
	<cffunction name="save" access="public" returntype="numeric">
		<cfargument name="dateTime" type="Date" required="true">
		<cfargument name="message" type="string" required="true">
		<cfargument name="applicationID" type="string" required="true">
		<cfargument name="sourceID" type="numeric" required="true">
		<cfargument name="severityID" type="numeric" required="true">
		<cfargument name="hostID" type="numeric" required="true">
		<cfargument name="exceptionMessage" type="string" required="true">
		<cfargument name="exceptionDetails" type="string" required="true">
		<cfargument name="CFID" type="string" required="true">
		<cfargument name="CFTOKEN" type="string" required="true">
		<cfargument name="userAgent" type="string" required="true">
		<cfargument name="templatePath" type="string" required="true">
		<cfargument name="HTMLReport" type="string" required="true">

		<cfscript>
			 var stColumns = getColumnStruct();
			 var arg = "";
			 var rtn = 0;
			
			for(arg in arguments) {
				if(arg neq "entryID") stColumns[arg].value = arguments[arg];
			}
			
			rtn = insertRecord(stColumns);
		</cfscript>		
		
		<cfreturn rtn>
	</cffunction>
	
	<cffunction name="search" returnType="query" access="public">
		<cfargument name="searchTerm" type="string" required="true">
		<cfargument name="applicationID" type="numeric" required="false" default="0">
		<cfargument name="hostID" type="numeric" required="false" default="0">
		<cfargument name="severityID" type="numeric" required="false" default="0">
		<cfargument name="startDate" type="date" required="false" default="1/1/1800">
		<cfargument name="endDate" type="date" required="false" default="1/1/3000">
		<cfargument name="search_cfid" type="string" required="false" default="">
		<cfargument name="search_cftoken" type="string" required="false" default="">

		<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			SELECT e.entryID, e.message, e.cfid, e.cftoken, e.dateTime, e.exceptionMessage, e.exceptionDetails, 
					e.templatePath, e.userAgent, a.code as ApplicationCode, h.hostName, s.code AS SeverityCode,
					src.name AS SourceName, e.applicationID, e.hostID, e.severityID, e.sourceID, e.createdOn,
					year(e.dateTime) as entry_year, month(e.dateTime) as entry_month, day(e.dateTime) as entry_day,
					hour(e.dateTime) as entry_hour, minute(e.dateTime) as entry_minute
				FROM #variables.tableName# e
					INNER JOIN bl_Application a ON e.applicationID = a.ApplicationID
					INNER JOIN bl_Host h ON e.hostID = h.hostID
					INNER JOIN bl_Severity s ON e.severityID = s.severityID
					INNER JOIN bl_Source src ON e.sourceID = src.SourceID
				WHERE (1=1)
					<cfif arguments.searchTerm neq "">
						AND (
							message LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchTerm#%">
							or
							exceptionMessage LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchTerm#%">
							or
							exceptionDetails LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchTerm#%">
						)
					</cfif>
					<cfif arguments.applicationID gt 0>
						AND e.applicationID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.applicationID#"> 
					</cfif>
					<cfif arguments.hostID gt 0>
						AND e.hostID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostID#"> 
					</cfif>
					<cfif arguments.severityID gt 0>
						AND e.severityID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.severityID#"> 
					</cfif>
					<cfif arguments.startDate neq "1/1/1800">
						AND dateTime >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.startDate#"> 
					</cfif>
					<cfif arguments.endDate neq "1/1/3000">
						AND dateTime <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.endDate#"> 
					</cfif>
					<cfif arguments.search_cfid neq "">
						AND cfid LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.search_cfid#%"> 
					</cfif>
					<cfif arguments.search_cftoken neq "">
						AND cftoken LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.search_cftoken#%"> 
					</cfif>
				ORDER BY createdOn DESC, entryID DESC
			</cfquery>
		<cfreturn qry>
	</cffunction>	
	
</cfcomponent>