<cfcomponent extends="bugLog.components.baseRule" 
			hint="This rule checks the amount of messages received on a given timespan and if the number of bugs received is greater than a given threshold, send an email alert">
	
	<cfproperty name="recipientEmail" type="string" buglogType="email" displayName="Recipient Email" hint="The email address to which to send the notifications">
	<cfproperty name="count" type="numeric" displayName="Count" hint="The number of bugreports that will trigger the rule">
	<cfproperty name="timespan" type="numeric" displayName="Timespan" hint="The number in minutes for which to count the amount of bug reports received">
	<cfproperty name="application" type="string" displayName="Application" buglogType="application" hint="The application name that will trigger the rule. Leave empty to look for all applications">
	<cfproperty name="host" type="string" displayName="Host Name" buglogType="host" hint="The host name that will trigger the rule. Leave empty to look for all hosts">
	<cfproperty name="severity" type="string" displayName="Severity Code" buglogType="severity" hint="The severity that will trigger the rule. Leave empty to look for all severities">
	<cfproperty name="sameMessage" type="boolean" displayName="Same Message?" hint="Set to True to counts only bug reports that have the same text on their message. Leave empty or False to count all messages">
	<cfproperty name="oneTimeAlertRecipient" type="string" hint="An email address to receive a one time short notification. This is sent only up to once per day.">
	
	<cfset variables.lastEmailTimestamp = createDateTime(1800,1,1,0,0,0)>
	<cfset variables.lastOneTimeEmailTimestamp = createDateTime(1800,1,1,0,0,0)>

	<cffunction name="init" access="public" returntype="bugLog.components.baseRule">
		<cfargument name="recipientEmail" type="string" required="true">
		<cfargument name="count" type="numeric" required="true">
		<cfargument name="timespan" type="numeric" required="true">
		<cfargument name="application" type="string" required="false" default="">
		<cfargument name="host" type="string" required="false" default="">
		<cfargument name="severity" type="string" required="false" default="">
		<cfargument name="sameMessage" type="string" required="false" default="">
		<cfargument name="oneTimeAlertRecipient" type="string" required="false" default="">
		<cfscript>
			arguments.sameMessage = (isBoolean(arguments.sameMessage) && arguments.sameMessage);
			super.init(argumentCollection = arguments);
			return this;
		</cfscript>		
	</cffunction>
	
	<cffunction name="matchCondition" access="public" returntype="boolean" hint="Returns true if the entry bean matches a custom condition">
		<cfargument name="entry" type="bugLog.components.entry" required="true">
		<cfscript>
			var matches = false;
			var oEntryDAO = getDAOFactory().getDAO("entry");
			var oEntryFinder = createObject("component","bugLog.components.entryFinder").init(oEntryDAO);

			// only evaluate this rule if the amount of timespan minutes has passed after the last email was sent
			if( dateDiff("n", variables.lastEmailTimestamp, now()) gt variables.config.timespan ) {

				var args = {
					startDate = dateAdd("n", variables.config.timespan * (-1), now() ),
					endDate = now()
				};

				for(var key in structKeyArray(scope)) {
					var ids = [];
					for(var item in scope[key]["items"]) {
						ids.add( scope[key]["items"][item] );
					}
					if(arrayLen(ids)) {
						args[key & "id"] = (scope[key]["not_in"] ? "-" : "") & listToArray(ids)
					}
				}

				var qry = oEntryFinder.search(argumentCollection = args);

				if(qry.recordCount gt 0) {
					if(variables.sameMessage) {
						qry = groupMessages(qry, variables.config.count);
						
						if(qry.recordCount gt 0) {
							matches = true;
						}
			
					} else if(qry.recordCount gt variables.config.count) {
						matches = true;
					}
				}
			}

			return matches;
		</cfscript>
	</cffunction>

	<cffunction name="doAction" access="public" returntype="boolean" hint="Performs an action when the entry matches the scope and conditions">
		<cfargument name="entry" type="bugLog.components.entry" required="true">
		<cfscript>
			sendEmail(qry);
			sendAlert(qry);
			return true;
		</cfscript>
	</cffunction>
<!----
	<cffunction name="processRule" access="public" returnType="boolean">
		<cfargument name="rawEntry" type="bugLog.components.rawEntryBean" required="true">
		<cfargument name="entry" type="bugLog.components.entry" required="true">
		<cfscript>
			var qry = 0;
			var oEntryFinder = 0;
			var oEntryDAO = 0;
			var args = structNew();
			
			// only evaluate this rule if the amount of timespan minutes has passed after the last email was sent
			if( dateDiff("n", variables.lastEmailTimestamp, now()) gt variables.config.timespan ) {
			
				oEntryDAO = getDAOFactory().getDAO("entry");
				oEntryFinder = createObject("component","bugLog.components.entryFinder").init(oEntryDAO);
	
				if(variables.config.application neq "" and (variables.applicationID eq ID_NOT_SET or variables.applicationID eq ID_NOT_FOUND)) {
					variables.applicationID = getApplicationID();
				}
				if(variables.config.host neq "" and (variables.hostID eq ID_NOT_SET or variables.hostID eq ID_NOT_FOUND)) {
					variables.hostID = getHostID();
				}
				if(variables.config.severity neq "" and (variables.severityID eq ID_NOT_SET or variables.severityID eq ID_NOT_FOUND)) {
					variables.severityID = getSeverityID();
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
							logTrigger(entry);
							sendEmail(qry);
							sendAlert(qry);
						}
			
					} else if(qry.recordCount gt variables.config.count) {
						logTrigger(entry);
						sendEmail(qry);
						sendAlert(qry);
					}
				}
			
			}
			return true;
		</cfscript>
	</cffunction>
--->
	<cffunction name="sendEmail" access="private" returntype="void" output="true">
		<cfargument name="data" type="query" required="true" hint="query with the bug report entries">
		<cfset var qryEntries = 0>
		<cfset var bugReportURL = "">
		<cfset var intro = "">
		
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
		
		<cfsavecontent variable="intro">
			<cfoutput>
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
					<cfset bugReportURL = getBugEntryHREF(qryEntries.EntryID) />
					&bull; <a href="#bugReportURL#">[#qryEntries.severityCode#][#qryEntries.applicationCode#][#qryEntries.hostName#] #qryEntries.message# <cfif !variables.sameMessage>(#qryEntries.bugCount#)</cfif></a><br />
				</cfloop>
			</cfoutput>
		</cfsavecontent>

		<cfset sendToEmail(recipient = variables.config.recipientEmail,
							subject= "BugLog: bug frequency alert!", 
							comment = intro)>

		<cfset variables.lastEmailTimestamp = now()>
		
		<cfset writeToCFLog("'frequencyAlert' rule fired. Email sent.")>
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
		
			<cfset sendToEmail(recipient = variables.config.oneTimeAlertRecipient,
								subject= "BugLog: Frequency alert", 
								comment = msg)>
		
			<cfset variables.lastOneTimeEmailTimestamp = now()>
			
			<cfset writeToCFLog("'frequencyAlert' rule fired. One-time alert sent.")>
		</cfif>
	</cffunction>
	
	<cffunction name="explain" access="public" returntype="string">
		<cfset var rtn = "Sends an alert ">
		<cfif variables.config.recipientEmail  neq "">
			<cfset rtn &= " to <b>#variables.config.recipientEmail#</b>">
		</cfif>
		<cfif variables.config.oneTimeAlertRecipient neq "">
			<cfset rtn &= " (and once per day to <b>#variables.config.oneTimeAlertRecipient#</b>)">
		</cfif>
		<cfset rtn &= " when receiving more than <b>#variables.config.count#</b> report<cfif variables.config.count gt 1>s</cfif>">
		<cfif variables.config.timespan  neq "">
			<cfset rtn &= " within the last <b>#variables.config.timespan#</b> minute<cfif variables.config.timespan gt 1>s</cfif>">
		</cfif>
		<cfif variables.config.application  neq "">
			<cfset rtn &= " from application <b>#variables.config.application#</b>">
		</cfif>
		<cfif variables.config.severity  neq "">
			<cfset rtn &= " with a severity of <b>#variables.config.severity#</b>">
		</cfif>
		<cfif variables.config.host  neq "">
			<cfset rtn &= " from host <b>#variables.config.host#</b>">
		</cfif>
		<cfreturn rtn>
	</cffunction>	
	
</cfcomponent>
