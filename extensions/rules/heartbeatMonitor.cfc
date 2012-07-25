<cfcomponent extends="bugLog.components.baseRule" 
			displayName="Heartbeat Monitor"
			hint="This rule checks if we have received a matching message in X minutes. If not, an alert is sent.">

	<cfproperty name="recipientEmail" type="string" buglogType="email" displayName="Recipient Email" hint="The email address to which to send the notifications">
	<cfproperty name="timespan" type="numeric" displayName="Timespan" hint="The number in minutes to wait for a matching message">
	<cfproperty name="application" type="string" buglogType="application" displayName="Application" hint="The application name that will trigger the rule. Leave empty to look for all applications">
	<cfproperty name="host" type="string" buglogType="host" displayName="Host Name" hint="The host name that will trigger the rule. Leave empty to look for all hosts">
	<cfproperty name="severity" type="string" buglogType="severity" displayName="Severity Code" hint="The severity that will trigger the rule. Leave empty to look for all severities">
	<cfproperty name="alertInterval" type="numeric" displayName="Alert Interval" hint="The number of minutes to wait between alert messages">

	<cffunction name="init" access="public" returntype="bugLog.components.baseRule">
		<cfargument name="recipientEmail" type="string" required="true">
		<cfargument name="timespan" type="numeric" required="true">
		<cfargument name="application" type="string" required="false" default="">
		<cfargument name="host" type="string" required="false" default="">
		<cfargument name="severity" type="string" required="false" default="">
		<cfargument name="alertInterval" type="string" required="false" default="">
		<cfset variables.config.recipientEmail = arguments.recipientEmail>
		<cfset variables.config.timespan = arguments.timespan>
		<cfset variables.config.application = arguments.application>
		<cfset variables.config.host = arguments.host>
		<cfset variables.config.severity = arguments.severity>
		<cfset variables.config.alertInterval = val(arguments.alertInterval)>
		<cfset variables.applicationID = -1>
		<cfset variables.hostID = -1>
		<cfset variables.severityID = -1>
		<cfset variables.lastEmailTimestamp = createDateTime(1800,1,1,0,0,0)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="processQueueEnd" access="public" returntype="boolean" hint="This method gets called AFTER each processing of the queue (only invoked when using the asynch listener)">
		<cfargument name="queue" type="array" required="true">
		<cfargument name="dataProvider" type="bugLog.components.lib.dao.dataProvider" required="true">
		<cfargument name="configObj" type="bugLog.components.config" required="true">
		<cfscript>
			var qry = 0;
			var oEntryFinder = 0;
			var oEntryDAO = 0;
			var args = structNew();
			var sender = arguments.configObj.getSetting("general.adminEmail");
	
			// only evaluate this rule if 'alertInterval' minutes has passed after the last email was sent
			if( dateDiff("n", variables.lastEmailTimestamp, now()) gt variables.config.alertInterval ) {

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
				args.startDate = dateAdd("n", variables.config.timespan * (-1), now() );
				args.endDate = now();
				if(variables.applicationID gt 0) args.applicationID = variables.applicationID;
				if(variables.hostID gt 0) args.hostID = variables.hostID;
				if(variables.severityID gt 0) args.severityID = variables.severityID;
	
				qry = oEntryFinder.search(argumentCollection = args);
				
				if(qry.recordCount eq 0) {
					sendEmail(sender);
					variables.lastEmailTimestamp = now();
				}
				
			}
			
			return true;
		</cfscript>
	</cffunction>

	<cffunction name="sendEmail" access="private" returntype="void" output="true">
		<cfargument name="sender" type="string" required="true" hint="the sender of the email">
		
		<cfset var numHours = int(variables.config.timespan / 60)>
		<cfset var numMinutes = variables.config.timespan mod 60>

		<cfsavecontent variable="intro">
			<cfoutput>
				BugLog has <b>NOT</b> received a report 
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
				<br />
				It is possible that the monitored application is not functioning correctly.
				<br />
			</cfoutput>
		</cfsavecontent>			
		
		<cfset sendToEmail(sender = arguments.sender,
							recipient = variables.config.recipientEmail,
							subject= "BugLog: [Heartbeat Monitor Alert][#variables.config.application#][#variables.config.host#]", 
							comment = intro)>
		
		<cfset writeToCFLog("'heartbeatMonitor' rule fired. Email sent. [#variables.config.application#][#variables.config.host#]")>
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