<cfparam name="action" default="">

<cfset bugLogPath = "/bugLog">
<cfset results = "">
<cfset error = false>
<cfset errorMessage = "">

<cftry>
	<cfset oConfig = createObject("component","bugLog.components.config").init(configProviderType = "xml", configDoc = "/bugLog/config/buglog-config.xml.cfm")>
	<cfset oAppService = createObject("component","bugLog.hq.components.services.appService").init(bugLogPath,oConfig)>
	
	<cfset dateFormatMask = oConfig.getSetting("general.dateFormat")>
	
	<cfswitch expression="#action#">
		
		<cfcase value="checkLogin">
			<cfparam name="username" default="">
			<cfparam name="password" default="">
	
			<cfset userID = oAppService.checkLogin(username, password)>
			<cfset session.token = createUUID()>
			
			<cfif userID gt 0>
				<cfset results = session.token>
			<cfelse>
				<cfset error = true>
				<cfset errorMessage = "Invalid user/password">
			</cfif>		
		</cfcase>
	
		<cfcase value="getSummary">
			<cfparam name="numDays" default="1">
			<cfparam name="token" default="">
			<cfparam name="applicationID" default="0">
			<cfparam name="hostID" default="0">
			<cfparam name="severities" default="">
			
			<!--- validate token --->
			<cfif not validateToken(token)>
				<cfthrow message="Invalid token. Please login first" type="invalidToken">
			</cfif>
			
			<cfif severities eq "">
				<cfset severities = "_ALL_">
			</cfif>
			
			<!--- get listing --->
			<cfset qryEntries = oAppService.searchEntries(searchTerm = "",
															startDate = dateAdd("d",-1 * val(numDays),now()), 
															applicationID=val(applicationID),
															hostID=val(hostID),
															severityID=severities)>
			<cfquery name="qryEntries" dbtype="query">
				SELECT ApplicationCode, ApplicationID,  
						Message, COUNT(*) AS bugCount, MAX(createdOn) as createdOn, MAX(entryID) AS EntryID, MAX(severityCode) AS SeverityCode
					FROM qryEntries
					GROUP BY ApplicationCode, ApplicationID, Message
					ORDER BY createdOn DESC
			</cfquery>
			
			<cfsavecontent variable="results">
				<cfoutput query="qryEntries">
					<item>
						<ApplicationCode>#xmlFormat(qryEntries.ApplicationCode)#</ApplicationCode>
						<ApplicationID>#ApplicationID#</ApplicationID>
						<Message>#xmlFormat(qryEntries.message)#</Message>
						<bugCount>#qryEntries.bugCount#</bugCount>
						<createdOn>#dateFormat(qryEntries.createdOn,dateFormatMask)# #lsTimeFormat(qryEntries.createdOn)#</createdOn>
						<EntryID>#qryEntries.entryID#</EntryID>
						<SeverityCode>#qryEntries.severityCode#</SeverityCode>
					</item>
				</cfoutput>
			</cfsavecontent>
		</cfcase>
	
		<cfcase value="getListing">
			<cfparam name="numDays" default="1">
			<cfparam name="token" default="">
			<cfparam name="applicationID" default="0">
			<cfparam name="hostID" default="0">
			<cfparam name="msgFromEntryID" default="">
			<cfparam name="searchTerm" default="">
			<cfparam name="startRow" default="1">
			<cfparam name="rowsPerPage" default="50">
			
			<!--- validate token --->
			<cfif not validateToken(token)>
				<cfthrow message="Invalid token. Please login first" type="invalidToken">
			</cfif>
			
			<!--- get listing --->
			<cfscript>
				// if we are passing an entryID, then get the message from there
				if(val(msgFromEntryID) gt 0) {
					oEntry = oAppService.getEntry( msgFromEntryID );
					searchTerm = oEntry.getMessage();
				}				
			</cfscript>
			<cfset qryEntries = oAppService.searchEntries(searchTerm = searchTerm,
															startDate = dateAdd("d",-1 * val(numDays),now()), 
															applicationID=applicationID,
															hostID=hostID)>
			<cfquery name="qryEntries" dbtype="query">
				SELECT *
					FROM qryEntries
					ORDER BY createdOn DESC
			</cfquery>
			
			<cfsavecontent variable="results">
				<cfoutput query="qryEntries" maxrows="#rowsPerPage#" startrow="#startRow#">
					<item>
						<ApplicationCode>#xmlFormat(qryEntries.ApplicationCode)#</ApplicationCode>
						<ApplicationID>#ApplicationID#</ApplicationID>
						<HostName>#xmlFormat(qryEntries.hostname)#</HostName>
						<HostID>#qryEntries.hostid#</HostID>
						<Message>#xmlFormat(qryEntries.message)#</Message>
						<createdOn>#dateFormat(qryEntries.createdOn,dateFormatMask)# #lsTimeFormat(qryEntries.createdOn)#</createdOn>
						<EntryID>#qryEntries.entryID#</EntryID>
						<SeverityCode>#qryEntries.severityCode#</SeverityCode>
					</item>
				</cfoutput>
			</cfsavecontent>
		</cfcase>	
	
		<cfcase value="getEntry">
			<cfparam name="entryID" default="0" type="numeric">
			<cfparam name="token" default="">
			
			<!--- validate token --->
			<cfif not validateToken(token)>
				<cfthrow message="Invalid token. Please login first" type="invalidToken">
			</cfif>
			
			<!--- get listing --->
			<cfset oEntry = oAppService.getEntry(entryID)>

			<cfsavecontent variable="results">
				<cfoutput>
					<item>
						<ApplicationCode>#xmlFormat(oEntry.getApplication().getCode())#</ApplicationCode>
						<ApplicationID>#oEntry.getApplicationID()#</ApplicationID>
						<HostName>#xmlFormat(oEntry.getHost().getHostname())#</HostName>
						<HostID>#oEntry.getHostID()#</HostID>
						<Message>#xmlFormat(oEntry.getMessage())#</Message>
						<createdOn>#dateFormat(oEntry.getDateTime(),dateFormatMask)# - #lsTimeFormat(oEntry.getDateTime())#</createdOn>
						<EntryID>#oEntry.getEntryID()#</EntryID>
						<SeverityCode>#oEntry.getSeverity().getCode()#</SeverityCode>
						<ExceptionMessage>#xmlFormat(oEntry.getExceptionMessage())#</ExceptionMessage>
						<ExceptionDetails>#xmlFormat(oEntry.getExceptionDetails())#</ExceptionDetails>
						<BugCFID>#xmlFormat(oEntry.getCFID())#</BugCFID>
						<BugCFTOKEN>#xmlFormat(oEntry.getCFTOKEN())#</BugCFTOKEN>
						<UserAgent>#xmlFormat(oEntry.getUserAgent())#</UserAgent>
						<TemplatePath>#xmlFormat(oEntry.getTemplate_Path())#</TemplatePath>
						<HTMLReport>#xmlFormat(oEntry.getHTMLReport())#</HTMLReport>
					</item>
				</cfoutput>
			</cfsavecontent>
		</cfcase>	
	
		<cfcase value="getApplications">
			<!--- validate token --->
			<cfif not validateToken(token)>
				<cfthrow message="Invalid token. Please login first" type="invalidToken">
			</cfif>

			<cfset qryData = oAppService.getApplications()>

			<cfquery name="qryData" dbtype="query">
				SELECT *, upper(code) as u_code
					FROM qryData
					ORDER BY u_code
			</cfquery>

			<cfsavecontent variable="results">
				<cfoutput query="qryData">
					<item>
						<appID>#ApplicationID#</appID>
						<appCode>#xmlFormat(qryData.code)#</appCode>
					</item>
				</cfoutput>
			</cfsavecontent>
		</cfcase>

		<cfcase value="getHosts">
			<!--- validate token --->
			<cfif not validateToken(token)>
				<cfthrow message="Invalid token. Please login first" type="invalidToken">
			</cfif>

			<cfset qryData = oAppService.getHosts()>

			<cfquery name="qryData" dbtype="query">
				SELECT *, upper(HostName) as u_host
					FROM qryData
					ORDER BY u_host
			</cfquery>

			<cfsavecontent variable="results">
				<cfoutput query="qryData">
					<item>
						<hostID>#xmlFormat(qryData.HostID)#</hostID>
						<hostName>#HostName#</hostName>
					</item>
				</cfoutput>
			</cfsavecontent>
		</cfcase>

		<cfcase value="getSeverities">
			<!--- validate token --->
			<cfif not validateToken(token)>
				<cfthrow message="Invalid token. Please login first" type="invalidToken">
			</cfif>

			<cfset qryData = oAppService.getSeverities()>

			<cfsavecontent variable="results">
				<cfoutput query="qryData">
					<item>
						<severityID>#qryData.SeverityID#</severityID>
						<code>#xmlFormat(code)#</code>
						<name>#xmlFormat(name)#</name>
					</item>
				</cfoutput>
			</cfsavecontent>
		</cfcase>
	
		<cfdefaultcase>
			<cfset error = true>
			<cfset errorMessage = "Unknown action">
		</cfdefaultcase>
	
	</cfswitch>
	
	<cfcatch type="any">
		<cfset error = true>
		<cfset errorMessage = cfcatch.Message & cfcatch.Detail>
	</cfcatch>
</cftry>

<cfoutput>
	<cfxml variable="xmlDoc">
		<bugLogData>
			<action>#xmlFormat(action)#</action>
			<error>#error#</error>
			<errorMessage>#xmlFormat(errorMessage)#</errorMessage>
			<results>#results#</results>
		</bugLogData>
	</cfxml>
</cfoutput>

<cfcontent type="text/xml" reset="true"><cfoutput>#toString(xmlDoc)#</cfoutput>

<cffunction name="validateToken" access="private" returntype="boolean">
	<cfargument name="token" type="string" required="true">
	<cfreturn structKeyExists(session,"token") and session.token eq arguments.token>
</cffunction>