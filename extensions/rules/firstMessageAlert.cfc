<cfcomponent extends="bugLog.components.baseRule" 
			displayName="First Message Alert"
			hint="This rule checks for the first time a given bug report is received on the last X minutes and send an email">
	
	<cfproperty name="recipientEmail" type="string" displayName="Recipient Email" hint="The email address to which to send the notifications">
	<cfproperty name="timespan" type="numeric" displayName="Timespan" hint="The number in minutes for which to count the amount of bug reports received">
	<cfproperty name="application" type="string" displayName="Application" hint="The application name that will trigger the rule. Leave empty to look for all applications">
	<cfproperty name="host" type="string" displayName="Host Name" hint="The host name that will trigger the rule. Leave empty to look for all hosts">
	<cfproperty name="severity" type="string" displayName="Severity Code" hint="The severity that will trigger the rule. Leave empty to look for all severities">

	<cffunction name="init" access="public" returntype="bugLog.components.baseRule">
		<cfargument name="recipientEmail" type="string" required="true">
		<cfargument name="timespan" type="numeric" required="true">
		<cfargument name="application" type="string" required="false" default="">
		<cfargument name="host" type="string" required="false" default="">
		<cfargument name="severity" type="string" required="false" default="">
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
		<cfargument name="configObj" type="bugLog.components.config" required="true">
		<cfscript>
			var qry = 0;
			var oEntryFinder = 0;
			var oEntryDAO = 0;
			var args = structNew();
			var sender = arguments.configObj.getSetting("general.adminEmail");
			
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
			args.searchTerm = "";
			args.message = arguments.rawEntry.getMessage();
			args.startDate = dateAdd("n", variables.config.timespan * (-1), now() );
			args.endDate = now();
			if(variables.applicationID gt 0) args.applicationID = variables.applicationID;
			if(variables.hostID gt 0) args.hostID = variables.hostID;
			if(variables.severityID gt 0) args.severityID = variables.severityID;

			qry = oEntryFinder.search(argumentCollection = args);
			
			if(qry.recordCount eq 1) {
				sendEmail(qry, rawEntry, sender);
			}
		
			return true;
		</cfscript>
	</cffunction>

	<cffunction name="sendEmail" access="private" returntype="void" output="true">
		<cfargument name="data" type="query" required="true" hint="query with the bug report entries">
		<cfargument name="rawEntry" type="bugLog.components.rawEntryBean" required="true">
		<cfargument name="sender" type="string" required="true" hint="the sender of the email">
		
		<cfset var q = arguments.data>
		<cfset var numHours = int(variables.config.timespan / 60)>
		<cfset var numMinutes = variables.config.timespan mod 60>

		<cfsavecontent variable="intro">
			<cfoutput>
				BugLog has received a new bug report 
				<cfif variables.config.application neq "">
					for application <strong>#variables.config.application#</strong>
				</cfif>
				<cfif variables.config.host neq "">
					on host <strong>#variables.config.host#</strong>
				</cfif>
				<cfif variables.config.severity neq "">
					with a severity of <strong>#variables.config.severity#</strong>
				</cfif>
				on the last 
				<b>
					<cfif numHours gt 0> #numHours# hour<cfif numHours gt 1>s</cfif> <cfif numMinutes gt 0> and </cfif></cfif>
					<cfif numMinutes gt 0> #numMinutes# minute<cfif numMinutes gt 1>s</cfif></cfif>
				</b>
				<br /><br />
				<cfset tmpURL = "http://#cgi.HTTP_HOST#/bugLog/hq/index.cfm?event=ehGeneral.dspEntry&entryID=#q.EntryID#">
				Bug Report URL: <a href="#tmpURL#">#tmpURL#</a>
				<br />
			</cfoutput>
		</cfsavecontent>			
		
		<cfset sendToEmail(rawEntryBean = arguments.rawEntry,
							sender = arguments.sender,
							recipient = variables.config.recipientEmail,
							subject= "BugLog: [First Message Alert][#q.ApplicationCode#][#q.hostName#] #q.message#", 
							comment = intro)>
		
		<cfset writeToCFLog("'firstMessageAlert' rule fired. Email sent. Msg: '#q.message#'")>
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

</cfcomponent>