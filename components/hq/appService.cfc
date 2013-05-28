<cfcomponent>
	
	<cfset variables.DEFAULT_BUGLOG_CFC_PATH = "bugLog">
	<cfset variables.DEFAULT_BUGLOG_INSTANCE = "default">
	
	<cfset variables.cfcPath = "">
	<cfset variables.extensionsPath = "">
	<cfset variables.OSPathSeparator = createObject("java","java.lang.System").getProperty("file.separator")>
	<cfset variables.config = 0>
	<cfset variables.instanceName = "">
	<cfset variables.autoApplyRuleChanges = true>

	<cffunction name="init" access="public" returntype="appService">
		<cfargument name="instanceName" type="string" required="false" default="">

		<!--- get the path in dot notation --->
		<cfset variables.cfcPath = variables.DEFAULT_BUGLOG_CFC_PATH>

		<!--- set instance --->
		<cfif arguments.instanceName eq "">
			<!--- allow setting the buglog instance using a global request-level variable --->
			<cfif structKeyExists(request,"bugLogInstance") and request.bugLogInstance neq "">
				<cfset variables.instanceName = request.bugLogInstance>
			<cfelse>
				<cfset variables.instanceName = variables.DEFAULT_BUGLOG_INSTANCE>
			</cfif>
		<cfelse>
			<cfset variables.instanceName = arguments.instanceName>
		</cfif>
		<cfdump var="BuglogHQ Init. Using instance: #variables.instanceName# #chr(10)#" output="console">

		<!--- load the config object --->
		<cfset var loader = getServiceLoader( true )>
		<cfset variables.config = loader.getConfig()>

		<!--- Load the DAO objects --->
		<cfset variables.oDAOFactory = createModelObject("components.DAOFactory").init( variables.config )>
		<cfset variables.oApplicationDAO = variables.oDAOFactory.getDAO("application")>
		<cfset variables.oEntryDAO = variables.oDAOFactory.getDAO("entry")>
		<cfset variables.oHostDAO = variables.oDAOFactory.getDAO("host")>
		<cfset variables.oSeverityDAO = variables.oDAOFactory.getDAO("severity")>
		<cfset variables.oSourceDAO = variables.oDAOFactory.getDAO("source")>
		<cfset variables.oUserDAO = variables.oDAOFactory.getDAO("user")>
		<cfset variables.oUserApplicationDAO = variables.oDAOFactory.getDAO("userApplication")>

		<!--- setup extensions --->
		<cfset variables.extensionsPath = variables.cfcPath & ".extensions.">
		<cfset variables.oExtensionsService = createModelObject("components.extensionsService").init( variables.oDAOFactory.getDAO("extension") )>

		<!--- other settings --->
		<cfset variables.autoApplyRuleChanges = variables.config.getSetting("hq.autoApplyRuleChanges", true)>

		<cfreturn this>		
	</cffunction>

	<!--- Interface for BugLogListener Running Instance ---->
	<cffunction name="getServiceLoader" access="public" returntype="bugLog.components.service">
		<cfargument name="forceReload" type="boolean" required="false" default="false">
		<cfset var service = createModelObject("components.service").init( reloadConfig = arguments.forceReload,
																										instanceName = variables.instanceName )>
		<cfreturn service>
	</cffunction>

	<cffunction name="getServiceInfo" access="public" returntype="struct">
		<cfscript>
			var stInfo = structNew();
			var loader = getServiceLoader();
			
			stInfo.isRunning = loader.isRunning();
			stInfo.startedOn = "";
			
			if(stInfo.isRunning) {
				stInfo.startedOn = loader.getService().getStartedOn();
			}
			
			return stInfo;
		</cfscript>
	</cffunction>
	
	<cffunction name="startService" access="public" returntype="void">
		<cfscript>
			var loader = getServiceLoader( true );
			loader.start();
		</cfscript>
	</cffunction>

	<cffunction name="stopService" access="public" returntype="void">
		<cfscript>
			var loader = getServiceLoader();
			loader.stop();
		</cfscript>
	</cffunction>

	<cffunction name="getServiceSetting" access="public" returntype="string">
		<cfargument name="name" type="string" required="true">
		<cfargument name="value" type="string" required="false" default="">
		<cfscript>
			var loader = getServiceLoader( true );
			return loader.getSetting(arguments.name, arguments.value);
		</cfscript>
	</cffunction>

	<cffunction name="setServiceSetting" access="public" returntype="string">
		<cfargument name="name" type="string" required="true">
		<cfargument name="value" type="string" required="false" default="">
		<cfscript>
			var loader = getServiceLoader( true );
			return loader.setSetting(arguments.name, arguments.value);
		</cfscript>
	</cffunction>
	
	<cffunction name="searchEntries" access="public" returntype="query">
		<cfargument name="searchTerm" type="string" required="true">
		<cfargument name="applicationID" type="string" required="false" default="0">
		<cfargument name="hostID" type="string" required="false" default="0">
		<cfargument name="severityID" type="string" required="false" default="0">
		<cfargument name="startDate" type="date" required="false" default="1/1/1800">
		<cfargument name="endDate" type="date" required="false" default="1/1/3000">
		<cfargument name="search_cfid" type="string" required="false" default="">
		<cfargument name="search_cftoken" type="string" required="false" default="">
		<cfargument name="userAgent" type="string" required="false" default="">
		<cfargument name="searchHTMLReport" type="string" required="false" default="">
		<cfargument name="user" type="any" required="false">
		<cfscript>
			var oEntryFinder = 0;
			var qry = 0;
			var oFinder = 0;
			var o = 0;
			var args = duplicate(arguments);

			// if applicationID is not numeric, assume it is the applicationCode
			if(Not isNumeric(arguments.applicationID)) {
				args.applicationID = 0;
				args.applicationCode = trim(arguments.applicationID);
			}

			// if hostID is not numeric, assume it is the hostname
			if(Not isNumeric(arguments.hostID)) {
				args.hostID = 0;
				args.hostName = trim(arguments.hostID);
			}

			// if severityID is not numeric and is not a list and is not _ALL_, assume it is the severityCode
			if(Not isNumeric(arguments.severityID) and listlen(arguments.severityID) eq 1 and arguments.severityID neq "_ALL_") {
				args.severityID = 0;
				args.severityCode = trim(arguments.severityID);
			}
			
			// make sure that searchHTMLReport is a valid boolean value
			args.searchHTMLReport = (isBoolean(arguments.searchHTMLReport) and arguments.searchHTMLReport);
						
			// see if we need to restrict search for the given user
			if(structKeyExists(arguments,"user")) {
				if(!arguments.user.getIsAdmin() and arrayLen(arguments.user.getAllowedApplications())) {
					args.userID = arguments.user.getUserID();
				}
				structDelete(args,"user");
			}			
						
			// get entries
			oEntryFinder = createModelObject("components.entryFinder").init( variables.oEntryDAO );
			qry = oEntryFinder.search(argumentCollection = args);
			
			return qry;
		</cfscript>
	</cffunction>

	<cffunction name="getEntry" access="public" returntype="any">
		<cfargument name="entryID" type="numeric" required="true">
		<cfargument name="user" type="bugLog.components.user" required="false">
		<cfscript>
			var oEntryFinder = 0;
			var entry = 0;

			// create the dao factory
			oEntryFinder = createModelObject("components.entryFinder").init( variables.oEntryDAO );
			
			// get entries
			entry = oEntryFinder.findByID(arguments.entryID);
			
			// if we are passing a user, make sure that user can view the entry
			if(structKeyExists(arguments,"user") and !arguments.user.isApplicationAllowed(entry.getApplicationID())) {
				throw(message="Not allowed",type="notAllowed");
			}
			
			return entry;
		</cfscript>
	</cffunction>
	
	<cffunction name="getApplications" access="public" returntype="query">
		<cfargument name="user" type="any" required="false">
		<cfif not structKeyExists(arguments,"user") or user.getIsAdmin() or not arrayLen(user.getAllowedApplications())>
			<cfset var qry = variables.oApplicationDAO.getAll()>
		<cfelse>
			<cfset var apps = user.getAllowedApplications()>
			<cfset var ids = []>
			<cfset var app = 0>
			<cfloop array="#apps#" index="app">
				<cfset arrayAppend(ids,app.getApplicationID())>
			</cfloop>
			<cfset var qry = variables.oApplicationDAO.get(arrayToList(ids))>
		</cfif>
		<cfquery name="qry" dbtype="query">
			SELECT *
				FROM qry
				ORDER BY code
		</cfquery>
		<cfreturn qry>
	</cffunction>	

	<cffunction name="getHosts" access="public" returntype="query">
		<cfset var qry = variables.oHostDAO.getAll()>
		<cfquery name="qry" dbtype="query">
			SELECT *
				FROM qry
				ORDER BY hostName
		</cfquery>
		<cfreturn qry>
	</cffunction>	

	<cffunction name="getSeverities" access="public" returntype="query">
		<cfset var qry = variables.oSeverityDAO.getAll()>
		<cfquery name="qry" dbtype="query">
			SELECT *
				FROM qry
				ORDER BY name
		</cfquery>
		<cfreturn qry>
	</cffunction>	
	
	<cffunction name="sendEntry" access="public" returntype="void">
		<cfargument name="entryID" type="numeric" required="true">
		<cfargument name="sender" type="string" required="true">
		<cfargument name="recipient" type="string" required="true">
		<cfargument name="comment" type="string" required="false" default="">
		
		<cfscript>
			var oEntry = getEntry(arguments.entryID);
			var thisHost = "";
			var bugURL = getBugEntryHREF(arguments.EntryID);
			var buglogHref = getBaseBugLogHREF();
		</cfscript>
		
		<cfmail from="#arguments.sender#" 
				to="#arguments.recipient#" 
				type="html" 
				subject="Bug ###arguments.entryID#: #oEntry.getMessage()#">
			<cfif arguments.comment neq "">
				#arguments.comment#
				<hr>
			</cfif>

			<table style="font-size:12px;">
				<tr>
					<td><b>Date/Time:</b></td>
					<td>#showDateTime(oEntry.getCreatedOn())#</td>
				</tr>
				<tr>
					<td><b>Application:</b></td>
					<td>#oEntry.getapplication().getName()#</td>
				</tr>
				<tr>
					<td><b>Host:</b></td>
					<td>#oEntry.gethost().getHostName()#</td>
				</tr>
				<tr>
					<td><b>Template Path:</b></td>
					<td>#oEntry.gettemplate_Path()#</td>
				</tr>
				<tr valign="top">
					<td><b>Exception Message:</b></td>
					<td>#oEntry.getexceptionMessage()#</td>
				</tr>
				<tr valign="top">
					<td><b>Exception Detail:</b></td>
					<td>#oEntry.getExceptionDetails()#</td>
				</tr>
			</table>			
			
			<hr>
			Click on the following link to view full bug report: 
			<a href="#bugURL#">#bugURL#</a>
			<br><br><br>
			** This email has been sent from the BugLog server at 
			<a href="#buglogHref#">#buglogHref#</a>
		</cfmail>
		
	</cffunction>
	
	<cffunction name="deleteEntry" access="public" returntype="numeric" hint="deletes one or more entries from the database">
		<cfargument name="entryID" type="numeric" required="true">
		<cfargument name="deleteScope" type="string" required="false" default="this" hint="indicates whether to delete only one entry or all entries that share certain properties">
		<cfscript>
			var oEntry = getEntry(arguments.entryID);
			var qry = 0;
			var ids = [];

			switch(deleteScope) {
				case "this":
					ids = entryID;
					break;
				case "app":
					qry = oEntryDAO.search(message = oEntry.getMessage(),
											applicationID = oEntry.getApplicationID());
					ids = valueList(qry.entryID);
					break;
				case "app-host":
					qry = oEntryDAO.search(message = oEntry.getMessage(),
											hostID = oEntry.getHostID(),
											applicationID = oEntry.getApplicationID());
					ids = valueList(qry.entryID);
					break;
				default:
					throw("Unknown deletion scope");
			}

			if(listLen(entryID) gt 0) {
				oEntryDAO.delete(ids);
			}
			
			return listLen(ids);
		</cfscript>
	</cffunction>
	
	<cffunction name="checkLogin" access="public" returntype="numeric" hint="Checks username and password, and returns userID of corresponding user. If not correct, returns 0">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		
		<cfscript>
			var oFinder = 0;
			var o = 0;

			if(arguments.username eq "") return 0;

			// create the finder
			oFinder = createModelObject("components.userFinder").init( oUserDAO );
			
			// see if the user exists
			try {
				o = oFinder.findByUsername( arguments.username );
				if(len(o.getPassword()) lt 32 and o.getPassword() eq arguments.password) {
					return o.getUserID() * -1;	// good password but needs to be changed
				}
				if(o.getPassword() neq hash(arguments.password)) {
					return 0;	// wrong password
				}
			
			} catch(userFinderException.usernameNotFound e) {
				return 0;		// wrong username
			}
			
			return o.getUserID();
		</cfscript>		
	</cffunction>

	<cffunction name="purgeHistory" access="public" returntype="void">
		<cfargument name="purgeHistoryDays" type="numeric" required="true">
		
		<cfset var oDataProvider = variables.oDAOFactory.getDataProvider()>
		<cfset var sql = "">
		<cfset var dbType = oDataProvider.getConfig().getDBType()>
		
		<!--- delete entries --->
		<cfsavecontent variable="sql">
			<cfoutput>
				DELETE 
					FROM bl_Entry
					WHERE
					<cfif dbType eq "mysql">
						createdOn < NOW() - INTERVAL #purgeHistoryDays# DAY
					<cfelseif dbType contains "mssql" or dbType eq "access">
						DATEDIFF(day, createdOn, GETDATE()) > #purgeHistoryDays#
					<cfelseif dbType EQ "pgsql">
						createdOn < CURRENT_TIMESTAMP - INTERVAL '#purgeHistoryDays# days'
					<cfelseif dbType EQ "oracle">
						(extract(day from CURRENT_TIMESTAMP) - extract(day from createdOn)) > #purgeHistoryDays#
					</cfif>
			</cfoutput>
		</cfsavecontent>
		<cfset oDataProvider.exec(sql)>
		
	</cffunction>

	<cffunction name="getDigestSettings" access="public" returntype="struct">
		<cfset var digestConfig = {}>
		<cfset digestConfig.enabled = isBoolean(variables.config.getSetting("digest.enabled", false)) and variables.config.getSetting("digest.enabled", false)>
		<cfset digestConfig.recipients = variables.config.getSetting("digest.recipients", "")>
		<cfset digestConfig.schedulerIntervalHours = val(variables.config.getSetting("digest.schedulerIntervalHours", 24))>
		<cfset digestConfig.schedulerStartTime = variables.config.getSetting("digest.schedulerStartTime", "06:00")>
		<cfset digestConfig.sendIfEmpty = isBoolean(variables.config.getSetting("digest.sendIfEmpty", false)) and variables.config.getSetting("digest.sendIfEmpty", false)>
		<cfset digestConfig.severity = variables.config.getSetting("digest.severity", "")>
		<cfset digestConfig.application = variables.config.getSetting("digest.application", "")>
		<cfset digestConfig.host = variables.config.getSetting("digest.host", "")>
		<cfreturn digestConfig>
	</cffunction>

	<cffunction name="setDigestSettings" access="public" returntype="void">
		<cfargument name="enabled" type="boolean" required="true">
		<cfargument name="recipients" type="string" required="true">
		<cfargument name="interval" type="numeric" required="true">
		<cfargument name="startTime" type="string" required="true">
		<cfargument name="sendIfEmpty" type="boolean" required="true">
		<cfargument name="severity" type="string" required="true">
		<cfargument name="application" type="string" required="true">
		<cfargument name="host" type="string" required="true">
		<cfset variables.config.setSetting("digest.enabled", arguments.enabled)>
		<cfset variables.config.setSetting("digest.recipients", arguments.recipients)>
		<cfset variables.config.setSetting("digest.schedulerIntervalHours", arguments.interval)>
		<cfset variables.config.setSetting("digest.schedulerStartTime", arguments.startTime)>
		<cfset variables.config.setSetting("digest.sendIfEmpty", arguments.sendIfEmpty)>
		<cfset variables.config.setSetting("digest.severity", arguments.severity)>
		<cfset variables.config.setSetting("digest.application", arguments.application)>
		<cfset variables.config.setSetting("digest.host", arguments.host)>
	</cffunction>

	<cffunction name="getConfigKey" access="public" returntype="string">
		<cfreturn variables.config.getConfigKey()>
	</cffunction>	

	<cffunction name="getInstanceName" access="public" returntype="string">
		<cfreturn variables.instanceName>
	</cffunction>	

	<cffunction name="getConfig" access="public" returntype="bugLog.components.config">
		<cfreturn variables.config>
	</cffunction>	

	<cffunction name="applyGroupings" access="public" returntype="query" hint="perform grouping for summary display">
		<cfargument name="qryEntries" required="true" type="query">
		<cfargument name="groupByApp" required="true" type="boolean">
		<cfargument name="groupByHost" required="true" type="boolean">
		<cfset var qry = 0>
		<cfquery name="qry" dbtype="query">
			SELECT <cfif arguments.groupByApp>
						ApplicationCode, ApplicationID, 
					</cfif>
					<cfif arguments.groupByHost>
						HostName, HostID, 
					</cfif>
					Message, 
					COUNT(entryID) AS bugCount, 
					MAX(createdOn) as createdOn, 
					MAX(entryID) AS EntryID, 
					MAX(severityCode) AS SeverityCode
				FROM arguments.qryEntries
				GROUP BY 
					<cfif arguments.groupByApp>
						ApplicationCode, ApplicationID, 
					</cfif>
					<cfif arguments.groupByHost>
						HostName, HostID, 
					</cfif>
					Message
				ORDER BY createdOn DESC
		</cfquery>
		<cfreturn qry>
	</cffunction>
		
	<cffunction name="buildRSSFeed" access="public" returntype="xml">
		<cfargument name="criteria" type="struct" required="true">
		<cfargument name="summary" type="boolean" required="true">
		<cfargument name="rssService" type="any" required="true">
		<cfscript>
			var maxEntries = 20;
			var data = queryNew("title,body,link,subject,date");

			// search bug reports
			var qryEntries = searchEntries(argumentCollection = criteria);
			if(summary)
				qryEntries = applyGroupings(qryEntries, criteria.groupByApp, criteria.groupByHost);

			// build rss feed
			var meta = {
				title = "BugLog",
				link = getBaseBugLogHREF(),
				description = "Recently received bugs"
			};
			
			for(var i=1;i lte min(maxEntries, qryEntries.recordCount);i=i+1) {
				queryAddRow(data,1);
				if(summary) {
					querySetCell(data,"title", qryEntries.message[i] & " (" & qryEntries.bugCount[i] & ")");
					querySetCell(data,"body", composeMessage(qryEntries.createdOn[i], 
																					qryEntries.applicationCode[i], 
																					qryEntries.hostName[i], 
																					qryEntries.severityCode[i], 
																					"", 
																					"", 
																					"",
																					qryEntries.bugCount[i] ));
				} else {
					querySetCell(data,"title","Bug ###qryEntries.entryID[i]#: " & qryEntries.message[i]);
					querySetCell(data,"body",composeMessage(qryEntries.createdOn[i], 
																					qryEntries.applicationCode[i], 
																					qryEntries.hostName[i], 
																					qryEntries.severityCode[i], 
																					qryEntries.templatePath[i], 
																					qryEntries.exceptionMessage[i], 
																					qryEntries.exceptionDetails[i] ));
				}
				querySetCell(data,"link", getBugEntryHREF(qryEntries.entryID[i]));
				querySetCell(data,"subject","Subject");
				querySetCell(data,"date",now());
			}
			
			var rssXML = rssService.generateRSS("rss1",data,meta);		
			
			return rssXML;
		</cfscript>
	</cffunction>	
		

	<!----- Extensions ----->	
	<cffunction name="getRules" access="public" returnType="array" hint="Returns all rules that are available">
		<cfset var tmpRulesPath = "/bugLog/extensions/rules">
		<cfset var aRtn = arrayNew(1)>
		<cfset var st = structNew()>
		
		<cfdirectory action="list" directory="#expandPath(tmpRulesPath)#" name="qryDir" listinfo="name">
		<cfquery name="qryDir" dbtype="query">
			SELECT *
				FROM qryDir
				WHERE name not like '%.svn'
					and name not like '%.cvs'
				ORDER BY name
		</cfquery>	

		<cfloop query="qryDir">
			<cfset st = getCFCInfo(variables.extensionsPath & "rules." & listFirst(qryDir.name,".") )>
			<cfset arrayAppend(aRtn, st)>
		</cfloop>

		<cfreturn aRtn>
	</cffunction>
	
	<cffunction name="getActiveRules" access="public" returnType="array" hint="Returns all rules that are active">
		<cfreturn variables.oExtensionsService.getRules() />
	</cffunction>

	<cffunction name="getRuleInfo" access="public" returnType="struct" hint="Returns information about a given rule">
		<cfargument name="ruleName" type="string" required="true">
		<cfreturn getCFCInfo(variables.extensionsPath & "rules." & arguments.ruleName )>
	</cffunction>

	<cffunction name="getRule" access="public" returntype="any" hint="Finds a given rule by its ID">
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="user" type="bugLog.components.user" required="true">
		<cfscript>
			if(!oExtensionsService.isAllowed(arguments.id, arguments.user))
				throw(message="User cannot access this rule",type="notAuthorized");
			return oExtensionsService.getRuleByID(arguments.id);
		</cfscript>
	</cffunction>

	<cffunction name="saveRule" access="public" returntype="void" hint="adds or updates a rule">
		<cfargument name="id" type="numeric" required="false" default="0">
		<cfargument name="ruleName" type="string" required="true">
		<cfargument name="user" type="bugLog.components.user" required="true">
		<!--- rule settings are passed as individual arguments --->
		
		<cfscript>
			var stRule = 0;
			var stProperties = 0; var i=0; var prop = "";
			var desc = "";
			
			// get rule info
			stRule = getCFCInfo(variables.extensionsPath & "rules." & arguments.ruleName);
			
			stProperties = structNew();
			for(i=1;i lte arrayLen(stRule.properties);i=i+1) {
				prop = stRule.properties[i].name;
				if(structKeyExists(arguments,prop))
					stProperties[prop] = arguments[prop];
			}
			
			if(structKeyExists(arguments,"description"))
				desc = arguments.description;
			
			if(arguments.id gt 0) {
				if(!oExtensionsService.isAllowed(arguments.id, arguments.user))
					throw(message="User cannot update this rule",type="notAuthorized");
				oExtensionsService.updateRule(arguments.id, stProperties, desc);
			} else {
				oExtensionsService.createRule(arguments.ruleName, stProperties, desc, user.getUserID());
			}
			
			// reload rules
			if(variables.autoApplyRuleChanges) {
				getServiceLoader().getService().reloadRules();
			}
		</cfscript>
		
	</cffunction>

	<cffunction name="deleteRule" access="public" returntype="void" hint="delete a rule">
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="user" type="bugLog.components.user" required="true">
		<cfscript>
			if(!oExtensionsService.isAllowed(arguments.id, arguments.user))
				throw(message="User cannot delete this rule",type="notAuthorized");
			oExtensionsService.removeRule(arguments.id);

			// reload rules
			if(variables.autoApplyRuleChanges) {
				getServiceLoader().getService().reloadRules();
			}
		</cfscript>		
	</cffunction>

	<cffunction name="enableRule" access="public" returntype="void" hint="enables a rule">
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="user" type="bugLog.components.user" required="true">
		<cfscript>
			if(!oExtensionsService.isAllowed(arguments.id, arguments.user))
				throw(message="User cannot enable this rule",type="notAuthorized");
			oExtensionsService.enableRule(arguments.id);

			// reload rules
			if(variables.autoApplyRuleChanges) {
				getServiceLoader().getService().reloadRules();
			}
		</cfscript>		
	</cffunction>

	<cffunction name="disableRule" access="public" returntype="void" hint="disables a rule">
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="user" type="bugLog.components.user" required="true">
		<cfscript>
			if(!oExtensionsService.isAllowed(arguments.id, arguments.user))
				throw(message="User cannot disable this rule",type="notAuthorized");
			oExtensionsService.disableRule(arguments.id);

			// reload rules
			if(variables.autoApplyRuleChanges) {
				getServiceLoader().getService().reloadRules();
			}
		</cfscript>		
	</cffunction>

	<cffunction name="getExtensionsLog" access="public" returntype="query" hint="get a list of the most recent rule firings">
		<cfargument name="startDate" type="date" required="false" default="1/1/1800">
		<cfargument name="user" type="bugLog.components.user" required="false">
		<cfscript>
			var userID = (structKeyExists(arguments,"user") and !arguments.user.getIsAdmin()) ? arguments.user.getUserID() : 0;
			var qry = oExtensionsService.getHistory(arguments.startDate, userID);
			return qry;
		</cfscript>
	</cffunction>


	<!---- User Management ---->
	<cffunction name="getUserByID" access="public" returntype="bugLog.components.user" hint="return the user for the given userid">
		<cfargument name="userID" type="numeric" required="true">
		<cfscript>
			var oFinder = createModelObject("components.userFinder").init( oUserDAO );
			var user = oFinder.findByID( arguments.userID );
			user.setAllowedApplications( getUserApplications(arguments.userID) );
			return user;
		</cfscript>
	</cffunction>

	<cffunction name="getUsers" access="public" returntype="query" hint="return a query with all users">
		<cfreturn variables.oUserDAO.getAll()>
	</cffunction>

	<cffunction name="saveUser" access="public" returntype="void" hint="Creates or updates a user">
		<cfargument name="userToSave" type="bugLog.components.user" required="true" hint="a user object">
		<cfset arguments.userToSave.save()>
	</cffunction>

	<cffunction name="deleteUser" access="public" returntype="void" hint="Deletes a user">
		<cfargument name="userIDToDelete" type="numeric" required="true" hint="a user id">
		<cfset variables.oUserDAO.delete( arguments.userIDToDelete )>
	</cffunction>

	<cffunction name="getBlankUser" access="public" returntype="bugLog.components.user" hint="return an empty user object">
		<cfreturn createObject("component","bugLog.components.user").init( variables.oUserDAO ) />
	</cffunction>
	
	<cffunction name="setUserPassword" access="public" returntype="void" hint="Updates the password for a user">
		<cfargument name="userToSave" type="bugLog.components.user" required="true" hint="a user object">
		<cfargument name="newPassword" type="string" required="true" hint="the new password">
		<cfset arguments.userToSave.setPassword(hash(arguments.newPassword))>
		<cfset arguments.userToSave.save()>
	</cffunction>
	
	<cffunction name="getUserApplications" access="public" returntype="array" hint="returns the applications that a user is allowed to see">
		<cfargument name="userID" type="numeric" required="true">
		<cfscript>
			var qryUserApps = oUserApplicationDAO.search(userID = arguments.userID);
			var oFinder = createModelObject("components.appFinder").init(oApplicationDAO);
			var apps = oFinder.findByIDList(valueList(qryUserApps.applicationID));
			return apps;
		</cfscript>		
	</cffunction>

	<cffunction name="setUserApplications" access="public" returntype="void" hint="sets the applications that a user is allowed to see">
		<cfargument name="userID" type="numeric" required="true">
		<cfargument name="applicationID" type="array" required="true">
		<cfscript>
			var i = 0;
			var qryUserApps = oUserApplicationDAO.search(userID = arguments.userID);
			oUserApplicationDAO.delete(valueList(qryUserApps.userApplicationID));
			
			for(i=1;i lte arrayLen(applicationID);i++) {
				oUserApplicationDAO.save(userID = arguments.userID,
										applicationID = applicationID[i]);
			}
		</cfscript>		
	</cffunction>
	
	
	<!---- Data Management --->
	<cffunction name="saveApplication" access="public" returntype="numeric">
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="code" type="string" required="true">
		<cfargument name="name" type="string" required="false" default="#arguments.code#">
		<cfset var newID = variables.oApplicationDAO.save(id=arguments.id, 
															code=arguments.code, 
															name=arguments.name)>
		<cfreturn newID>
	</cffunction>

	<cffunction name="saveHost" access="public" returntype="numeric">
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="hostName" type="string" required="true">
		<cfset var newID = variables.oHostDAO.save(id=arguments.id, 
															hostName=arguments.hostName)>
		<cfreturn newID>
	</cffunction>

	<cffunction name="saveSeverity" access="public" returntype="numeric">
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="code" type="string" required="true">
		<cfargument name="name" type="string" required="false" default="#arguments.code#">
		<cfset var newID = variables.oSeverityDAO.save(id=arguments.id, 
															code=arguments.code, 
															name=arguments.name)>
		<cfreturn newID>
	</cffunction>

	<cffunction name="deleteApplication" access="public" returntype="void">
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="entryAction" type="string" required="true">
		<cfargument name="moveToID" type="numeric" required="false" default="0">
		<cfif arguments.entryAction eq "delete">
			<cfset variables.oEntryDAO.deleteByApplicationID(arguments.id)>
		<cfelseif arguments.entryAction eq "move" and arguments.moveToID gt 0>
			<cfset variables.oEntryDAO.updateApplicationID(arguments.id, arguments.moveToID)>
		</cfif>
		<cfset variables.oApplicationDAO.delete(arguments.id)>
	</cffunction>

	<cffunction name="deleteHost" access="public" returntype="void">
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="entryAction" type="string" required="true">
		<cfargument name="moveToAppID" type="numeric" required="false" default="0">
		<cfif arguments.entryAction eq "delete">
			<cfset variables.oEntryDAO.deleteByHostID(arguments.id)>
		<cfelseif arguments.entryAction eq "move" and arguments.moveToID gt 0>
			<cfset variables.oEntryDAO.updateHostID(arguments.id, arguments.moveToID)>
		</cfif>
		<cfset variables.oHostDAO.delete(arguments.id)>
	</cffunction>
	
	<cffunction name="deleteSeverity" access="public" returntype="void">
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="entryAction" type="string" required="true">
		<cfargument name="moveToAppID" type="numeric" required="false" default="0">
		<cfif arguments.entryAction eq "delete">
			<cfset variables.oEntryDAO.deleteBySeverityID(arguments.id)>
		<cfelseif arguments.entryAction eq "move" and arguments.moveToID gt 0>
			<cfset variables.oEntryDAO.updateSeverityID(arguments.id, arguments.moveToID)>
		</cfif>
		<cfset variables.oSeverityDAO.delete(arguments.id)>
	</cffunction>

		
	<!----- Private Methods ---->
	<cffunction name="createModelObject" access="private" returntype="any">
		<cfargument name="cfc" type="string" required="true">
		<cfreturn createObject("component", variables.cfcPath & "." & arguments.cfc)>
	</cffunction>
	
	<cffunction name="getCFCInfo" access="private" returntype="struct" hint="returns information about a given cfc">
		<cfargument name="cfcPath" type="string" required="true">
		<cfscript>
			var stMD = structNew();
			var st = structNew();
			var o = 0;
			
			st.description = "";
			st.properties = arrayNew(1);
	
			o = createObject("component",arguments.cfcPath);
			stMD = getMetaData(o);
			
			st.name = stMD.name;
			if(structKeyExists(stMD,"hint")) st.description = stMD.hint;
			if(structKeyExists(stMD,"properties")) st.properties = duplicate(stMD.properties);

			return st;
		</cfscript>
	</cffunction>

	<cffunction name="getBugEntryHREF" access="public" returntype="string" hint="Returns the URL to a given bug report">
		<cfargument name="entryID" type="numeric" required="true" hint="the id of the bug report">
		<cfset var utils = createObject("component","bugLog.components.util").init() />
		<cfset var href = utils.getBugEntryHREF(arguments.entryID, variables.config, variables.instanceName) />
		<cfreturn href />
	</cffunction>

	<cffunction name="getBaseBugLogHREF" access="public" returntype="string" hint="Returns a web accessible URL to buglog">
		<cfset var utils = createObject("component","bugLog.components.util").init() />
		<cfset var href = utils.getBaseBugLogHREF(variables.config, variables.instanceName) />
		<cfreturn href />
	</cffunction>

	<cffunction name="getLocalAssetsPath" access="public" returntype="string" hint="Returns the path to use locally within the HQ app to find html assets (js,images,css)">
		<cfscript>
			var path = "";
			var externalURL = variables.config.getSetting("general.externalURL");
			switch(externalURL) {
				case "":
				case "/bugLog/":
					path = "/bugLog/hq/";
					break;
				case "/":
					path = "/hq/";
					break;
				default:
					path = externalURL & "hq/";
			}
			return path;
		</cfscript>
	</cffunction>
	
	<cffunction name="composeMessage" access="private" returntype="string">
		<cfargument name="datetime" type="string" required="true">
		<cfargument name="applicationCode" type="string" required="true">
		<cfargument name="hostName" type="string" required="true">
		<cfargument name="severityCode" type="string" required="true">
		<cfargument name="templatePath" type="string" required="false" default="">
		<cfargument name="exceptionMessage" type="string" required="false" default="">
		<cfargument name="ExceptionDetails" type="string" required="false" default="">
		<cfargument name="BugCount" type="numeric" required="false" default="0">

		<cfset var tmpHTML = "">

		<cfsavecontent variable="tmpHTML">
			<cfoutput>
			<table style="font-size:12px;">
				<tr>
					<td><b>Date/Time:</b></td>
					<td>#showDateTime(arguments.datetime)#</td>
				</tr>
				<cfif arguments.applicationCode neq "">
					<tr>
						<td><b>Application:</b></td>
						<td>#arguments.applicationCode#</td>
					</tr>
				</cfif>
				<cfif arguments.hostname neq "">
					<tr>
						<td><b>Host:</b></td>
						<td>#arguments.hostname#</td>
					</tr>
				</cfif>
				<tr>
					<td><b>Severity:</b></td>
					<td>#arguments.severityCode#</td>
				</tr>
				<cfif arguments.templatePath neq "">
					<tr>
						<td><b>Template Path:</b></td>
						<td>#arguments.templatePath#</td>
					</tr>
				</cfif>
				<cfif arguments.exceptionMessage neq "">
					<tr valign="top">
						<td><b>Exception Message:</b></td>
						<td>#arguments.exceptionMessage#</td>
					</tr>
				</cfif>
				<cfif arguments.ExceptionDetails neq "">
					<tr valign="top">
						<td><b>Exception Detail:</b></td>
						<td>#arguments.ExceptionDetails#</td>
					</tr>
				</cfif>
				<cfif arguments.BugCount gt 0>
					<tr>
						<td><b>Count:</b></td>
						<td>#arguments.bugCount#</td>
					</tr>
				</cfif>
			</table>
			</cfoutput>
		</cfsavecontent>
		<cfreturn tmpHTML>
	</cffunction>	
	
	<cffunction name="showDateTime" returnType="string" access="private">
		<cfargument name="theDateTime" type="any" required="true">
		<cfset var rtn = "">
		<cfset var timezoneInfo = variables.config.getSetting("general.timezoneInfo","")>
		<cfset var dateMask = variables.config.getSetting("general.dateFormat","mm/dd/yyyy")>
		
		<cfif timezoneInfo neq "">
			<cfset var utils = createObject("component","bugLog.components.util").init() />
			<cfset theDateTime = util.dateConvertZ("local2zone",theDateTime,timezoneInfo)>
		</cfif>
		<cfset rtn = dateFormat(theDateTime, dateMask) & " " & lsTimeFormat(theDateTime)>
		<cfreturn rtn>
	</cffunction>

</cfcomponent>