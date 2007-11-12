<cfparam name="action" default="">

<cfset bugLogPath = "/bugLog">
<cfset results = "">
<cfset error = false>
<cfset errorMessage = "">

<cftry>
	<cfset oAppService = createObject("component","hq.components.services.appService").init(bugLogPath)>
	
	<cfswitch expression="#action#">
		
		<cfcase value="checkLogin">
			<cfparam name="username" default="">
			<cfparam name="password" default="">
	
			<cfset userID = oAppService.checkLogin(username, password)>
			
			<cfif userID gt 0>
				<cfset results = userID>
			<cfelse>
				<cfset error = true>
				<cfset errorMessage = "Invalid user/password">
			</cfif>		
		</cfcase>
	
	
		<cfcase value="getListing">
			<cfparam name="token" default="">
			
			<!--- to do: validate token --->
			
			<!--- get listing --->
			<cfset qryEntries = oAppService.searchEntries(searchTerm = "",startDate = dateAdd("d",now(),-1))>
			<cfquery name="qryEntries" dbtype="query">
				SELECT ApplicationCode, ApplicationID, HostName, HostID, 
						Message, COUNT(*) AS bugCount, MAX(createdOn) as createdOn, MAX(entryID) AS EntryID, MAX(severityCode) AS SeverityCode
					FROM qryEntries
					GROUP BY ApplicationCode, ApplicationID, HostName, HostID, Message
					ORDER BY createdOn DESC
			</cfquery>
			
			<cfsavecontent variable="results">
				<cfoutput query="qryEntries">
					<entry>
						<ApplicationCode>#qryEntries.ApplicationCode#</ApplicationCode>
						<ApplicationID>#ApplicationID#</ApplicationID>
						<HostName>#qryEntries.hostname#</HostName>
						<HostID>#qryEntries.hostid#</HostID>
						<Message>#qryEntries.message#</Message>
						<bugCount>#qryEntries.bugCount#</bugCount>
						<createdOn>#dateFormat(qryEntries.createdOn,"mm/dd/yyyy")# #lsTimeFormat(qryEntries.createdOn)#</createdOn>
						<EntryID>#qryEntries.entryID#</EntryID>
						<SeverityCode>#qryEntries.severityCode#</SeverityCode>
					</entry>
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

