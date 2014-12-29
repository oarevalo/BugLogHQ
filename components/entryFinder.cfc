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
				o.setCreatedOn(qry.createdOn);
				o.setUUID(qry.UUID);
				return o;
			} else {
				throw("ID not found","entryFinderException.IDNotFound");
			}
		</cfscript>
	</cffunction>

	<cffunction name="search" returntype="query" access="public">
		<cfargument name="searchTerm" type="string" required="true">
		<cfargument name="applicationID" type="string" required="false" default="0">
		<cfargument name="hostID" type="string" required="false" default="0">
		<cfargument name="severityID" type="string" required="false" default="0">
		<cfargument name="startDate" type="date" required="false" default="1/1/1800">
		<cfargument name="endDate" type="date" required="false" default="1/1/3000">
		<cfargument name="search_cfid" type="string" required="false" default="">
		<cfargument name="search_cftoken" type="string" required="false" default="">
		<cfargument name="searchHTMLReport" type="boolean" required="false" default="false">
		<cfargument name="message" type="string" required="false" default="">
		<cfargument name="applicationCode" type="string" required="false" default="">
		<cfargument name="hostName" type="string" required="false" default="">
		<cfargument name="severityCode" type="string" required="false" default="">
		<cfargument name="userAgent" type="string" required="false" default="">
		<cfargument name="userID" type="numeric" required="false" default="0">
		<cfargument name="UUID" type="string" required="false" default="">
		<cfargument name="groupByMsg" type="boolean" required="false" default="false" />
		<cfargument name="groupByApp" type="boolean" required="false" default="false" />
		<cfargument name="groupByHost" type="boolean" required="false" default="false" />

		<cfset var oDataProvider = variables.oDAO.getDataProvider()>
		<cfset var dbType = oDataProvider.getConfig().getDBType()>
		<cfset var qry = 0>
		<cfset var dsn = oDataProvider.getConfig().getDSN()>
		<cfset var tmpMessage = ''>
		<cfset var applyGroupings = (groupByHost or groupByApp or groupByMsg) />

		<cfif arguments.searchTerm neq "">
			<cfif dbType eq "mysql">
				<cfset arguments.searchTerm = replace(arguments.searchTerm,"'","\'","ALL")>
			<cfelse>
				<cfset arguments.searchTerm = replace(arguments.searchTerm,"'","''","ALL")>
			</cfif>
		</cfif>

		<cfquery name="qry" datasource="#dsn#">
			<cfif applyGroupings>
				SELECT 
					<cfif groupByApp>ApplicationCode, ApplicationID, </cfif>
					<cfif groupByHost>HostName, HostID, </cfif>
					<cfif groupByMsg>Message, </cfif>
					COUNT(entryID) AS bugCount, 
					MAX(createdOn) as createdOn, 
					MAX(entryID) AS EntryID, 
					MAX(severityCode) AS SeverityCode
				FROM (		
			</cfif>
			SELECT e.entryID, e.message, e.cfid, e.cftoken, e.mydateTime, e.exceptionMessage, e.exceptionDetails, 
					e.templatePath, e.userAgent, a.code as ApplicationCode, h.hostName, s.code AS SeverityCode,
					src.name AS SourceName, e.applicationID, e.hostID, e.severityID, e.sourceID, e.createdOn, e.UUID,
					<cfswitch expression="#dbType#">
						<cfcase value="mssql">
							datePart(year, e.createdOn) as entry_year, 
							datePart(month, e.createdOn) as entry_month, 
							datePart(day, e.createdOn) as entry_day,
							datePart(hour, e.createdOn) as entry_hour, 
							datePart(minute, e.createdOn) as entry_minute
						</cfcase>
						<cfcase value="pgsql">
							date_part('year', e.createdOn) as entry_year, 
							date_part('month', e.createdOn) as entry_month,
							date_part('day', e.createdOn) as entry_day,
							date_part('hour', e.createdOn) as entry_hour, 
							date_part('minute', e.createdOn) as entry_minute
						</cfcase>
						<cfcase value="oracle">
							extract(year from e.createdOn) as entry_year, 
							extract(month from e.createdOn) as entry_month, 
							extract(day from e.createdOn) as entry_day,
							extract(hour from e.createdOn) as entry_hour, 
							extract(minute from e.createdOn) as entry_minute
						</cfcase>
						<cfdefaultcase>
							year(e.createdOn) as entry_year, 
							month(e.createdOn) as entry_month, 
							day(e.createdOn) as entry_day,
							hour(e.createdOn) as entry_hour, 
							minute(e.createdOn) as entry_minute
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
							message LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchTerm#%"> 
							or
							exceptionMessage LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchTerm#%"> 
							or
							exceptionDetails LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchTerm#%"> 
							or
							templatePath LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchTerm#%"> 
							or
							userAgent LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchTerm#%"> 
							<cfif arguments.searchHTMLReport>
								or HTMLReport LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchTerm#%"> 
							</cfif>
						)
					</cfif>
					<cfif arguments.message neq "">
						<cfif arguments.message eq "__EMPTY__">
							AND NULLIF(message,'') IS NULL
						<cfelse>
							<cfset tmpMessage = arguments.message>
							<cfif dbtype eq "mssql">
								<cfset tmpMessage = replace(replace(tmpMessage,"[","[[]",'all'),"''","'", "all")>
							</cfif>
							AND message LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#tmpMessage#">
						</cfif>
					</cfif>
					<cfif arguments.applicationID neq "" and arguments.applicationID neq 0 and arguments.applicationID neq "_ALL_">
						AND e.applicationID <cfif left(arguments.applicationID,1) eq "-"><cfset arguments.applicationID = removechars(arguments.applicationID,1,1)>NOT</cfif> IN 
    						(<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.applicationID#" list="true">)
					</cfif>
					<cfif arguments.applicationCode neq "">
						AND a.code = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.applicationCode#">
					</cfif>
					<cfif arguments.hostID neq "" and arguments.hostID neq 0 and arguments.hostID neq "_ALL_">
						AND e.hostID <cfif left(arguments.hostID,1) eq "-"><cfset arguments.hostID = removechars(arguments.hostID,1,1)>NOT</cfif> IN
                            (<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostID#" list="true">)
					</cfif>
					<cfif arguments.hostName neq "">
						AND h.hostName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.hostName#">
					</cfif>
					<cfif arguments.severityID neq "" and arguments.severityID neq 0 and arguments.severityID neq "_ALL_">
						AND e.severityID <cfif left(arguments.severityID,1) eq "-"><cfset arguments.severityID = removechars(arguments.severityID,1,1)>NOT</cfif> IN
                            (<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.severityID#" list="true">)
					</cfif>
					<cfif arguments.severityCode neq "">
						AND s.code = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.severityCode#">
					</cfif>
					<cfif arguments.startDate neq "1/1/1800">
						AND e.createdOn >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.startDate#">
					</cfif>
					<cfif arguments.endDate neq "1/1/3000">
						AND e.createdOn <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.endDate#">
					</cfif>
					<cfif arguments.search_cfid neq "">
						AND cfid LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.search_cfid#%">
					</cfif>
					<cfif arguments.search_cftoken neq "">
						AND cftoken LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.search_cftoken#%"> 
					</cfif>
					<cfif arguments.userAgent neq "">
						AND userAgent LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userAgent#"> 
					</cfif>
					<cfif arguments.userID gt 0>
						AND e.applicationID IN (
							SELECT applicationID 
								FROM bl_UserApplication
								WHERE userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.userID#">
						)
					</cfif>
					<cfif arguments.UUID neq "">
						AND e.UUID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.UUID#">
					</cfif>
			<cfif applyGroupings>
				) a
				GROUP BY
					<cfif groupByApp>ApplicationCode, ApplicationID, </cfif>
					<cfif groupByHost>HostName, HostID, </cfif>
					<cfif groupByMsg>Message </cfif>
			</cfif>
			ORDER BY createdOn DESC, entryID DESC
		</cfquery>

		<cfreturn qry>
	</cffunction>

</cfcomponent>
