<cfcomponent extends="bugLog.components.baseRule" 
			hint="This rule checks the amount of messages received on a given timespan and if the number of bugs received is greater than a given threshold, send an email alert">
	
	<cfproperty name="senderEmail" type="string" hint="An email address to use as sender of the email notifications">
	<cfproperty name="recipientEmail" type="string" hint="The email address to which to send the notifications">
	<cfproperty name="count" type="numeric" hint="The number of bugreports that will trigger the rule">
	<cfproperty name="timespan" type="numeric" hint="The number in minutes for which to count the amount of bug reports received">
	<cfproperty name="application" type="string" hint="The application name that will trigger the rule. Leave empty to look for all applications">
	<cfproperty name="host" type="string" hint="The host name that will trigger the rule. Leave empty to look for all hosts">
	<cfproperty name="severity" type="string" hint="The severity that will trigger the rule. Leave empty to look for all severities">
	<cfproperty name="sameMessage" type="boolean" hint="Set to True to counts only bug reports that have the same text on their message. Leave empty or False to count all messages">

	<cffunction name="init" access="public" returntype="bugLog.components.baseRule">
		<cfargument name="senderEmail" type="string" required="true">
		<cfargument name="recipientEmail" type="string" required="true">
		<cfargument name="count" type="numeric" required="true">
		<cfargument name="timespan" type="numeric" required="true">
		<cfargument name="application" type="string" required="false" default="">
		<cfargument name="host" type="string" required="false" default="">
		<cfargument name="severity" type="string" required="false" default="">
		<cfargument name="sameMessage" type="string" required="false" default="">
		<cfset variables.config.senderEmail = arguments.senderEmail>
		<cfset variables.config.recipientEmail = arguments.recipientEmail>
		<cfset variables.config.count = arguments.count>
		<cfset variables.config.timespan = arguments.timespan>
		<cfset variables.config.application = arguments.application>
		<cfset variables.config.host = arguments.host>
		<cfset variables.config.severity = arguments.severity>
		<cfset variables.config.sameMessage = arguments.sameMessage>
		<cfset variables.lastEmailTimestamp = createDateTime(1800,1,1,0,0,0)>
		<cfset variables.applicationID = -1>
		<cfset variables.hostID = -1>
		<cfset variables.severityID = -1>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="processRule" access="public" returnType="boolean">
		<cfargument name="rawEntry" type="bugLog.components.rawEntryBean" required="true">
		<cfargument name="dataProvider" type="bugLog.components.lib.dao.dataProvider" required="true">
		
		<cfscript>
			var qry = 0;
			var oEntryFinder = 0;
			var oEntryDAO = 0;
			var args = structNew();
			
			// only evaluate this rule if the amount of timespan minutes has passed after the last email was sent
			if( dateDiff("n", variables.lastEmailTimestamp, now()) gt variables.config.timespan ) {
			
				oEntryDAO = createObject("component","bugLog.components.db.entryDAO").init(arguments.dataProvider);
				oEntryFinder = createObject("component","bugLog.components.entryFinder").init(oEntryDAO);
	
				if(variables.config.application neq "" and variables.applicationID eq -1) {
					variables.applicationID = getApplicationID(arguments.dataProvider);
					if(variables.applicationID eq 0) variables.config.application = "";
				}
				if(variables.config.host neq "" and variables.hostID eq -1) {
					variables.hostID = getHostID(arguments.dataProvider);
					if(variables.hostID eq 0) variables.config.host = "";
				}
				if(variables.config.severity neq "" and variables.severityID eq -1) {
					variables.severityID = getSeverityID(arguments.dataProvider);
					if(variables.severityID eq 0) variables.config.severity = "";
				}
				
				args = structNew();
				args.searchTerm = "";
				args.startDate = dateAdd("n", variables.config.timespan * (-1), now() );
				args.endDate = now();
				if(variables.applicationID gt 0) args.applicationID = variables.applicationID;
				if(variables.hostID gt 0) args.hostID = variables.hostID;
				if(variables.severityID gt 0) args.severityID = variables.severityID;
	
				qry = oEntryFinder.search(argumentCollection = args);
	
				if(isBoolean(variables.config.sameMessage) and variables.config.sameMessage) {
					qry = groupMessages(qry, variables.config.count);
					sendEmail(qry);
		
				} else if(qry.recordCount gt variables.config.count) {
					sendEmail(qry);
				}
			}
			return true;
		</cfscript>
	</cffunction>

	<cffunction name="sendEmail" access="private" returntype="void" output="true">
		<cfargument name="data" type="query" required="true" hint="query with the bug report entries">
		<cfset var qryEntries = 0>
		
		<cfquery name="qryEntries" dbtype="query">
			SELECT ApplicationCode, ApplicationID, 
					HostName, HostID, 
					Message, COUNT(*) AS bugCount, MAX(createdOn) as createdOn, MAX(entryID) AS EntryID, MAX(severityCode) AS SeverityCode
				FROM arguments.data
				GROUP BY 
						ApplicationCode, ApplicationID, 
						HostName, HostID, 
						Message
				ORDER BY createdOn DESC
		</cfquery>
		
		<cfmail from="#variables.config.senderEmail#" 
				to="#variables.config.recipientEmail#"
				subject="BugLog: bug frequency alert!" 
				type="text/html">
			BugLog has received more than <strong>#variables.config.count#</strong> bug reports 
			<cfif variables.config.application neq "">
				for application <strong>#variables.config.application#</strong>
			</cfif>
			<cfif variables.config.host neq "">
				on host <strong>#variables.config.host#</strong>
			</cfif>
			<cfif variables.config.severity neq "">
				with a severity of <strong>#variables.config.severity#</strong>
			</cfif>
			on the last <strong>#variables.config.timespan#</strong> minutes.
			<br /><br />
			<cfloop query="qryEntries">
				<cfset tmpURL = "http://#cgi.HTTP_HOST#/bugLog/hq/index.cfm?event=ehGeneral.dspEntry&entryID=#qryEntries.EntryID#">
				&bull; <a href="#tmpURL#">[#qryEntries.severityCode#][#qryEntries.applicationCode#][#qryEntries.hostName#] #qryEntries.message# (#qryEntries.bugCount#)</a><br />
			</cfloop>
			<br /><br /><br />
			** This email has been sent from the BugLog server at 
			<a href="http://#cgi.HTTP_HOST#/bugLog/hq">http://#cgi.HTTP_HOST#/bugLog/hq</a>
		</cfmail>
		<cfset variables.lastEmailTimestamp = now()>
		
		<cfset writeToCFLog("frequencyAlert. Rule fired. Email sent.")>
	</cffunction>

	<cffunction name="getApplicationID" access="private" returntype="numeric">
		<cfargument name="dataProvider" type="bugLog.components.lib.dao.dataProvider" required="true">
		<cfset var oDAO = createObject("component","bugLog.components.db.applicationDAO").init(arguments.dataProvider)>
		<cfset var oFinder = createObject("component","bugLog.components.appFinder").init(oDAO)>
		<cfset var o = 0>
		<cftry>
			<cfset o = oFinder.findByCode(variables.config.application)>
			<cfreturn o.getApplicationID()>
			<cfcatch type="appFinderException.ApplicationCodeNotFound">
				<cfreturn 0>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getHostID" access="private" returntype="numeric">
		<cfargument name="dataProvider" type="bugLog.components.lib.dao.dataProvider" required="true">
		<cfset var oDAO = createObject("component","bugLog.components.db.hostDAO").init(arguments.dataProvider)>
		<cfset var oFinder = createObject("component","bugLog.components.hostFinder").init(oDAO)>
		<cfset var o = 0>
		<cftry>
			<cfset o = oFinder.findByName(variables.config.host)>
			<cfreturn o.getHostID()>
			<cfcatch type="hostFinderException.HostNameNotFound">
				<cfreturn 0>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getSeverityID" access="private" returntype="numeric">
		<cfargument name="dataProvider" type="bugLog.components.lib.dao.dataProvider" required="true">
		<cfset var oDAO = createObject("component","bugLog.components.db.severityDAO").init(arguments.dataProvider)>
		<cfset var oFinder = createObject("component","bugLog.components.severityFinder").init(oDAO)>
		<cfset var o = 0>
		<cftry>
			<cfset o = oFinder.findByCode(variables.config.severity)>
			<cfreturn o.getSeverityID()>
			<cfcatch type="severityFinderException.codeNotFound">
				<cfreturn 0>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="groupMessages" access="private" returntype="query">
		<cfargument name="data" type="query" required="true" hint="query with the bug report entries">
		<cfargument name="minCount" type="numeric" required="false" default="0" hint="When greater than 0, returns only messages whose count is greater than the given value">
		<cfset var qryEntries = 0>
		
		<cfquery name="qryEntries" dbtype="query">
			SELECT ApplicationCode, ApplicationID, 
					HostName, HostID, 
					SeverityCode, SeverityID,
					Message, COUNT(*) AS bugCount, MAX(createdOn) as createdOn, MAX(entryID) AS EntryID
				FROM arguments.data
				WHERE (1=1)
					<cfif variables.applicationID gt 0>
						AND applicationID = #variables.applicationID#
					</cfif>
					<cfif variables.hostID gt 0>
						AND hostID = #variables.hostID#
					</cfif>
					<cfif variables.severityID gt 0>
						AND SeverityID = #variables.SeverityID#
					</cfif>
				GROUP BY 
						ApplicationCode, ApplicationID, 
						HostName, HostID, 
						SeverityCode, SeverityID,
						Message
				ORDER BY createdOn DESC
		</cfquery>
		
		<cfif minCount gt 0>
			<cfquery name="qryEntries" dbtype="query">
				SELECT *
					FROM qryEntries
					WHERE bugCount > #arguments.minCount#
					ORDER BY createdOn DESC
			</cfquery>
		</cfif>
		
		<cfreturn qryEntries>
	</cffunction>

</cfcomponent>