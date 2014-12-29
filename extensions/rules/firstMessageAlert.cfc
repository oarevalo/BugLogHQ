<cfcomponent extends="bugLog.components.baseRule" 
			displayName="First Message Alert"
			hint="This rule checks for the first time a given bug report is received on the last X minutes and send an email">
	
	<cfproperty name="recipientEmail" type="string" buglogType="email" displayName="Recipient Email" hint="The email address to which to send the notifications">
	<cfproperty name="timespan" type="numeric" displayName="Timespan" hint="The number in minutes for which to count the amount of bug reports received">
	<cfproperty name="application" type="string" buglogType="application" displayName="Application" hint="The application name that will trigger the rule. Leave empty to look for all applications">
	<cfproperty name="host" type="string" buglogType="host" displayName="Host Name" hint="The host name that will trigger the rule. Leave empty to look for all hosts">
	<cfproperty name="severity" type="string" buglogType="severity" displayName="Severity Code" hint="The severity that will trigger the rule. Leave empty to look for all severities">
	<cfproperty name="includeHTMLReport" type="boolean" displayName="Include HTML Report?" hint="When enabled, the HTML Report section of the bug report is included in the email body">

	<cfset variables.lastEmailTimestamp = createDateTime(1800,1,1,0,0,0)>

	<cffunction name="init" access="public" returntype="bugLog.components.baseRule">
		<cfargument name="recipientEmail" type="string" required="true">
		<cfargument name="timespan" type="string" required="true">
		<cfargument name="application" type="string" required="false" default="">
		<cfargument name="host" type="string" required="false" default="">
		<cfargument name="severity" type="string" required="false" default="">
		<cfargument name="includeHTMLReport" type="string" required="false" default="">
		<cfscript>
			arguments.timespan = val(arguments.timespan);
			arguments.includeHTMLReport = (isBoolean(arguments.includeHTMLReport) && arguments.includeHTMLReport);
			super.init(argumentCollection = arguments);
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="matchCondition" access="public" returntype="boolean" hint="Returns true if the entry bean matches a custom condition">
		<cfargument name="entry" type="bugLog.components.entry" required="true">
		<cfscript>
			var oEntryDAO = getDAOFactory().getDAO("entry");
			var oEntryFinder = createObject("component","bugLog.components.entryFinder").init(oEntryDAO);

			var args = {
				message = arguments.rawEntry.getMessage(),
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

			return (qry.recordCount == 1 
					|| (qry.recordCount > 1 
						&& dateDiff("n", variables.lastEmailTimestamp, now()) > variables.config.timespan));
		</cfscript>		
	</cffunction>

	<cffunction name="doAction" access="public" returntype="boolean" hint="Performs an action when the entry matches the scope and conditions">
		<cfargument name="entry" type="bugLog.components.entry" required="true">
		<cfscript>
			sendEmail(qry, entry);
			variables.lastEmailTimestamp = now();
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
			
			// check fast fail conditions
			if(variables.config.application neq "" and arguments.rawEntry.getApplicationCode() neq variables.config.application) return true;
			if(variables.config.host neq "" and arguments.rawEntry.getHostName() neq variables.config.host) return true;
			if(variables.config.severity neq "" and arguments.rawEntry.getSeverityCode() neq variables.config.severity) return true;

			// get necessary IDs
			if(variables.config.application neq "" and (variables.applicationID eq ID_NOT_SET or variables.applicationID eq ID_NOT_FOUND)) {
				variables.applicationID = getApplicationID();
			}
			if(variables.config.host neq "" and (variables.hostID eq ID_NOT_SET or variables.hostID eq ID_NOT_FOUND)) {
				variables.hostID = getHostID();
			}
			if(variables.config.severity neq "" and (variables.severityID eq ID_NOT_SET or variables.severityID eq ID_NOT_FOUND)) {
				variables.severityID = getSeverityID();
			}

			
			oEntryDAO = getDAOFactory().getDAO("entry");
			oEntryFinder = createObject("component","bugLog.components.entryFinder").init(oEntryDAO);

			
			args = structNew();
			args.searchTerm = "";
			args.message = arguments.rawEntry.getMessage();
			args.startDate = dateAdd("n", variables.config.timespan * (-1), now() );
			args.endDate = now();
			if(variables.applicationID neq ID_NOT_SET) args.applicationID = variables.applicationID;
			if(variables.hostID neq ID_NOT_SET) args.hostID = variables.hostID;
			if(variables.severityID neq ID_NOT_SET) args.severityID = variables.severityID;

			qry = oEntryFinder.search(argumentCollection = args);
			
			if(qry.recordCount eq 1 or (qry.recordCount gt 1 and dateDiff("n", variables.lastEmailTimestamp, now()) gt variables.config.timespan)) {
				logTrigger(entry);
				sendEmail(qry, rawEntry);
				variables.lastEmailTimestamp = now();
			}
		
			return true;
		</cfscript>
	</cffunction>
--->

	<cffunction name="sendEmail" access="private" returntype="void" output="true">
		<cfargument name="data" type="query" required="true" hint="query with the bug report entries">
		<cfargument name="entry" type="bugLog.components.entry" required="true">
		
		<cfset var q = arguments.data>
		<cfset var numHours = int(variables.config.timespan / 60)>
		<cfset var numMinutes = variables.config.timespan mod 60>
		<cfset var intro = "">

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
			</cfoutput>
		</cfsavecontent>			
		
		<cfset sendToEmail(entry = arguments.entry,
							recipient = variables.config.recipientEmail,
							subject= "BugLog: [First Message Alert][#q.ApplicationCode#][#q.hostName#] #q.message#", 
							comment = intro,
							entryID = q.EntryID,
							includeHTMLReport = variables.config.includeHTMLReport)>
		
		<cfset writeToCFLog("'firstMessageAlert' rule fired. Email sent. Msg: '#q.message#'")>
	</cffunction>

	<cffunction name="explain" access="public" returntype="string">
		<cfset var rtn = "Sends an alert ">
		<cfif variables.config.recipientEmail  neq "">
			<cfset rtn &= " to <b>#variables.config.recipientEmail#</b>">
		</cfif>
		<cfset rtn &= " on the first ocurrence">
		<cfif variables.config.timespan  neq "">
			<cfset rtn &= " in <b>#variables.config.timespan#</b> minutes">
		</cfif>
		<cfset rtn &= " of a bug report received">
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
