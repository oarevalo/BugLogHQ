<cfcomponent extends="finder">
	
	<cffunction name="findByID" returnType="entry" access="public">
		<cfargument name="id" type="numeric" required="true">
		<cfscript>
			var qry = variables.oDAO.get(arguments.id);
			var o = 0;
			
			if(qry.recordCount gt 0) {
				o = createObject("component","bugLog.components.entry").init( variables.oDAO );
				o.setEntryID(qry.entryID);
				o.setDateTime(qry.mydateTime);
				o.setMessage(qry.message);
				o.setApplicationID(qry.ApplicationID);
				o.setSourceID(qry.SourceID);
				o.setSeverityID(qry.SeverityID);
				o.setHostID(qry.HostID);
				o.setExceptionMessage(qry.exceptionMessage);
				o.setExceptionDetails(qry.exceptionDetails);
				o.setCFID(qry.cfid);
				o.setCFTOKEN(qry.cftoken);
				o.setUserAgent(qry.userAgent);
				o.setTemplatePath(qry.templatePath);
				o.setHTMLReport(qry.HTMLReport);
				return o;
			} else {
				throw("ID not found","entryFinderException.IDNotFound");
			}
		</cfscript>
	</cffunction>

	<cffunction name="search" returnType="query" access="public">
		<cfargument name="searchTerm" type="string" required="true">
		<cfargument name="applicationID" type="numeric" required="false" default="0">
		<cfargument name="hostID" type="numeric" required="false" default="0">
		<cfargument name="severityID" type="string" required="false" default="0">
		<cfargument name="startDate" type="date" required="false" default="1/1/1800">
		<cfargument name="endDate" type="date" required="false" default="1/1/3000">
		<cfargument name="search_cfid" type="string" required="false" default="">
		<cfargument name="search_cftoken" type="string" required="false" default="">
		
		<cfset var oDataProvider = variables.oDAO.getDataProvider()>
		<cfset var dbType = oDataProvider.getType()>
		<cfset var qry = 0>
	
		<!--- perform an optimized search for the current data provider --->
		<cfif dbType eq "xml">
			<cfset qry = searchForXML(argumentCollection = arguments)>
			
		<cfelseif dbType eq "db">
			<cfif oDataProvider.getConfig().getDBType() eq "MSAccess">
				<cfset qry = searchForXML(argumentCollection = arguments)>
			<cfelse>
				<cfset qry = searchForSQL(argumentCollection = arguments)>
			</cfif>

		<cfelse>
			<cfset qry = searchForSQL(argumentCollection = arguments)>
		</cfif>		
		
		<cfreturn qry>
	</cffunction>

	
	<cffunction name="searchForSQL" returntype="query" access="private">
		<cfargument name="searchTerm" type="string" required="true">
		<cfargument name="applicationID" type="numeric" required="false" default="0">
		<cfargument name="hostID" type="numeric" required="false" default="0">
		<cfargument name="severityID" type="string" required="false" default="0">
		<cfargument name="startDate" type="date" required="false" default="1/1/1800">
		<cfargument name="endDate" type="date" required="false" default="1/1/3000">
		<cfargument name="search_cfid" type="string" required="false" default="">
		<cfargument name="search_cftoken" type="string" required="false" default="">
		<cfargument name="searchHTMLReport" type="boolean" required="false" default="false">

		<cfset var tmpSQL = "">
		<cfset var oDataProvider = variables.oDAO.getDataProvider()>
		<cfset var dbType = oDataProvider.getConfig().getDBType()>
		<cfset var qry = 0>

		<cfif arguments.searchTerm neq "" and dbType eq "mysql">
			<cfset arguments.searchTerm = replace(arguments.searchTerm,"'","\'","ALL")>
		</cfif>

		<cfsavecontent variable="tmpSQL">
			<cfoutput>
			SELECT e.entryID, e.message, e.cfid, e.cftoken, e.mydateTime, e.exceptionMessage, e.exceptionDetails, 
					e.templatePath, e.userAgent, a.code as ApplicationCode, h.hostName, s.code AS SeverityCode,
					src.name AS SourceName, e.applicationID, e.hostID, e.severityID, e.sourceID, e.createdOn,
					<cfswitch expression="#dbType#">
						<cfcase value="mssql">
							datePart(year, e.mydateTime) as entry_year, 
							datePart(month, e.mydateTime) as entry_month, 
							datePart(day, e.mydateTime) as entry_day,
							datePart(hour, e.mydateTime) as entry_hour, 
							datePart(minute, e.mydateTime) as entry_minute
						</cfcase>
						<cfdefaultcase>
							year(e.mydateTime) as entry_year, 
							month(e.mydateTime) as entry_month, 
							day(e.mydateTime) as entry_day,
							hour(e.mydateTime) as entry_hour, 
							minute(e.mydateTime) as entry_minute
						</cfdefaultcase>
					</cfswitch>
				FROM bl_Entry e
					INNER JOIN bl_Application a ON e.applicationID = a.ApplicationID
					INNER JOIN bl_Host h ON e.hostID = h.hostID
					INNER JOIN bl_Severity s ON e.severityID = s.severityID
					INNER JOIN bl_Source src ON e.sourceID = src.SourceID
				WHERE (1=1)
					<cfif arguments.searchTerm neq "">
						AND (
							message LIKE '%#arguments.searchTerm#%'
							or
							exceptionMessage LIKE '%#arguments.searchTerm#%'
							or
							exceptionDetails LIKE '%#arguments.searchTerm#%'
							or
							templatePath LIKE '%#arguments.searchTerm#%'
							or
							userAgent LIKE '%#arguments.searchTerm#%'
							<cfif arguments.searchHTMLReport>
								or HTMLReport LIKE '%#arguments.searchTerm#%'
							</cfif>
						)
					</cfif>
					<cfif arguments.applicationID gt 0>
						AND e.applicationID = #arguments.applicationID# 
					</cfif>
					<cfif arguments.hostID gt 0>
						AND e.hostID = #arguments.hostID# 
					</cfif>
					<cfif arguments.severityID neq "" and arguments.severityID neq 0 and arguments.severityID neq "_ALL_">
						AND e.severityID IN (#arguments.severityID#) 
					</cfif>
					<cfif arguments.startDate neq "1/1/1800">
						AND mydateTime >= #arguments.startDate# 
					</cfif>
					<cfif arguments.endDate neq "1/1/3000">
						AND mydateTime <= #arguments.endDate#
					</cfif>
					<cfif arguments.search_cfid neq "">
						AND cfid LIKE '#arguments.search_cfid#%' 
					</cfif>
					<cfif arguments.search_cftoken neq "">
						AND cftoken LIKE '#arguments.search_cftoken#%' 
					</cfif>
				ORDER BY createdOn DESC, entryID DESC
			</cfoutput>
		</cfsavecontent>
		<cfset qry = oDataProvider.exec(tmpSQL)>
		<cfreturn qry>
	</cffunction>

	<cffunction name="searchForAccess" returntype="query" access="private">
		<cfargument name="searchTerm" type="string" required="true">
		<cfargument name="applicationID" type="numeric" required="false" default="0">
		<cfargument name="hostID" type="numeric" required="false" default="0">
		<cfargument name="severityID" type="string" required="false" default="0">
		<cfargument name="startDate" type="date" required="false" default="1/1/1800">
		<cfargument name="endDate" type="date" required="false" default="1/1/3000">
		<cfargument name="search_cfid" type="string" required="false" default="">
		<cfargument name="search_cftoken" type="string" required="false" default="">
		<cfargument name="searchHTMLReport" type="boolean" required="false" default="false">

		<cfset var tmpSQL = "">
		<cfset var oDataProvider = variables.oDAO.getDataProvider()>
		<cfset var qry = 0>
		
		<!--- Query modified for Access --->
		<cfsavecontent variable="tmpSQL">
			<cfoutput>
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
								bl_Application a INNER JOIN bl_Entry e
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
						message LIKE '%#arguments.searchTerm#%'
						or
						exceptionMessage LIKE '%#arguments.searchTerm#%'
						or
						exceptionDetails LIKE '%#arguments.searchTerm#%'
					)
				</cfif>
				<cfif arguments.applicationID gt 0>
					AND e.applicationID = #arguments.applicationID# 
				</cfif>
				<cfif arguments.hostID gt 0>
					AND e.hostID = #arguments.hostID# 
				</cfif>
				<cfif arguments.severityID gt 0>
					AND e.severityID = #arguments.severityID# 
				</cfif>
				<cfif arguments.startDate neq "1/1/1800">
					AND mydateTime >= '#arguments.startDate#' 
				</cfif>
				<cfif arguments.endDate neq "1/1/3000">
					AND mydateTime <= '#arguments.endDate#' 
				</cfif>
				<cfif arguments.search_cfid neq "">
					AND cfid LIKE '#arguments.search_cfid#%' 
				</cfif>
				<cfif arguments.search_cftoken neq "">
					AND cftoken LIKE '#arguments.search_cftoken#%' 
				</cfif>
			</cfoutput>
		</cfsavecontent>
		<cfset qry = oDataProvider.exec(tmpSQL)>
		
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

	<cffunction name="searchForXML" returnType="query" access="private">
		<cfargument name="searchTerm" type="string" required="true">
		<cfargument name="applicationID" type="numeric" required="false" default="0">
		<cfargument name="hostID" type="numeric" required="false" default="0">
		<cfargument name="severityID" type="string" required="false" default="0">
		<cfargument name="startDate" type="date" required="false" default="1/1/1800">
		<cfargument name="endDate" type="date" required="false" default="1/1/3000">
		<cfargument name="search_cfid" type="string" required="false" default="">
		<cfargument name="search_cftoken" type="string" required="false" default="">
		<cfargument name="searchHTMLReport" type="boolean" required="false" default="false">
		
		<cfset var qryEntries = 0>
		<cfset var qryHosts = 0>
		<cfset var qrySeverity = 0>
		<cfset var qryApplications = 0>
		<cfset var qrySources = 0>
		<cfset var oDataProvider = variables.oDAO.getDataProvider()>
		<cfset var stSearchParams = structNew()>

		<cfscript>
			if(arguments.applicationID gt 0) stSearchParams.applicationID = arguments.applicationID;
			if(arguments.hostID gt 0) stSearchParams.hostID = arguments.hostID;
			if(arguments.severityID neq "" and arguments.severityID neq 0 and arguments.severityID neq "_ALL_") stSearchParams.severityID = arguments.severityID;
			if(arguments.searchTerm neq "") stSearchParams.message = "%arguments.searchTerm%";
			if(arguments.search_cfid neq "") arguments.cfid = "arguments.search_cfid%";
			if(arguments.search_cftoken neq "") arguments.cftoken = "arguments.search_cftoken%";
		</cfscript>		

		<cfset qryEntries = variables.oDAO.search(argumentCollection = stSearchParams)>

		<cfset oHostDAO = createObject("component","bugLog.components.db.hostDAO").init( oDataProvider )>
		<cfset oSeverityDAO = createObject("component","bugLog.components.db.severityDAO").init( oDataProvider )>
		<cfset oApplicationDAO = createObject("component","bugLog.components.db.applicationDAO").init( oDataProvider )>
		<cfset oSourceDAO = createObject("component","bugLog.components.db.sourceDAO").init( oDataProvider )>

		<cfset qryHosts = oHostDAO.getAll()>		
		<cfset qrySeverity = oSeverityDAO.getAll()>		
		<cfset qryApplications = oApplicationDAO.getAll()>		
		<cfset qrySources = oSourceDAO.getAll()>		
		
		<cfquery name="qryEntries" dbtype="query">
			SELECT qryEntries.*, hostName FROM qryEntries, qryHosts WHERE CAST(qryHosts.HostID AS VARCHAR) = CAST(qryEntries.HostID AS VARCHAR)
		</cfquery>	

		<cfquery name="qryEntries" dbtype="query">
			SELECT qryEntries.*, code AS SeverityCode FROM qryEntries, qrySeverity WHERE CAST(qrySeverity.SeverityID AS VARCHAR) = CAST(qryEntries.SeverityID AS VARCHAR)
		</cfquery>	

		<cfquery name="qryEntries" dbtype="query">
			SELECT qryEntries.*, code as ApplicationCode FROM qryEntries, qryApplications WHERE CAST(qryApplications.ApplicationID AS VARCHAR) = CAST(qryEntries.ApplicationID AS VARCHAR)
		</cfquery>	

		<cfquery name="qryEntries" dbtype="query">
			SELECT qryEntries.*, name AS SourceName FROM qryEntries, qrySources WHERE CAST(qrySources.SourceID AS VARCHAR) = CAST(qryEntries.SourceID AS VARCHAR)
		</cfquery>	

		<cfquery name="qryEntries" dbtype="query">
			SELECT *
				FROM qryEntries
				WHERE (1=1)
				<cfif arguments.startDate neq "1/1/1800">
					AND mydateTime >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.startDate#"> 
				</cfif>
				<cfif arguments.endDate neq "1/1/3000">
					AND mydateTime <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.endDate#"> 
				</cfif>
		</cfquery>	

		<cfquery name="qryEntries" dbtype="query">
			SELECT *,
				   0 as entry_year,<!--- This is New Starting Value. --->
				   0 as entry_month,<!--- This is New Starting Value. --->
				   0 as entry_day,<!--- This is New Starting Value. --->
				   0 as entry_hour,<!--- This is New Starting Value. --->
				   0 as entry_minute<!--- This is New Starting Value. --->			
			FROM qryEntries
		</cfquery>
		
		<cfloop query="qryEntries">
			<cfscript>
				QuerySetCell(qryEntries, "entry_year", Year(qryEntries.mydateTime), CurrentRow);
				QuerySetCell(qryEntries, "entry_month", Month(qryEntries.mydateTime), CurrentRow);
				QuerySetCell(qryEntries, "entry_day", Day(qryEntries.mydateTime), CurrentRow);
				QuerySetCell(qryEntries, "entry_hour", Hour(qryEntries.mydateTime), CurrentRow);
				QuerySetCell(qryEntries, "entry_minute", Minute(qryEntries.mydateTime), CurrentRow);
			</cfscript>
		</cfloop>		
				
		<cfreturn qryEntries>
	</cffunction>
</cfcomponent>