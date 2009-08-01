<cfcomponent extends="bugLog.components.baseRule" 
			hint="This rule checks for the first time a given bug report is received on the last X minutes and send an email">
	
	<cfproperty name="senderEmail" type="string" hint="An email address to use as sender of the email notifications">
	<cfproperty name="recipientEmail" type="string" hint="The email address to which to send the notifications">
	<cfproperty name="timespan" type="numeric" hint="The number in minutes for which to count the amount of bug reports received">
	<cfproperty name="application" type="string" hint="The application name that will trigger the rule. Leave empty to look for all applications">
	<cfproperty name="host" type="string" hint="The host name that will trigger the rule. Leave empty to look for all hosts">
	<cfproperty name="severity" type="string" hint="The severity that will trigger the rule. Leave empty to look for all severities">

	<cffunction name="init" access="public" returntype="bugLog.components.baseRule">
		<cfargument name="senderEmail" type="string" required="true">
		<cfargument name="recipientEmail" type="string" required="true">
		<cfargument name="timespan" type="numeric" required="true">
		<cfargument name="application" type="string" required="false" default="">
		<cfargument name="host" type="string" required="false" default="">
		<cfargument name="severity" type="string" required="false" default="">
		<cfset variables.config.senderEmail = arguments.senderEmail>
		<cfset variables.config.recipientEmail = arguments.recipientEmail>
		<cfset variables.config.timespan = arguments.timespan>
		<cfset variables.config.application = arguments.application>
		<cfset variables.config.host = arguments.host>
		<cfset variables.config.severity = arguments.severity>
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
			var qryCheck = 0;
			
			// check fast fail conditions
			if(variables.config.application neq "" and arguments.rawEntry.getApplicationCode() neq variables.config.application) return true;
			if(variables.config.host neq "" and arguments.rawEntry.getHostName() neq variables.config.host) return true;
			if(variables.config.severity neq "" and arguments.rawEntry.getSeverityCode() neq variables.config.severity) return true;

			// get necessary IDs
			if(variables.config.application neq "" and variables.applicationID eq -1) {
				variables.applicationID = getApplicationID(arguments.dataProvider);
			}
			if(variables.config.host neq "" and variables.hostID eq -1) {
				variables.hostID = getHostID(arguments.dataProvider);
			}
			if(variables.config.severity neq "" and variables.severityID eq -1) {
				variables.severityID = getSeverityID(arguments.dataProvider);
			}

			
			oEntryDAO = createObject("component","bugLog.components.db.entryDAO").init(arguments.dataProvider);
			oEntryFinder = createObject("component","bugLog.components.entryFinder").init(oEntryDAO);

			
			args = structNew();
			args.searchTerm = arguments.rawEntry.getMessage();
			args.startDate = dateAdd("n", variables.config.timespan * (-1), now() );
			args.endDate = now();
			if(variables.applicationID gt 0) args.applicationID = variables.applicationID;
			if(variables.hostID gt 0) args.hostID = variables.hostID;
			if(variables.severityID gt 0) args.severityID = variables.severityID;

			qry = oEntryFinder.search(argumentCollection = args);
			qryCheck = groupMessages(qry);
			
			if(qryCheck.recordCount eq 1 and qryCheck.bugCount[1] eq 1) {
				sendEmail(qry);
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
				subject="BugLog: [First Message Alert] #qryEntries.message#" 
				type="text/html">
			BugLog has received new bug report 
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
				&bull; <a href="#tmpURL#">[#qryEntries.severityCode#][#qryEntries.applicationCode#][#qryEntries.hostName#] #qryEntries.message#</a><br />
			</cfloop>
			<br /><br /><br />
			** This email has been sent from the BugLog server at 
			<a href="http://#cgi.HTTP_HOST#/bugLog/hq">http://#cgi.HTTP_HOST#/bugLog/hq</a>
		</cfmail>
		
		<cfset writeToCFLog("firstMessageAlert. Rule fired. Email sent.")>
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

	<cffunction name="getNewMessages" access="private" returntype="query">
		<cfargument name="data" type="query" required="true" hint="query with the bug report entries">
		<cfset var qryEntries = arguments.data>
		
		<cfif variables.lastEntryID gt 0>
			<cfquery name="qryEntries" dbtype="query">
				SELECT *
					FROM qryEntries
					WHERE entryID > #variables.lastEntryID#
					ORDER BY createdOn DESC
			</cfquery>
		</cfif>
		
		<cfreturn qryEntries>
	</cffunction>

	<cffunction name="groupMessages" access="private" returntype="query">
		<cfargument name="data" type="query" required="true" hint="query with the bug report entries">
		<cfset var qryEntries = 0>
		
		<cfquery name="qryEntries" dbtype="query">
			SELECT Message, COUNT(*) AS bugCount, MAX(createdOn) as createdOn, MAX(entryID) AS EntryID
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
				GROUP BY Message
				ORDER BY createdOn DESC
		</cfquery>
		
		<cfreturn qryEntries>
	</cffunction>

</cfcomponent>