<cfcomponent extends="bugLog.components.baseRule" 
			hint="This rule checks the amount of messages received on a given timespan and if the number of bugs received is greater than a given threshold, send an email alert">
	
	<cfproperty name="recipientEmail" type="string" displayName="Recipient Email" hint="The email address to which to send the notifications">
	<cfproperty name="count" type="numeric" displayName="Count" hint="The number of bugreports that will trigger the rule">
	<cfproperty name="timespan" type="numeric" displayName="Timespan" hint="The number in minutes for which to count the amount of bug reports received">
	<cfproperty name="application" type="string" displayName="Application" hint="The application name that will trigger the rule. Leave empty to look for all applications">
	<cfproperty name="host" type="string" displayName="Host Name" hint="The host name that will trigger the rule. Leave empty to look for all hosts">
	<cfproperty name="severity" type="string" displayName="Severity Code" hint="The severity that will trigger the rule. Leave empty to look for all severities">
	<cfproperty name="sameMessage" type="boolean" displayName="Same Message?" hint="Set to True to counts only bug reports that have the same text on their message. Leave empty or False to count all messages">
	<cfproperty name="oneTimeAlertRecipient" type="string" hint="An email address to receive a one time short notification. This is sent only up to once per day.">

	<cfset ID_NOT_SET = -9999999 />
	<cfset ID_NOT_FOUND = -9999990 />

	<cffunction name="init" access="public" returntype="bugLog.components.baseRule">
		<cfargument name="recipientEmail" type="string" required="true">
		<cfargument name="count" type="numeric" required="true">
		<cfargument name="timespan" type="numeric" required="true">
		<cfargument name="application" type="string" required="false" default="">
		<cfargument name="host" type="string" required="false" default="">
		<cfargument name="severity" type="string" required="false" default="">
		<cfargument name="sameMessage" type="string" required="false" default="">
		<cfargument name="oneTimeAlertRecipient" type="string" required="false" default="">
		<cfset variables.config.recipientEmail = arguments.recipientEmail>
		<cfset variables.config.count = arguments.count>
		<cfset variables.config.timespan = arguments.timespan>
		<cfset variables.config.application = arguments.application>
		<cfset variables.config.host = arguments.host>
		<cfset variables.config.severity = arguments.severity>
		<cfset variables.config.sameMessage = arguments.sameMessage>
		<cfset variables.config.oneTimeAlertRecipient = arguments.oneTimeAlertRecipient>
		<cfset variables.lastEmailTimestamp = createDateTime(1800,1,1,0,0,0)>
		<cfset variables.lastOneTimeEmailTimestamp = createDateTime(1800,1,1,0,0,0)>
		<cfset variables.applicationID = ID_NOT_SET>
		<cfset variables.hostID = ID_NOT_SET>
		<cfset variables.severityID = ID_NOT_SET>
		<cfset variables.sameMessage = (isBoolean(variables.config.sameMessage) and variables.config.sameMessage)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="processRule" access="public" returnType="boolean">
		<cfargument name="rawEntry" type="bugLog.components.rawEntryBean" required="true">
		<cfargument name="dataProvider" type="bugLog.components.lib.dao.dataProvider" required="true">
		<cfargument name="configObj" type="bugLog.components.config" required="true">
		<cfscript>
			var qry = 0;
			var oEntryFinder = 0;
			var oEntryDAO = 0;
			var args = structNew();
			var sender = arguments.configObj.getSetting("general.adminEmail");
			
			// only evaluate this rule if the amount of timespan minutes has passed after the last email was sent
			if( dateDiff("n", variables.lastEmailTimestamp, now()) gt variables.config.timespan ) {
			
				oEntryDAO = createObject("component","bugLog.components.db.entryDAO").init(arguments.dataProvider);
				oEntryFinder = createObject("component","bugLog.components.entryFinder").init(oEntryDAO);
	
				if(variables.config.application neq "" and (variables.applicationID eq ID_NOT_SET or variables.applicationID eq ID_NOT_FOUND)) {
					variables.applicationID = getApplicationID(arguments.dataProvider);
				}
				if(variables.config.host neq "" and (variables.hostID eq ID_NOT_SET or variables.hostID eq ID_NOT_FOUND)) {
					variables.hostID = getHostID(arguments.dataProvider);
				}
				if(variables.config.severity neq "" and (variables.severityID eq ID_NOT_SET or variables.severityID eq ID_NOT_FOUND)) {
					variables.severityID = getSeverityID(arguments.dataProvider);
				}
				
				args = structNew();
				args.searchTerm = "";
				args.startDate = dateAdd("n", variables.config.timespan * (-1), now() );
				args.endDate = now();
				if(variables.applicationID neq ID_NOT_SET) args.applicationID = variables.applicationID;
				if(variables.hostID neq ID_NOT_SET) args.hostID = variables.hostID;
				if(variables.severityID neq ID_NOT_SET) args.severityID = variables.severityID;

				qry = oEntryFinder.search(argumentCollection = args);

				if(qry.recordCount gt 0) {
					if(variables.sameMessage) {
						qry = groupMessages(qry, variables.config.count);
						
						if(qry.recordCount gt 0) {
							sendEmail(qry, sender);
							sendAlert(qry, sender);
						}
			
					} else if(qry.recordCount gt variables.config.count) {
						sendEmail(qry, sender);
						sendAlert(qry, sender);
					}
				}
			
			}
			return true;
		</cfscript>
	</cffunction>

	<cffunction name="sendEmail" access="private" returntype="void" output="true">
		<cfargument name="data" type="query" required="true" hint="query with the bug report entries">
		<cfargument name="sender" type="string" required="true" hint="the sender of the email">
		<cfset var qryEntries = 0>
		<cfset var thisHost = "">

		<cfscript>
			if(cgi.server_port_secure) thisHost = "https://"; else thisHost = "http://";
			thisHost = thisHost & cgi.server_name;
			if(cgi.server_port neq 80) thisHost = thisHost & ":" & cgi.server_port;
		</cfscript>
		
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
		
		<cfif variables.config.recipientEmail neq "" and arguments.sender neq "">
			<cfmail from="#arguments.sender#" 
					to="#variables.config.recipientEmail#"
					subject="BugLog: bug frequency alert!" 
					type="text/html">
				BugLog has received more than <strong>#variables.config.count#</strong> bug reports 
				<cfif variables.sameMessage>
					<strong>with the same message</strong>
				</cfif>
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
					<cfset tmpURL = thisHost & "/bugLog/hq/index.cfm?event=ehGeneral.dspEntry&entryID=#qryEntries.EntryID#">
					&bull; <a href="#tmpURL#">[#qryEntries.severityCode#][#qryEntries.applicationCode#][#qryEntries.hostName#] #qryEntries.message# <cfif !variables.sameMessage>(#qryEntries.bugCount#)</cfif></a><br />
				</cfloop>
				<br /><br /><br />
				** This email has been sent from the BugLog server at 
				<a href="#thisHost#/bugLog/hq">#thisHost#/bugLog/hq</a>
			</cfmail>
		</cfif>

		<cfset variables.lastEmailTimestamp = now()>
		
		<cfset writeToCFLog("'frequencyAlert' rule fired. Email sent.")>
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
				<cfreturn ID_NOT_FOUND>
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
				<cfreturn ID_NOT_FOUND>
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
				<cfreturn ID_NOT_FOUND>
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

	<cffunction name="sendAlert" access="private" returntype="void" output="true">
		<cfargument name="data" type="query" required="true" hint="query with the bug report entries">
		<cfargument name="sender" type="string" required="true" hint="the sender of the email">
		<cfset var qryEntries = 0>
		<cfset var msg = "">
		
		<cfif variables.config.oneTimeAlertRecipient neq "" 
				and dateDiff("n", variables.lastOneTimeEmailTimestamp, now()) gt 60*24>
			
			<cfset msg = "BugLog has received more than #variables.config.count# bug reports ">
			<cfif variables.config.application neq "">
				<cfset msg = msg & "for application #variables.config.application# ">
			</cfif>
			<cfif variables.config.host neq "">
				<cfset msg = msg & "on host #variables.config.host# ">
			</cfif>
			<cfif variables.config.severity neq "">
				<cfset msg = msg & "with a severity of #variables.config.severity# ">
			</cfif>
			<cfset msg = msg & "on the last #variables.config.timespan# minutes.">
		
			<cfmail from="#arguments.sender#" 
					to="#variables.config.oneTimeAlertRecipient#"
					subject="BugLog: Frequency alert" 
					type="text">#msg#</cfmail>
			<cfset variables.lastOneTimeEmailTimestamp = now()>
			
			<cfset writeToCFLog("'frequencyAlert' rule fired. One-time alert sent.")>
		</cfif>
	</cffunction>
	
</cfcomponent>