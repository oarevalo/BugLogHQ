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
			var publicEvents = "doLogin,login,requireLogin,rss";
			var noLoginRedirectEvents = "dashboardContent";
			var loginEvent = "login";

			// url path used to find html/js/css resources
			var assetsPath = app.getLocalAssetsPath();
			setValue("_coreImagesPath",assetsPath & "../core/images");

			try {
				if(not structKeyExists(session,"userID")) session.userID = 0;
				if(not structKeyExists(session,"user")) session.user = 0;

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

				// get a util function used for date formatting
				var dateConvertZFunc = createObject("component","bugLog.components.util").dateConvertZ;

				// set generally available values on the request context
				setValue("hostName", hostName);
				setValue("applicationTitle", appTitle);
				setValue("stInfo", stInfo);
				setValue("versionTag", versionTag);
				setValue("currentUser", session.user);
				setValue("dateFormatMask",config.getSetting("general.dateFormat",""));
				setValue("timezoneInfo",config.getSetting("general.timezoneInfo",""));
				setValue("configKey", config.getConfigKey());
				setValue("instanceName", app.getInstanceName());
				setValue("assetsPath", assetsPath);
				setValue("dateConvertZ", dateConvertZFunc);
				setValue("bugTracker", getService("bugTracker"));

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}
		</cfscript>

	</cffunction>

	<cffunction name="onRequestEnd">
		<!--- code to execute at the end of each request --->
	</cffunction>

	<cffunction name="onError">
		<cfset var e = getValue("exception")>
		<cfparam name="e.message" default="">
		<cfset getService("bugTracker").notifyService(e.message, e)>
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

				// ensure that we are grouping at least by message
				criteria.groupByMsg = true;

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
				var criteria = getValue("criteria");

				// for the dashboard, we need the raw data to do adhoc queries
				criteria.groupByMsg = false;
				criteria.groupByApp = false;
				criteria.groupByHost = false;

				var qryEntries = appService.searchEntries(argumentCollection = criteria);
				var qryTriggers = appService.getExtensionsLog(criteria.startDate, getValue("currentUser"));

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

				// ensure that we are grouping at least by message
				criteria.groupByMsg = true;

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

				// ensure that we are not grouping anything
				criteria.groupByMsg = false;
				criteria.groupByApp = false;
				criteria.groupByHost = false;

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
				var entryUUID = getValue("uuid");
				var argsSearch = {};
				var qryEntriesUA = queryNew("");
				var currentUser = getValue("currentUser");
				var oEntry = 0;

				// get requested entry object
				if(entryID gt 0) {
					oEntry = appService.getEntry(entryID, currentUser);
				} else if(len(entryUUID)) {
					oEntry = appService.getEntryByUUID(entryUUID, currentUser);
				} else {
					setMessage("warning","Please select an entry to view");
					setNextEvent("main");
				}

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
															 applicationID = args.applicationID,
															 user = currentUser);
				if(oEntry.getUserAgent() neq "") {
					qryEntriesUA = appService.searchEntries(startDate = args.startDate,
															userAgent = oEntry.getUserAgent(),
															searchTerm = "",
															 user = currentUser);
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

			} catch(notAllowed e) {
				setMessage("warning","You are not allowed to view this bug report");
				setNextEvent("main");

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
				var appService = getService("app");
				var rssService = getService("rss");
				var summary = getValue("summary",false);

				// check if we allow public/unauthenticated access to the RSS feeds
				var isPublicAccessAllowed = appService.getConfig().getSetting("rss.allowPublicAccess",false);

				// if public access is not allowed, see if client is sending a username/password to authenticate
				// if so, then try to authenticate with that, otherwise deny access
				if(!isPublicAccessAllowed) {
					var userID = 0;
					if(getValue("username") neq "" and getValue("password") neq "") {
						// maybe is sent on the URL
						userID = appService.checkLogin(username, password);
					} else {
						// otherwise request to be sent using HTTP Basic Authentication
						var authHeader = GetPageContext().getRequest().getHeader("Authorization");
						var authString = "";
						if(isDefined("authHeader")) {
							authString = ToString(BinaryDecode(ListLast(authHeader, " "),"Base64"));
							userID = appService.checkLogin(GetToken(authString,1,":"), GetToken(authString,2,":"));
						}
					}
					if(userID eq 0) throw(type="notAllowed");
				}

				var criteria = normalizeCriteria();
				criteria.groupByMsg = summary;
				
				var rssXML = appService.buildRSSFeed(criteria, rssService);

				setValue("rssXML", rssXML);
				setView("feed");
				setLayout("xml");

			} catch(notAllowed e) {
				sendUnauthorizedHeader();
				setMessage("warning", "Public access to RSS feeds is not allowed. Sorry.");
				setView("");
				setLayout("clean");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setView("");
				setLayout("clean");
			}
		</cfscript>
	</cffunction>

	<cffunction name="updatePassword" access="public" returntype="void">
		<cfset setView("updatePassword")>
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
		<cfscript>
			var nextEvent = getValue("nextEvent");
			try {
				// stop service
				getService("app").stopService();
				setMessage("info","BugLogListener has been stopped!");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent(nextEvent);
		</cfscript>
	</cffunction>

	<cffunction name="doSend" access="public" returnType="void">
		<cfscript>
			try {
				entryID = getValue("entryID",0);
				sender = getService("app").getConfig().getSetting("general.adminEmail");
				recipient = getValue("to","");
				comment = getValue("comment","");

				if(val(entryID) eq 0) throw(type="validation", message="Please select an entry to send");
				if(recipient eq "") throw(type="validation", message="Please enter the email address of the recipient");
				if(sender eq "") throw(type="validation", message="The sender email address has not been configured.");

				oEntry = getService("app").sendEntry(entryID, sender, recipient, comment);

				setMessage("info","Email has been sent!");

			} catch(validation e) {
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

				if(username eq "") throw(type="validation", message="Please enter your username");
				if(password eq "") throw(type="validation", message="Please enter your password");
				if(nextEvent eq "") nextEvent = "";

				userID = getService("app").checkLogin(username, password);
				if(userID eq 0) throw(type="validation", message="Invalid username/password combination");
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

			} catch(validation e) {
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
			var currentUser = getValue("currentUser");

			if(resetCriteria) {
				structDelete(cookie,criteriaName);
				writeCookie(criteriaName,"","now");
			}

			if(structKeyExists(cookie,criteriaName) and isJSON(cookie[criteriaName])) {
				criteria = deserializeJSON(cookie[criteriaName]);
			}

			// make sure we have a complete criteria struct w/ default values
			criteria = normalizeCriteria(criteria);

			// write cookie back
			writeCookie(criteriaName,serializeJSON(criteria),30);

			qrySeverities = appService.getSeverities();

			// set current user (do it now, because we don't want to save that to the cookie)
			criteria.user = currentUser;

			setValue("criteria", criteria);
			setValue("qrySeverities", qrySeverities);
		</cfscript>
	</cffunction>

	<cffunction name="loadFilter" access="private" returntype="void">
		<cfargument name="criteriaName" type="string" default="criteria">
		<cfscript>
			if(structKeyExists(cookie,criteriaName) and isJSON(cookie[criteriaName])) {
				criteria = deserializeJSON(cookie[criteriaName]);
				criteria = normalizeCriteria(criteria);
				criteria.user = getValue("currentUser");
				setValue("criteria", criteria);
			} else {
				prepareFilter(criteriaName);
			}
		</cfscript>
	</cffunction>

	<cffunction name="normalizeCriteria" access="private" returntype="struct">
		<cfargument name="criteria" type="struct" required="false" default="#structNew()#">
		<cfscript>
			var thisEvent = getValue("event");
			var appService = getService("app");

			// make sure we have a complete criteria struct w/ default values
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
			if(not structKeyExists(criteria,"rows")) criteria.rows = 5;

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
				sortDir = getValue("sortDir", criteria.sortDir),
				rows = getValue("rows", criteria.rows)
			};

			// calculate how far back to query the data
			if(isNumeric(criteria.numdays)) {
				if(criteria.numdays lt 1)
					criteria.startDate = dateAdd("h", criteria.numDays * 24 * -1, now());
				else
					criteria.startDate = dateAdd("d", val(criteria.numDays) * -1, now());
			}

			// build a url to tihs page with the full criteria
			var href = "";
			var ignoreList = "startDate,endDate,rows";
			for(var item in criteria) {
				if(criteria[item] neq "" and criteria[item] neq 0 and not listFindNoCase(ignoreList,item))
					href &= "&" & item & "=" & criteria[item];
			}
			criteria.url = "index.cfm?event=#thisEvent#" & href;
			criteria.rssurl = "index.cfm?event=rss" & href;

			return criteria;
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

	<cffunction name="sendUnauthorizedHeader" access="private" returntype="void">
		<cfheader statusCode="401" statusText="UNAUTHORIZED" />
		<cfheader name="WWW-Authenticate" value="Basic realm=""BugLog""" />
	</cffunction>

</cfcomponent>
