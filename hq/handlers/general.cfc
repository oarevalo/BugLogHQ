<cfcomponent name="general" extends="eventHandler">

	<cffunction name="onApplicationStart" access="public" returntype="void">
	</cffunction>

	<cffunction name="onRequestStart" access="public" returntype="void">
		<cfscript>
			var appTitle = getSetting("applicationTitle", application.applicationName);
			var event = getEvent();
			var hostName = CreateObject("java", "java.net.InetAddress").getLocalHost().getHostName();
			var versionTag = getSetting("versionTag");
			var	qs = "";
			var configKey = "";
			var instanceName = "";
			var app = getService("app");
			var config = app.getConfig();
			var publicEvents = "doLogin,login,requireLogin,rss.rss";
			var noLoginRedirectEvents = "dashboardContent";
			var loginEvent = "login";

			// url path used to find html/js/css resources
			var assetsPath = app.getLocalAssetsPath();
			setValue("_coreImagesPath",assetsPath & "../core/images");
			
			try {
				if(not structKeyExists(session,"userID")) session.userID = 0;
				if(not structKeyExists(session,"user")) session.user = 0;
				
				// make sure that we always access everything via events
				if(event eq "") {
					throw("All requests must specify the event to execute. Direct access to views is not allowed");
				}

				// check login
				if(not listFindNoCase(publicEvents, event) and session.userID eq 0) {
					if(not listFindNoCase(noLoginRedirectEvents, event)) {
						setMessage("Warning","Please enter your username and password");
						for(key in url) {
							if(key eq "event")
								qs = qs & "nextevent=" & url.event & "&";
							else
								qs = qs & key & "=" & url[key] & "&";
						}
					} else {
						loginEvent = "requireLogin";
					}
					setNextEvent(loginEvent,qs);
				}

				// check if user needs to change password
				if(structKeyExists(session,"requirePasswordChange")
					and not listFindNoCase("updatePassword,doUpdatePassword",event)) {
					setMessage("warning","Please update your password");
					setNextEvent("updatePassword");
				}

				// get status of buglog server
				stInfo = app.getServiceInfo();
				
				// set generally available values on the request context
				setValue("hostName", hostName);
				setValue("applicationTitle", appTitle);
				setValue("stInfo", stInfo);
				setValue("versionTag", versionTag);
				setValue("currentUser", session.user);
				setValue("dateFormatMask",config.getSetting("general.dateFormat"));
				setValue("configKey", config.getConfigKey());
				setValue("instanceName", app.getInstanceName());
				setValue("assetsPath", assetsPath);

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}
		</cfscript>

	</cffunction>

	<cffunction name="onRequestEnd">
		<!--- code to execute at the end of each request --->
	</cffunction>

	<cffunction name="login" access="public" returntype="void">
		<cfset setView("login")>
		<cfset setLayout("clean")>
	</cffunction>

	<cffunction name="requireLogin" access="public" returntype="void">
		<cfset setView("requireLogin")>
		<cfset setLayout("clean")>
	</cffunction>

	<cffunction name="dashboard" access="public" returntype="void">
		<cfscript>
			var refreshSeconds = 60;
			var appService = getService("app"); 

			try {
				// prepare filters panel
				prepareFilter("dashboard");
				
				// get current filters selected
				criteria = getValue("criteria");
				
				qryEntries = appService.searchEntries(argumentCollection = criteria);

				setValue("qryEntries",qryEntries);
				setValue("refreshSeconds",refreshSeconds);
				setValue("pageTitle", "Dashboard");
				setView("dashboard");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}
		</cfscript>
	</cffunction>

	<cffunction name="dashboardContent" access="public" returntype="void">
		<cfscript>
			var appService = getService("app"); 
			var numTriggersToDisplay = 10;

			try {
				// prepare filters panel
				loadFilter("dashboard");
				
				// get current filters selected
				criteria = getValue("criteria");
				
				qryEntries = appService.searchEntries(argumentCollection = criteria);
				qryTriggers = appService.getExtensionsLog(criteria.startDate);

				setValue("qryEntries",qryEntries);
				setValue("qryTriggers",qryTriggers);
				setLayout("");
				setView("dashboardContent");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="main" access="public" returntype="void">
		<cfscript>
			var refreshSeconds = 60;
			var rowsPerPage = 20;
			var appService = getService("app"); 

			try {
				// prepare filters panel
				prepareFilter("summary");
				
				// get current filters selected
				var criteria = getValue("criteria");
				
				// perform search				
				var qryEntries = appService.searchEntries(argumentCollection = criteria);
	
				// save the last entryID on a cookie, this allows to detect unread entries
				var lastEntryID = getHighestEntryID(qryEntries);
				if(not structKeyExists(cookie,"lastbugread")) {
					writeCookie("lastbugread",lastEntryID,30);
				}
				setValue("lastbugread", cookie.lastbugread);
	
				// set the page title to reflect any recenly received messages
				if(lastEntryID gt cookie.lastbugread) 
					setValue("pageTitle", "Summary (#lastEntryID-cookie.lastbugread#)");
				else
					setValue("pageTitle", "Summary");
					
				// perform grouping for summary display
				qryEntries = appService.applyGroupings(qryEntries, criteria.groupByApp, criteria.groupByHost);
	
				setValue("qryEntries", qryEntries);
				setValue("refreshSeconds",refreshSeconds);
				setValue("rowsPerPage",rowsPerPage);
				setView("main");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}
		</cfscript>				
	</cffunction>
	
	<cffunction name="log" access="public" returntype="void">
		<cfscript>
			var refreshSeconds = 60;
			var rowsPerPage = 20;
			var appService = getService("app"); 

			try {
				// prepare filters panel
				prepareFilter("log");
				
				// get current filters selected
				var criteria = getValue("criteria");

				// if we are passing an entryID, then get the message from there
				msgFromEntryID = getValue("msgFromEntryID",0);
				if(criteria.searchTerm eq "" and val(msgFromEntryID) gt 0) {
					oEntry = getService("app").getEntry( msgFromEntryID );
					if(oEntry.getMessage() eq "")
						criteria.message = "__EMPTY__";
					else
						criteria.message = oEntry.getMessage();
					setValue("criteria", criteria);
				} else {
					setValue("msgFromEntryID", "");
				}
				
				// perform search				
				var qryEntries = appService.searchEntries(argumentCollection = criteria);
	
				// save the last entryID on a cookie, this allows to detect unread entries
				var lastEntryID = getHighestEntryID(qryEntries);
				if(not structKeyExists(cookie,"lastbugread")) {
					writeCookie("lastbugread",lastEntryID,30);
				}
				setValue("lastbugread", cookie.lastbugread);
	
				// set the page title to reflect any recenly received messages
				if(lastEntryID gt cookie.lastbugread) 
					setValue("pageTitle", "Details View (#lastEntryID-cookie.lastbugread#)");
				else
					setValue("pageTitle", "Details View");
					
				setValue("qryEntries", qryEntries);
				setValue("refreshSeconds",refreshSeconds);
				setValue("rowsPerPage",rowsPerPage);
				setView("log");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}
		</cfscript>
	</cffunction>

	<cffunction name="entry" access="public" returntype="void">
		<cfscript>
			try {
				var appService = getService("app"); 
				var entryID = getValue("entryID");
				var argsSearch = {};
				var qryEntriesUA = queryNew("");

				if(val(entryID) eq 0) {
					setMessage("warning","Please select an entry to view");
					setNextEvent("main");
				}		
				
				// get requested entry object
				oEntry = appService.getEntry(entryID);
				
				// search for recent ocurrences (last 24 hours)
				args.message = "__EMPTY__";
				args.startDate = dateAdd("d", -1, now());
				args.searchTerm = "";
				args.applicationID = oEntry.getApplicationID();
				if(oEntry.getMessage() neq "")
					args.message = oEntry.getMessage();
				var qryEntriesLast24 = appService.searchEntries(argumentCollection = args);
				var qryEntriesAll = appService.searchEntries(message = args.message, 
															 searchTerm = "",
															 applicationID = args.applicationID);
				if(oEntry.getUserAgent() neq "") {
					qryEntriesUA = appService.searchEntries(startDate = args.startDate,
																						userAgent = oEntry.getUserAgent(),
																						searchTerm = "");
				}
				
				
				// update lastread setting
				if(structKeyExists(cookie, "lastbugread") and entryID gte cookie.lastbugread) {
					cookie.lastbugread = entryID;
				}
				
				// set values
				setValue("ruleTypes", getService("app").getRules());
				setValue("jiraEnabled", getService("jira").getSetting("enabled"));
				setValue("oEntry", oEntry);
				setValue("qryEntriesLast24", qryEntriesLast24);
				setValue("qryEntriesAll", qryEntriesAll);
				setValue("qryEntriesUA", qryEntriesUA);
				setValue("oEntry", oEntry);
				setView("entry");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("main");
			}
		</cfscript>
	</cffunction>	
	
	<cffunction name="rss" access="public" returntype="void">
		<cfscript>
			try {
				qryApplications = getService("app").getApplications();
				qryHosts = getService("app").getHosts();
				
				// set values
				setValue("qryApplications", qryApplications);
				setValue("qryHosts", qryHosts);
				setValue("pageTitle", "RSS Feeds");
				
				setView("rss");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("main");
			}
		</cfscript>	
	</cffunction>

	<cffunction name="updatePassword" access="public" returntype="void">
		<cfset setView("vwUpdatePassword")>
	</cffunction>
	
	<cffunction name="doStart" access="public" returnType="void">
		<cfscript>
			var nextEvent = getValue("nextEvent");
			try {
				// start service
				getService("app").startService();
				getService("app").getConfig().reload();
				setMessage("info","BugLogListener has been started!");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent(nextEvent);
		</cfscript>	
	</cffunction>
	
	<cffunction name="doStop" access="public" returnType="void">
		<cfset var nextEvent = getValue("nextEvent")>
		<cfset getService("app").stopService()>
		<cfset setMessage("info","BugLogListener has been stopped!")>
		<cfset setNextEvent(nextEvent)>
	</cffunction>

	<cffunction name="doSend" access="public" returnType="void">
		<cfscript>
			try {
				entryID = getValue("entryID",0);
				sender = getService("app").getConfig().getSetting("adminEmail");
				recipient = getValue("to","");
				comment = getValue("comment","");
				
				if(val(entryID) eq 0) throw("Please select an entry to send");		
				if(recipient eq "") throw("Please enter the email address of the recipient");
				if(sender eq "") throw("The sender email address has not been configured.");
				
				oEntry = getService("app").sendEntry(entryID, sender, recipient, comment);
				
				setMessage("info","Email has been sent!");
			
			} catch(custom e) {
				setMessage("warning",e.message);

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("entry","entryID=#entryID#");
		</cfscript>		
	</cffunction>
	
	<cffunction name="doLogin" access="public" returnType="void">
		<cfscript>
			var username = "";
			var password = "";
			var userID = 0;
			var nextEvent = getValue("nextEvent");
			var qs = "";

			try {
				username = getValue("username","");
				password = getValue("password","");
				
				if(username eq "") throw("Please enter your username");		
				if(password eq "") throw("Please enter your password");
				if(nextEvent eq "") nextEvent = "";
				
				userID = getService("app").checkLogin(username, password);
				if(userID eq 0) throw("Invalid username/password combination");
				session.userID = abs(userID);
				session.user = getService("app").getUserByID(abs(userID));

				if(userID lt 0) {
					session.requirePasswordChange = true;
					setMessage("warning","Please update your password");
					setNextEvent("updatePassword");
				}

				// build new query string
				var parts = listToArray(cgi.QUERY_STRING,"&");
				var paramName = "";
				var paramValue = "";
				for(var i=1;i lte arrayLen(parts);i++) {
					paramName = listFirst(parts[i],"=");
					paramValue = listLast(parts[i],"=");
					if(paramName neq "event" and paramName neq "resetapp" and paramName neq "nextevent")
						qs = listAppend(qs, paramName & "=" & paramValue, "&");
				}

				setNextEvent(nextEvent,qs);
				
			} catch(custom e) {
				setMessage("warning",e.message);
				setNextEvent("login");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("login");
			}

		</cfscript>		
	</cffunction>
	
	<cffunction name="doUpdatePassword" access="public" returnType="void">
		<cfscript>
			var newPassword = getValue("newPassword");
			var newPassword2 = getValue("newPassword2");
			var user = session.user;
			
			try {
				if(!structKeyExists(session,"requirePasswordChange")) setNextEvent("main");
				if(newPassword eq "") {setMessage("warning","Your password cannot be empty"); setNextEvent("updatePassword");}
				if(newPassword neq newPassword2) {setMessage("warning","The new passwords do not match"); setNextEvent("updatePassword");}
				getService("app").setUserPassword(user, newPassword);
				structDelete(session,"requirePasswordChange");
				setMessage("info","Your password has been updated");
				setNextEvent("main");
							
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("admin.main","panel=changePassword");				
			}
		</cfscript>
	</cffunction>

	<cffunction name="doLogoff" access="public" returnType="void">
		<cfset structDelete(session,"userID")>
		<cfset structDelete(session,"user")>
		<cfset setMessage("information","Thank you for using BugLogHQ")>
		<cfset setNextEvent("login")>
	</cffunction>
				
	<cffunction name="doDelete" access="public" returnType="void">
		<cfscript>
			var appService = getService("app");
			var entryID = val(getValue("entryID"));
			var deleteScope = getValue("deleteScope");
			
			try {
				if(entryID eq 0)
					setNextEvent("");
				var numDeleted = appService.deleteEntry(entryID, deleteScope);
				setMessage("info","#numDeleted# Report(s) deleted");
				setNextEvent("");
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				if(entryID gt 0)
					setNextEvent("entry","entryID=#entryID#");
				else
					setNextEvent("");
			}
		</cfscript>
	</cffunction>			
				
				
	<cffunction name="writeCookie" access="private">
		<cfargument name="name" type="string">
		<cfargument name="value" type="string">
		<cfargument name="expires" type="string">
		<cfcookie name="#arguments.name#" value="#arguments.value#" expires="#arguments.expires#">
	</cffunction>
	
	<cffunction name="prepareFilter" access="private">
		<cfargument name="criteriaName" type="string" default="criteria">
		<cfscript>
			var criteria = structNew();
			var resetCriteria = getValue("resetCriteria", false);
			var appService = getService("app"); 

			if(resetCriteria) {
				structDelete(cookie,criteriaName);
				writeCookie(criteriaName,"","now");
			}
			
			if(structKeyExists(cookie,criteriaName) and isJSON(cookie[criteriaName])) {
				criteria = deserializeJSON(cookie[criteriaName]);
			}
			
			// make sure we have a complete criteria struct w/ default values
			if(not isStruct(criteria)) criteria = structNew();
			if(not structKeyExists(criteria,"numdays")) criteria.numDays = 1;
			if(not structKeyExists(criteria,"searchTerm")) criteria.searchTerm = "";
			if(not structKeyExists(criteria,"applicationID")) criteria.applicationID = 0;
			if(not structKeyExists(criteria,"hostID")) criteria.hostID = 0;
			if(not structKeyExists(criteria,"severityID")) criteria.severityID = "_ALL_";
			if(not structKeyExists(criteria,"search_cfid")) criteria.search_cfid = "";
			if(not structKeyExists(criteria,"search_cftoken")) criteria.search_cftoken = "";
			if(not structKeyExists(criteria,"enddate")) criteria.enddate = "1/1/3000";
			if(not structKeyExists(criteria,"groupByApp")) criteria.groupByApp = true;
			if(not structKeyExists(criteria,"groupByHost")) criteria.groupByHost = true;
			if(not structKeyExists(criteria,"searchHTMLReport")) criteria.searchHTMLReport = false;
			if(not structKeyExists(criteria,"sortBy")) criteria.sortBy = "";
			if(not structKeyExists(criteria,"sortDir")) criteria.sortDir = "asc";
			
			criteria = {
				numDays = getValue("numDays", criteria.numDays),
				searchTerm = getValue("searchTerm", criteria.searchTerm),
				applicationID = getValue("applicationID", criteria.applicationID),
				hostID = getValue("hostID", criteria.hostID),
				severityID = getValue("severityID", criteria.severityID),
				search_cfid = getValue("search_cfid", criteria.search_cfid),
				search_cftoken = getValue("search_cftoken", criteria.search_cftoken),
				startdate = now(),
				enddate = getValue("endDate", criteria.enddate),
				groupByApp = getValue("groupByApp", criteria.groupByApp),
				groupByHost = getValue("groupByHost", criteria.groupByHost),
				searchHTMLReport = getValue("searchHTMLReport", criteria.searchHTMLReport),
				sortBy = getValue("sortBy", criteria.sortBy),
				sortDir = getValue("sortDir", criteria.sortDir)
			};

			// calculate how far back to query the data
			if(isNumeric(criteria.numdays)) {
				if(criteria.numdays lt 1) 
					criteria.startDate = dateAdd("h", criteria.numDays * 24 * -1, now());
				else
					criteria.startDate = dateAdd("d", val(criteria.numDays) * -1, now());
			}

			// write cookie back
			writeCookie(criteriaName,serializeJSON(criteria),30);

			qrySeverities = appService.getSeverities();
			
			setValue("criteria", criteria);
			setValue("qrySeverities", qrySeverities);
		</cfscript>
	</cffunction>
	
	<cffunction name="loadFilter" access="private" returntype="void">
		<cfargument name="criteriaName" type="string" default="criteria">
		<cfscript>
			if(structKeyExists(cookie,criteriaName) and isJSON(cookie[criteriaName])) {
				criteria = deserializeJSON(cookie[criteriaName]);
				setValue("criteria", criteria);
			} else {
				prepareFilter(criteriaName);
			}
		</cfscript>		
	</cffunction>
	
	<cffunction name="getHighestEntryID" access="private" returntype="numeric">
		<cfargument name="qryEntries" type="query" required="true">
		<cfset var qry = 0>
		<cfquery name="qry" dbtype="query" maxrows="1">
			SELECT MAX(entryID) as entryID
				FROM qryEntries
				ORDER BY entryID DESC
		</cfquery>
		<cfreturn val(qry.entryID)>
	</cffunction>
</cfcomponent>