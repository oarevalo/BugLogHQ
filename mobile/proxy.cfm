<cfparam name="action" default="">
<cfparam name="resetApp" default="false">

<cfset results = "">
<cfset error = false>
<cfset errorMessage = "">

<cfset args = form>
<cfset structAppend(args,url)>

<cftry>
	<cfset oAppService = application.appService>
	
	<cfset dateFormatMask = oAppService.getConfig().getSetting("general.dateFormat")>
	
	<cfswitch expression="#action#">
		
		<cfcase value="checkLogin">
			<cfparam name="args.username" default="">
			<cfparam name="args.password" default="">

			<cfset userID = oAppService.checkLogin(args.username, args.password)>

			<cfif userID gt 0>
				<cfset session.token = createUUID()>
				<cfset session.user = oAppService.getUserByID(userID)>
				<cfset results = session.token>
			<cfelse>
				<cfset results = "">
				<cfset structDelete(session,"token")>
				<cfset structDelete(session,"user")>
				<cfset error = true>
				<cfset errorMessage = "Invalid user/password">
			</cfif>		
		</cfcase>
	
		<cfcase value="getSummary">
			<cfparam name="args.numDays" default="1">
			<cfparam name="args.token" default="">
			<cfparam name="args.applicationID" default="0">
			<cfparam name="args.hostID" default="0">
			<cfparam name="args.severities" default="">
			
			<!--- validate token --->
			<cfif not validateToken(args.token)>
				<cfthrow message="Invalid token. Please login first" type="invalidToken">
			</cfif>
			
			<cfif args.severities eq "">
				<cfset args.severities = "_ALL_">
			</cfif>
			
			<!--- get listing --->
			<cfset qryEntries = oAppService.searchEntries(searchTerm = "",
															startDate = calculateStartDate(val(args.numDays)), 
															applicationID=val(args.applicationID),
															hostID=val(args.hostID),
															severityID=args.severities,
															user=session.user)>
			<cfquery name="qryEntries" dbtype="query">
				SELECT ApplicationCode, ApplicationID,  
						Message, COUNT(*) AS bugCount, MAX(createdOn) as createdOn, MAX(entryID) AS EntryID, MAX(severityCode) AS SeverityCode
					FROM qryEntries
					GROUP BY ApplicationCode, ApplicationID, Message
					ORDER BY createdOn DESC
			</cfquery>
			
			<cfsavecontent variable="results">
				<cfoutput query="qryEntries">
					<cfif qryEntries.message eq "">
						<cfset tmpMessage = "<em>No message</em>">
					<cfelse>		
						<cfset tmpMessage = HtmlEditFormat(qryEntries.message)>
					</cfif>
					<item>
						<ApplicationCode>#xmlFormat(qryEntries.ApplicationCode)#</ApplicationCode>
						<ApplicationID>#ApplicationID#</ApplicationID>
						<Message>#xmlFormat(tmpMessage)#</Message>
						<bugCount>#qryEntries.bugCount#</bugCount>
						<createdOn>#dateFormat(qryEntries.createdOn,dateFormatMask)# #lsTimeFormat(qryEntries.createdOn)#</createdOn>
						<EntryID>#qryEntries.entryID#</EntryID>
						<SeverityCode>#qryEntries.severityCode#</SeverityCode>
					</item>
				</cfoutput>
			</cfsavecontent>
		</cfcase>
	
		<cfcase value="getListing">
			<cfparam name="args.numDays" default="1">
			<cfparam name="args.token" default="">
			<cfparam name="args.applicationID" default="0">
			<cfparam name="args.hostID" default="0">
			<cfparam name="args.msgFromEntryID" default="">
			<cfparam name="args.searchTerm" default="">
			<cfparam name="args.startRow" default="1">
			<cfparam name="args.rowsPerPage" default="50">
			<cfparam name="args.message" default="">
			
			<!--- validate token --->
			<cfif not validateToken(args.token)>
				<cfthrow message="Invalid token. Please login first" type="invalidToken">
			</cfif>
			
			<!--- get listing --->
			<cfscript>
				// if we are passing an entryID, then get the message from there
				var  = "";
				if(val(args.msgFromEntryID) gt 0) {
					oEntry = oAppService.getEntry( args.msgFromEntryID );
					if(oEntry.getMessage() eq "")
						message = "__EMPTY__";
					else
						message = oEntry.getMessage();
				}				
			</cfscript>
			<cfset qryEntries = oAppService.searchEntries(searchTerm = args.searchTerm,
															startDate = calculateStartDate(val(args.numDays)), 
															applicationID=args.applicationID,
															hostID=args.hostID,
															message = message,
															user=session.user)>
			<cfquery name="qryEntries" dbtype="query">
				SELECT *
					FROM qryEntries
					ORDER BY createdOn DESC
			</cfquery>
			
			<cfsavecontent variable="results">
				<cfoutput query="qryEntries" maxrows="#args.rowsPerPage#" startrow="#args.startRow#">
					<cfif qryEntries.message eq "">
						<cfset tmpMessage = "<em>No message</em>">
					<cfelse>		
						<cfset tmpMessage = HtmlEditFormat(qryEntries.message)>
					</cfif>
					<item>
						<ApplicationCode>#xmlFormat(qryEntries.ApplicationCode)#</ApplicationCode>
						<ApplicationID>#ApplicationID#</ApplicationID>
						<HostName>#xmlFormat(qryEntries.hostname)#</HostName>
						<HostID>#qryEntries.hostid#</HostID>
						<Message>#xmlFormat(tmpMessage)#</Message>
						<createdOn>#dateFormat(qryEntries.createdOn,dateFormatMask)# #lsTimeFormat(qryEntries.createdOn)#</createdOn>
						<EntryID>#qryEntries.entryID#</EntryID>
						<SeverityCode>#qryEntries.severityCode#</SeverityCode>
					</item>
				</cfoutput>
			</cfsavecontent>
		</cfcase>	
	
		<cfcase value="getEntry">
			<cfparam name="args.entryID" default="0" type="numeric">
			<cfparam name="args.token" default="">
			
			<!--- validate token --->
			<cfif not validateToken(args.token)>
				<cfthrow message="Invalid token. Please login first" type="invalidToken">
			</cfif>
			
			<!--- get listing --->
			<cfset oEntry = oAppService.getEntry(args.entryID, session.user)>

			<cfif oEntry.getMessage() eq "">
				<cfset tmpMessage = "<em>No message</em>">
			<cfelse>		
				<cfset tmpMessage = HtmlEditFormat(oEntry.getMessage())>
			</cfif>

			<cfsavecontent variable="results">
				<cfoutput>
					<item>
						<ApplicationCode>#xmlFormat(oEntry.getApplication().getCode())#</ApplicationCode>
						<ApplicationID>#oEntry.getApplicationID()#</ApplicationID>
						<HostName>#xmlFormat(oEntry.getHost().getHostname())#</HostName>
						<HostID>#oEntry.getHostID()#</HostID>
						<Message>#xmlFormat(tmpMessage)#</Message>
						<createdOn>#dateFormat(oEntry.getDateTime(),dateFormatMask)# - #lsTimeFormat(oEntry.getDateTime())#</createdOn>
						<EntryID>#oEntry.getEntryID()#</EntryID>
						<SeverityCode>#oEntry.getSeverity().getCode()#</SeverityCode>
						<ExceptionMessage>#xmlFormat(htmlEditFormat(oEntry.getExceptionMessage()))#</ExceptionMessage>
						<ExceptionDetails>#xmlFormat(htmlCodeFormat(oEntry.getExceptionDetails()))#</ExceptionDetails>
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
			<cfparam name="args.token" default="">

			<!--- validate token --->
			<cfif not validateToken(args.token)>
				<cfthrow message="Invalid token. Please login first" type="invalidToken">
			</cfif>

			<cfset qryData = oAppService.getApplications(session.user)>

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
			<cfparam name="args.token" default="">

			<!--- validate token --->
			<cfif not validateToken(args.token)>
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
			<cfparam name="args.token" default="">

			<!--- validate token --->
			<cfif not validateToken(args.token)>
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
<cffunction name="calculateStartDate" access="private" returntype="date">
	<cfargument name="numDays" type="numeric" required="true">
	<cfscript>
		var startDate = now();
		if(numdays lt 1) 
			startDate = dateAdd("h", numDays * 24 * -1, now());
		else
			startDate = dateAdd("d", numDays * -1, now());
		return startDate;
	</cfscript>
</cffunction>
