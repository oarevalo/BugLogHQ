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
				if(not listFindNoCase("doLogin,login,rss.rss",event) and 
					(session.userID eq 0)) {
					setMessage("Warning","Please enter your username and password");
					for(key in url) {
						if(key eq "event")
							qs = qs & "nextevent=" & url.event & "&";
						else
							qs = qs & key & "=" & url[key] & "&";
					}
					setNextEvent("login",qs);
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

	<cffunction name="dashboard" access="public" returntype="void">
		<cfscript>
			var refreshSeconds = 60;
			var appService = getService("app"); 
			var numTriggersToDisplay = 10;

			try {
				// prepare filters panel
				prepareFilter();
				
				// get current filters selected
				criteria = getValue("criteria");
				
				qryData = appService.searchEntries(argumentCollection = criteria);
				qryTriggers = appService.getRecentTriggers(numTriggersToDisplay);

				setValue("qryData",qryData);
				setValue("qryTriggers",qryTriggers);
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
				loadFilter();
				
				// get current filters selected
				criteria = getValue("criteria");
				
				qryData = appService.searchEntries(argumentCollection = criteria);
				qryTriggers = appService.getRecentTriggers(numTriggersToDisplay);

				setValue("qryData",qryData);
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
				prepareFilter();
				
				// get current filters selected
				var criteria = getValue("criteria");
				
				// perform search				
				var qryEntries = appService.searchEntries(argumentCollection = criteria);
	
				// save the last entryID on a cookie, this allows to detect unread entries
				var lastEntryID = arrayMax( listToArray( valueList(qryEntries.entryID) ) );
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
				prepareFilter();
				
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
				var lastEntryID = arrayMax( listToArray( valueList(qryEntries.entryID) ) );
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
				entryID = getValue("entryID");

				if(val(entryID) eq 0) {
					setMessage("warning","Please select an entry to view");
					setNextEvent("main");
				}		
				
				oEntry = getService("app").getEntry(entryID);
				
				// update lastread setting
				if(structKeyExists(cookie, "lastbugread") and entryID gte cookie.lastbugread) {
					cookie.lastbugread = entryID;
				}
				
				// set values
				setValue("ruleTypes", getService("app").getRules());
				setValue("jiraEnabled", getService("jira").getSetting("enabled"));
				setValue("oEntry", oEntry);
				setValue("pageTitle", oEntry.getMessage());
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
				
	<cffunction name="writeCookie" access="private">
		<cfargument name="name" type="string">
		<cfargument name="value" type="string">
		<cfargument name="expires" type="string">
		<cfcookie name="#arguments.name#" value="#arguments.value#" expires="#arguments.expires#">
	</cffunction>
	
	<cffunction name="prepareFilter" access="private">
		<cfscript>
			var criteria = structNew();
			var resetCriteria = getValue("resetCriteria", false);
			var appService = getService("app"); 

			if(resetCriteria) {
				structDelete(cookie,"criteria");
				writeCookie("criteria","","now");
			}
			
			if(structKeyExists(cookie,"criteria") and isJSON(cookie.criteria)) {
				criteria = deserializeJSON(cookie.criteria);
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
			
			criteria = {
				numDays = getValue("numDays", criteria.numDays),
				searchTerm = getValue("searchTerm", criteria.searchTerm),
				applicationID = getValue("applicationID", criteria.applicationID),
				hostID = getValue("hostID", criteria.hostID),
				severityID = getValue("severityID", criteria.severityID),
				search_cfid = getValue("search_cfid", criteria.search_cfid),
				search_cftoken = getValue("search_cftoken", criteria.search_cftoken),
				enddate = getValue("endDate", criteria.enddate),
				groupByApp = getValue("groupByApp", criteria.groupByApp),
				groupByHost = getValue("groupByHost", criteria.groupByHost),
				searchHTMLReport = getValue("searchHTMLReport", criteria.searchHTMLReport)
			};

			// calculate how far back to query the data
			criteria.startDate = dateAdd("d", val(criteria.numDays) * -1, now());

			// write cookie back
			writeCookie("criteria",serializeJSON(criteria),30);

			qryApplications = appService.getApplications();
			qryHosts = appService.getHosts();
			qrySeverities = appService.getSeverities();

			// validate the application code
			if(criteria.applicationID eq "") criteria.applicationID = 0;
			if(criteria.applicationID neq 0 and criteria.applicationID neq "") {
				if(not listfindnocase(valuelist(qryApplications.applicationID), criteria.applicationID)
					and not listfindnocase(valuelist(qryApplications.code), criteria.applicationID)) {
					setMessage("warning","The given application does not exist.");
					criteria.applicationID = 0;
				}
			}

			// validate the host code
			if(criteria.hostID eq "") criteria.hostID = 0;
			if(criteria.hostID neq 0 and criteria.hostID neq "") {
				if(not listfindnocase(valuelist(qryHosts.hostID), criteria.hostID)
					and not listfindnocase(valuelist(qryHosts.hostName), criteria.hostID)) {
					setMessage("warning","The given host does not exist.");
					criteria.hostID = 0;
				}
			}

			setValue("criteria", criteria);
			setValue("qryApplications", qryApplications);
			setValue("qryHosts", qryHosts);
			setValue("qrySeverities", qrySeverities);
		</cfscript>
	</cffunction>
	
	<cffunction name="loadFilter" access="private" returntype="void">
		<cfscript>
			if(structKeyExists(cookie,"criteria") and isJSON(cookie.criteria)) {
				criteria = deserializeJSON(cookie.criteria);
				setValue("criteria", criteria);
			} else {
				prepareFilter();
			}
		</cfscript>		
	</cffunction>
	
</cfcomponent>