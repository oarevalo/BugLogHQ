<cfcomponent displayname="baseRule" hint="This is the base component for any rule. A rule is a process that is evaluated each time a bug arrives and can determine if some actions need to be taken, such as sending an alert via email">

	<!--- the internal config structure is used to store configuration values
			for the current instance of this rule --->
	<cfset variables.config = structNew()>

	<cffunction name="init" access="public" returntype="baseRule">
		<!--- the default behavior is to copy the arguments to the config 
			but this can be overriden if other type of initialization is needed
		--->
		<cfset variables.config = duplicate(arguments)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="processRule" access="public" returnType="boolean"
				hint="This method performs the actual evaluation of the rule. Each rule is evaluated on a rawEntryBean. 
						The method returns a boolean value that can be used by the caller to determine if additional rules
						need to be evaluated.">
		<cfargument name="rawEntry" type="bugLog.components.rawEntryBean" required="true">
		<cfargument name="entry" type="bugLog.components.entry" required="true">
		<!--- this method must be implemented by rules that extend the base rule --->
		<cfreturn true>
	</cffunction>

	<cffunction name="processQueueStart" access="public" returntype="boolean" hint="This method gets called BEFORE each processing of the queue (only invoked when using the asynch listener)">
		<cfargument name="queue" type="array" required="true">
		<!--- this method must be implemented by rules that extend the base rule --->
		<cfreturn true>
	</cffunction>

	<cffunction name="processQueueEnd" access="public" returntype="boolean" hint="This method gets called AFTER each processing of the queue (only invoked when using the asynch listener)">
		<cfargument name="queue" type="array" required="true">
		<!--- this method must be implemented by rules that extend the base rule --->
		<cfreturn true>
	</cffunction>

	<cffunction name="sendToEmail" access="public" returntype="void">
		<cfargument name="rawEntryBean" type="bugLog.components.rawEntryBean" required="false">
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

			if(structKeyExists(arguments,"rawEntryBean")) {
				stEntry = arguments.rawEntryBean.getMemento();
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

			<cfif structKeyExists(arguments,"rawEntryBean")>
				<table style="font-family:arial;font-size:12px;">
					<tr>
						<td><b>Message:</b></td>
						<td><strong>#stEntry.message#</strong></td>
					</tr>
					<tr>
						<td><b>Date/Time:</b></td>
						<td>#showDateTime(stEntry.receivedOn)#</td>
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
		
		<cfset _sendToEmail(sender, arguments.recipient, arguments.subject, body, "html")>
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
		<cfreturn "">
	</cffunction>

	<cffunction name="showDateTime" returnType="string" access="private" hint="formats a date/time object according to user settings">
		<cfargument name="theDateTime" type="any" required="true">
		<cfset var rtn = "">
		<cfset var timezoneInfo = getListener().getConfig().getSetting("general.timezoneInfo","")>
		<cfset var dateMask = getListener().getConfig().getSetting("general.dateFormat","mm/dd/yyyy")>
		
		<cfif timezoneInfo neq "">
			<cfset var utils = createObject("component","bugLog.components.util").init() />
			<cfset theDateTime = util.dateConvertZ("local2zone",theDateTime,timezoneInfo)>
		</cfif>
		<cfset rtn = dateFormat(theDateTime, dateMask) & " " & lsTimeFormat(theDateTime)>
		<cfreturn rtn>
	</cffunction>
	
	<cffunction name="_sendToEmail" access="private" returntype="void" hint="actual cfmail interaction">
		<cfargument name="from" type="string" required="true">
		<cfargument name="to" type="string" required="true">
		<cfargument name="subject" type="string" required="true">
		<cfargument name="body" type="string" required="true">
		<cfargument name="type" type="string" required="false" default="html">
		<cfset var debug = getListener().getConfig().getSetting("debug.email", false)>
		<cfif isBoolean(debug) and debug>
			<cfset var path = getListener().getConfig().getSetting("debug.emailPath","/bugLog/emails/")>
			<cfset var txt = "From: #arguments.from#" & chr(10)
									& "To: #arguments.to#" & chr(10)
									& "Type: #arguments.type#" & chr(10)
									& "Subject: #arguments.subject#" & chr(10)
									& "-----------------------------------" & chr(10)
									& arguments.body>
			<cfset var ext = arguments.type eq "html" ? "html" : "txt">
			<cfset fileWrite(expandPath(path & getTickCount() & "." & ext),txt,"UTF-8")>
		<cfelse>
			<cfmail from="#arguments.from#" 
					to="#arguments.to#" 
					type="#arguments.type#" 
					subject="#arguments.subject#"
					>#arguments.body#</cfmail>
		</cfif>
	</cffunction>
	
</cfcomponent>