<cfcomponent extends="DAO">
	
	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset variables.tableName = "bl_Entry">
		<cfset variables.PKName = "entryID">
		<cfset variables.LabelFieldName = "EntryID">
		
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

	</cffunction>
	
	<cffunction name="save" access="public" returntype="numeric">
		<cfargument name="mydateTime" type="Date" required="true">
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

	<!--- Thanks to Chuck Weidler for providing the code for the query to work with all supported databases (including access) --->	
	<cffunction name="search" returntype="query" access="public">
		<cfargument name="searchTerm" type="string" required="true">
		<cfargument name="applicationID" type="numeric" required="false" default="0">
		<cfargument name="hostID" type="numeric" required="false" default="0">
		<cfargument name="severityID" type="numeric" required="false" default="0">
		<cfargument name="startDate" type="date" required="false" default="1/1/1800">
		<cfargument name="endDate" type="date" required="false" default="1/1/3000">
		<cfargument name="search_cfid" type="string" required="false" default="">
		<cfargument name="search_cftoken" type="string" required="false" default="">
		
		<!--- Query modified for Access --->
		<cfquery name="qry" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			SELECT e.entryID,
				   e.message,
				   e.cfid,
				   e.cftoken,
				   e.mydateTime,
				   e.exceptionMessage,
				   e.exceptionDetails,
				   e.templatePath,
				   e.userAgent,
				   a.code as ApplicationCode,
				   h.hostName,
				   s.code AS SeverityCode,
				   src.name AS SourceName,
				   e.applicationID,
				   e.hostID,
				   e.severityID,
				   e.sourceID,
				   e.createdOn,
				   0 as entry_year,<!--- This is New Starting Value. --->
				   0 as entry_month,<!--- This is New Starting Value. --->
				   0 as entry_day,<!--- This is New Starting Value. --->
				   0 as entry_hour,<!--- This is New Starting Value. --->
				   0 as entry_minute<!--- This is New Starting Value. --->
				   
			<!--- The From Clause has been redone for use with Access Database. --->
			FROM bl_Source src INNER JOIN 
				(
					bl_Severity s INNER JOIN 
					(
						bl_Host h INNER JOIN 
						(
							bl_Application a INNER JOIN #variables.tableName# e
							ON a.ApplicationID = e.ApplicationID
						)
						ON h.HostID = e.HostID
					)
					ON s.SeverityID = e.SeverityID
				)
				ON src.SourceID = e.SourceID
			
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
				AND mydateTime >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.startDate#"> 
			</cfif>
			<cfif arguments.endDate neq "1/1/3000">
				AND mydateTime <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.endDate#"> 
			</cfif>
			<cfif arguments.search_cfid neq "">
				AND cfid LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.search_cfid#%"> 
			</cfif>
			<cfif arguments.search_cftoken neq "">
				AND cftoken LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.search_cftoken#%"> 
			</cfif>
		</cfquery>
		
		<!--- 
			This is New.
			Since not all Databases have the aggregate functions of Hour and Minute,
			let ColdFusion do the that part.
		 --->
		<cfloop query="qry">
			<cfscript>
				QuerySetCell(qry, "entry_year", Year(qry.mydateTime), CurrentRow);
				QuerySetCell(qry, "entry_month", Month(qry.mydateTime), CurrentRow);
				QuerySetCell(qry, "entry_day", Day(qry.mydateTime), CurrentRow);
				QuerySetCell(qry, "entry_hour", Hour(qry.mydateTime), CurrentRow);
				QuerySetCell(qry, "entry_minute", Minute(qry.mydateTime), CurrentRow);
			</cfscript>
		</cfloop>
		
		<cfreturn qry>
	</cffunction>
	
</cfcomponent>