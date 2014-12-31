<cfcomponent displayname="baseRule" hint="This is the base component for any rule. A rule is a process that is evaluated each time a bug arrives and can determine if some actions need to be taken, such as sending an alert via email">

	<cfscript>
		// the internal config structure is used to store configuration values
		// for the current instance of this rule
		variables.config = {};

		// the scope identifies the major properties for which a rule applies (application/host/severity)
		variables.scope = {};

		variables.ID_NOT_SET = -9999999;
		variables.ID_NOT_FOUND = -9999990;
		variables.SCOPE_KEYS = ["application","host","severity"];

	</cfscript>

	<cffunction name="init" access="public" returntype="baseRule">
		<cfargument name="severity" type="string" required="false" default="">
		<cfargument name="application" type="string" required="false" default="">
		<cfargument name="host" type="string" required="false" default="">
		<cfscript>
			// on buglog 1.8 rules were defined using severityCode instead of severity
			arguments.severity = structKeyExists(arguments,"severityCode") 
								? arguments.severityCode 
								: arguments.severity;

			// arguments to the constructor are used as the Rule configuration
			config = duplicate(arguments);

			// initialize scope context
			for(var key in variables.SCOPE_KEYS) {
				if(structKeyExists(config, key)) { 
					var cfg = trim(config[key]);
					if(!len(cfg))
						continue;
					scope[key] = {
						not_in = false,
						items = {}
					};
					if( left(cfg,1) == "-" ) {
						cfg = trim(removechars(cfg,1,1));
						scope[key]["not_in"] = true;
					}
					for(var item in listToArray(cfg)) {
						scope[key]["items"][trim(item)] = variables.ID_NOT_SET;
					}
				}
			}

			return this;
		</cfscript>
	</cffunction>

	<cffunction name="processRule" access="public" returnType="boolean"
				hint="This method performs the actual evaluation of the rule. Each rule is evaluated on an EntryBean. 
						The method returns a boolean value that can be used by the caller to determine if additional rules
						need to be evaluated.">
		<cfargument name="entry" type="bugLog.components.entry" required="true">
		<cfscript>
			var rtn = true;
			updateScope();
			if(matchScope(entry) && matchCondition(entry)) {
				rtn = doAction(entry);
				logTrigger(entry);
			}
			return rtn;
		</cfscript>
	</cffunction>



	<!---- Hooks --->
	
	<cffunction name="processQueueStart" access="public" returntype="boolean" hint="This method gets called BEFORE each processing of the queue">
		<cfargument name="queue" type="array" required="true">
		<!--- this method must be implemented by rules that extend the base rule --->
		<cfreturn true>
	</cffunction>

	<cffunction name="processQueueEnd" access="public" returntype="boolean" hint="This method gets called AFTER each processing of the queue">
		<cfargument name="queue" type="array" required="true">
		<!--- this method must be implemented by rules that extend the base rule --->
		<cfreturn true>
	</cffunction>

	<cffunction name="matchCondition" access="public" returntype="boolean" hint="Returns true if the entry bean matches a custom condition">
		<cfargument name="entry" type="bugLog.components.entry" required="true">
		<!--- this method must be implemented by rules that extend the base rule --->
		<cfreturn true />		
	</cffunction>

	<cffunction name="doAction" access="public" returntype="boolean" hint="Performs an action when the entry matches the scope and conditions">
		<cfargument name="entry" type="bugLog.components.entry" required="true">
		<!--- this method must be implemented by rules that extend the base rule --->
		<cfreturn true>
	</cffunction>




	<!---- Utility Methods --->
	
	<cffunction name="updateScope" access="public" returntype="void">
		<cfscript>
			// get necessary IDs
			for(var key in structKeyArray(scope)) {
				var items = scope[key]["items"];
				for(var item in items) {
					if(items[item] == ID_NOT_SET || items[item] == ID_NOT_FOUND) {
						switch(key) {
							case "application":
								items[item] = getApplicationID();
								break;
							case "severity":
								items[item] = getHostID();
								break;
							case "host":
								items[item] = getSeverityID();
								break;
						}
					}
				}
			}
		</cfscript>
	</cffunction>

	<cffunction name="matchScope" access="public" returntype="boolean" hint="Returns true if the entry bean matches the defined scope">
		<cfargument name="entry" type="bugLog.components.entry" required="true">
		<cfscript>
			var matches = true;
			var memento = entry.getMemento();
			for(var key in structKeyArray(scope)) {
				var matchesLine = scope[key]["not_in"];
				for(var item in scope[key]["items"]) {
					var id = scope[key]["items"][item];
					if(scope[key]["not_in"]) {
						matchesLine = matchesLine && memento[key & "ID"] != id;
					} else {
						matchesLine = matchesLine || memento[key & "ID"] == id;
					}
				}
				matches = matches && matchesLine;
			}
			return matches;
		</cfscript>
	</cffunction>




	<cffunction name="sendToEmail" access="public" returntype="void">
		<cfargument name="entry" type="bugLog.components.entry" required="false">
		<cfargument name="recipient" type="string" required="true">
		<cfargument name="subject" type="string" required="false" default="BugLog: bug received">
		<cfargument name="comment" type="string" required="false" default="">
		<cfargument name="entryId" type="numeric" required="false" default="0">
		<cfargument name="includeHTMLReport" type="boolean" required="false" default="true">

		<cfscript>
			var stEntry = {};
			var buglogHref = getBaseBugLogHREF();
			var sender = getListener().getConfig().getSetting("general.adminEmail");
			var bugReportURL = "";
			var body = "";

			if(structKeyExists(arguments,"entry")) {
				stEntry = arguments.entry.getMemento();
			}
			 
			if(arguments.recipient eq "") {writeToCFLog("Missing 'recipient' email address. Cannot send alert email!"); return;}
		</cfscript>

		<!--- build contents of email --->
		<cfsavecontent variable="body">
			<cfoutput>
			<cfif arguments.comment neq "">
				<div style="font-family:arial;font-size:12px;">
				#arguments.comment#
				</div>
				<hr />
			</cfif>

			<cfif arguments.entryID gt 0>
				<cfset bugReportURL = getBugEntryHREF(arguments.entryID)>
				<b>Bug Report URL:</b> <a href="#bugReportURL#">#bugReportURL#</a><br />
				<hr />
			</cfif>

			<cfif structKeyExists(arguments,"entry")>
				<cfset var createdOn = showDateTime(stEntry.createdOn)>
				<table style="font-family:arial;font-size:12px;">
					<tr>
						<td><b>Message:</b></td>
						<td><strong>#stEntry.message#</strong></td>
					</tr>
					<tr>
						<td><b>Date/Time:</b></td>
						<td>#createdOn#</td>
					</tr>
					<tr>
						<td><b>Application:</b></td>
						<td>#stEntry.applicationCode#</td>
					</tr>
					<tr>
						<td><b>Host:</b></td>
						<td>#stEntry.hostName#</td>
					</tr>
					<tr>
						<td><b>Severity:</b></td>
						<td>#stEntry.severityCode#</td>
					</tr>
					<tr>
						<td><b>Template Path:</b></td>
						<td>#stEntry.templatePath#</td>
					</tr>
					<tr valign="top">
						<td><b>Exception Message:</b></td>
						<td>#stEntry.exceptionMessage#</td>
					</tr>
					<tr valign="top">
						<td><b>Exception Detail:</b></td>
						<td>#stEntry.exceptionDetails#</td>
					</tr>
				</table>			
				
				<cfif stEntry.HTMLReport neq "" and arguments.includeHTMLReport>
					<hr />
					<b>HTML Report:</b><br />
					#stEntry.HTMLReport#
				</cfif>
				<hr />
			</cfif>

			<div style="font-family:arial;font-size:11px;margin-top:15px;">
				** This email has been sent automatically from the BugLog server at 
				<a href="#buglogHref#">#buglogHref#</a><br />
				<em>To disable automatic notifications log into the bugLog server and disable the corresponding rule.</em>
			</div>
			</cfoutput>
		</cfsavecontent>
		
		<cfset mailerService.send(
				from = sender, 
				to = arguments.recipient,
				subject = arguments.subject,
				body = body,
				type = "html"
			) />

	</cffunction>

	<cffunction name="writeToCFLog" access="private" returntype="void" hint="writes a message to the internal cf logs">
		<cfargument name="message" type="string" required="true">
		<cflog application="true" file="bugLog_ruleProcessor" text="#arguments.message#">
		<cfif structKeyExists(variables,"listener")>
			<cfset variables.listener.logMessage(arguments.message)>
		</cfif>
	</cffunction>
	
	<cffunction name="setListener" access="public" returntype="baseRule" hint="Adds a reference to the bugLogListener instance">
		<cfargument name="listener" type="any" required="true">
		<cfset variables.listener = arguments.listener>
		<cfreturn this />
	</cffunction>

	<cffunction name="getListener" access="public" returntype="bugLog.components.bugLogListener" hint="Returns a reference to the bugLogListener instance">
		<cfreturn variables.listener />
	</cffunction>

	<cffunction name="setDAOFactory" access="public" returntype="baseRule" hint="Adds a reference to the current DAOFactory instance">
		<cfargument name="daoFactory" type="any" required="true">
		<cfset variables.daoFactory = arguments.daoFactory>
		<cfreturn this />
	</cffunction>

	<cffunction name="getDAOFactory" access="public" returntype="bugLog.components.lib.dao.DAOFactory" hint="Returns a reference to the current DAOFactory instance">
		<cfreturn variables.daoFactory />
	</cffunction>

	<cffunction name="setMailerService" access="public" returntype="baseRule" hint="Adds a reference to the mailer service">
		<cfargument name="mailerService" type="any" required="true">
		<cfset variables.mailerService = arguments.mailerService>
		<cfreturn this />
	</cffunction>

	<cffunction name="setExtensionID" access="public" returntype="baseRule" hint="Sets the ID of this extension instance">
		<cfargument name="id" type="numeric" required="true">
		<cfset variables._id_ = arguments.id>
		<cfreturn this>
	</cffunction>

	<cffunction name="getExtensionID" access="public" returntype="numeric" hint="Returns the ID of this extension instance">
		<cfreturn variables._id_ />
	</cffunction>

	<cffunction name="getBugEntryHREF" access="public" returntype="string" hint="Returns the URL to a given bug report">
		<cfargument name="entryID" type="numeric" required="true" hint="the id of the bug report">
		<cfset var utils = createObject("component","bugLog.components.util").init() />
		<cfset var href = utils.getBugEntryHREF(arguments.entryID, listener.getConfig(), listener.getInstanceName()) />
		<cfreturn href />
	</cffunction>

	<cffunction name="getBaseBugLogHREF" access="public" returntype="string" hint="Returns a web accessible URL to buglog">
		<cfset var utils = createObject("component","bugLog.components.util").init() />
		<cfset var href = utils.getBaseBugLogHREF(listener.getConfig(), listener.getInstanceName()) />
		<cfreturn href />
	</cffunction>
	
	<cffunction name="logTrigger" access="public" returntype="void" hint="logs a firing of a rule">
		<cfargument name="entry" type="bugLog.components.entry" required="true">
		<cfscript>
			var dao = getDAOFactory().getDAO("extensionLog");
			dao.save(extensionID = getExtensionID(), 
							entryID = arguments.entry.getEntryID(),
							createdOn = now());
		</cfscript>
	</cffunction>
	
	<cffunction name="getLastTrigger" access="public" returntype="query" hint="Returns a query object with information about the last time this rule was triggered">
		<cfset var qry = 0>
		<cfset var dsn = getDAOFactory().getDataProvider().getConfig().getDSN()>
		<cfquery name="qry" datasource="#dsn#">
			SELECT extensionLogID, extensionID, entryID, createdOn
				FROM extensionLog
				WHERE extensionID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#getExtensionID()#">
				ORDER BY createdOn DESC
		</cfquery>
		<cfreturn qry>
	</cffunction>

	<cffunction name="explain" access="public" returntype="string" hint="returns a user friendly description of this rule">
		<cfset var rtn = "Matches bug reports ">
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

	<cffunction name="showDateTime" returnType="string" access="private" hint="formats a date/time object according to user settings">
		<cfargument name="theDateTime" type="any" required="true">
		<cfset var rtn = "">
		<cfset var timezoneInfo = getListener().getConfig().getSetting("general.timezoneInfo","")>
		<cfset var dateMask = getListener().getConfig().getSetting("general.dateFormat","mm/dd/yyyy")>

		<cfif timezoneInfo neq "">
			<cfset var utils = createObject("component","bugLog.components.util").init() />
			<cfset theDateTime = utils.dateConvertZ("local2zone",theDateTime,timezoneInfo)>
		</cfif>
		<cfset rtn = dateFormat(theDateTime, dateMask) & " " & lsTimeFormat(theDateTime)>
		<cfreturn rtn>
	</cffunction>

	<cffunction name="getApplicationID" access="private" returntype="numeric">
		<cfset var oDAO = getDAOFactory().getDAO("application")>
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
		<cfset var oDAO = getDAOFactory().getDAO("host")>
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
		<cfset var oDAO = getDAOFactory().getDAO("severity")>
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
