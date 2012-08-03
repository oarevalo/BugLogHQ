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
			var hours = val(getValue("hours",72));
			var severity = getValue("severity");
			var host = getValue("host");
			var app = getValue("app");
			var refreshSeconds = 60;
			var appService = getService("app"); 

			var criteria = structNew();
			var resetCriteria = getValue("resetCriteria", false);

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
			if(not structKeyExists(criteria,"applicationID")) criteria.applicationID = 0;
			if(not structKeyExists(criteria,"hostID")) criteria.hostID = 0;
			if(not structKeyExists(criteria,"severityID")) criteria.severityID = "_ALL_";
			
			// page params
			numDays = getValue("numDays", criteria.numDays);
			applicationID = getValue("applicationID", criteria.applicationID);
			hostID = getValue("hostID", criteria.hostID);
			severityID = getValue("severityID", criteria.severityID);

			criteria = structNew();
			criteria.numDays = numDays;
			criteria.applicationID = applicationID;
			criteria.hostID = hostID;
			criteria.severityID = severityID;
			writeCookie("criteria",serializeJSON(criteria),30);

			try {
				startDate = dateAdd("d", val(numDays) * -1, now());
				qryApplications = appService.getApplications();
				qryHosts = appService.getHosts();
				qrySeverities = appService.getSeverities();
						
				searchArgs = {
					searchTerm = "", 
					startDate = startDate,
					applicationID = criteria.applicationID,
					hostID = criteria.hostID,
					severityID = criteria.severityID
				};
				
				qryData = appService.searchEntries(argumentCollection = searchArgs);

				setValue("qryData",qryData);
				setValue("refreshSeconds",refreshSeconds);
				setValue("numDays", numDays);
				setValue("applicationID", applicationID);
				setValue("hostID", hostID);
				setValue("severityID", severityID);
				setValue("qryApplications", qryApplications);
				setValue("qryHosts", qryHosts);
				setValue("qrySeverities", qrySeverities);
				setValue("pageTitle", "Dashboard");
				setView("dashboard");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}
		</cfscript>
	</cffunction>

	<cffunction name="main" access="public" returntype="void">
		<cfscript>
			var criteria = structNew();
			var resetCriteria = getValue("resetCriteria", false);

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
			
			
			// page params
			numDays = getValue("numDays", criteria.numDays);
			searchTerm = getValue("searchTerm", criteria.searchTerm);
			applicationID = getValue("applicationID", criteria.applicationID);
			hostID = getValue("hostID", criteria.hostID);
			severityID = getValue("severityID", criteria.severityID);
			search_cfid = getValue("search_cfid", criteria.search_cfid);
			search_cftoken = getValue("search_cftoken", criteria.search_cftoken);
			endDate = getValue("endDate", criteria.enddate);
			searchHTMLReport = getValue("searchHTMLReport", criteria.searchHTMLReport);

			groupByApp = getValue("groupByApp", criteria.groupByApp);
			groupByHost = getValue("groupByHost", criteria.groupByHost);

			// calculate how far back to query the data
			startDate = dateAdd("d", val(numDays) * -1, now());
							
			// perform search				
			qryEntries = getService("app").searchEntries(searchTerm, applicationID, hostID, severityID, startDate, endDate, search_cfid, search_cftoken, searchHTMLReport);

			// set some default values			
			if(applicationID neq "" and Not isNumeric(applicationID)) setValue("applicationID", qryEntries.applicationID);
			if(hostID neq "" and Not isNumeric(hostID)) setValue("hostID", qryEntries.hostID);
			
			// save the last entryID on a cookie, this allows to detect unread entries
			lastEntryID = arrayMax( listToArray( valueList(qryEntries.entryID) ) );
			if(not structKeyExists(cookie,"lastbugread")) {
				writeCookie("lastbugread",lastEntryID,30);
			}
			setValue("lastbugread", cookie.lastbugread);

			// set the page title to reflect any recenly received messages
			if(lastEntryID gt cookie.lastbugread) {
				setValue("applicationTitle", getValue("applicationTitle") & " (#lastEntryID-cookie.lastbugread#)");
			}
			
			criteria = structNew();
			criteria.numDays = numDays;
			criteria.searchTerm = searchTerm;
			criteria.applicationID = applicationID;
			criteria.hostID = hostID;
			criteria.severityID = severityID;
			criteria.search_cfid = search_cfid;
			criteria.search_cftoken = search_cftoken;
			criteria.enddate = enddate;
			criteria.groupByApp = groupByApp;
			criteria.groupByHost = groupByHost;
			criteria.searchHTMLReport = searchHTMLReport;
			writeCookie("criteria",serializeJSON(criteria),30);
		</cfscript>
			
		<!--- perform grouping for summary display --->	
		<cfquery name="qryEntries" dbtype="query">
			SELECT <cfif groupByApp>
						ApplicationCode, ApplicationID, 
					</cfif>
					<cfif groupByHost>
						HostName, HostID, 
					</cfif>
					Message, COUNT(*) AS bugCount, MAX(createdOn) as createdOn, MAX(entryID) AS EntryID, MAX(severityCode) AS SeverityCode
				FROM qryEntries
				GROUP BY 
					<cfif groupByApp>
						ApplicationCode, ApplicationID, 
					</cfif>
					<cfif groupByHost>
						HostName, HostID, 
					</cfif>
					Message
				ORDER BY createdOn DESC
		</cfquery>
		<cfset setValue("qryEntries", qryEntries)>	
			
		<!--- get the data for the filter dropdowns --->
        <cfif groupByApp>
            <cfquery name="qryApplications" dbtype="query">
                SELECT DISTINCT applicationID, applicationCode FROM qryEntries ORDER BY applicationCode
            </cfquery>
        <cfelse>
        	<cfset qryApplications = getService("app").getApplications()>
            <cfquery name="qryApplications" dbtype="query">
                SELECT applicationID, code as applicationCode, name FROM qryApplications ORDER BY code
            </cfquery>
        </cfif>

		<cfif groupByHost>
            <cfquery name="qryHosts" dbtype="query">
                SELECT DISTINCT hostID, hostName FROM qryEntries ORDER BY hostName
            </cfquery>
        <cfelse>
        	<cfset qryHosts = getService("app").getHosts()>
            <cfquery name="qryHosts" dbtype="query">
                SELECT hostID, hostName FROM qryHosts ORDER BY hostName
            </cfquery>
        </cfif>
		
		<cfset qrySeverities = getService("app").getSeverities()>
		<cfquery name="qrySeverities" dbtype="query">
			SELECT severityID, name FROM qrySeverities ORDER BY name
		</cfquery>


		<cfset setValue("numDays", numDays)>	
		<cfset setValue("searchTerm", searchTerm)>	
		<cfset setValue("applicationID", applicationID)>	
		<cfset setValue("hostID", hostID)>	
		<cfset setValue("severityID", severityID)>	
		<cfset setValue("search_cfid", search_cfid)>	
		<cfset setValue("search_cftoken", search_cftoken)>	
		<cfset setValue("endDate", endDate)>	
		<cfset setValue("searchHTMLReport", searchHTMLReport)>	
		<cfset setValue("groupByApp", groupByApp)>	
		<cfset setValue("groupByHost", groupByHost)>	
		<cfset setValue("qryApplications", qryApplications)>	
		<cfset setValue("qryHosts", qryHosts)>	
		<cfset setValue("qrySeverities", qrySeverities)>	
		<cfset setValue("pageTitle", "Summary")>
		<cfset setView("main")>
	</cffunction>
	
	<cffunction name="log" access="public" returntype="void">
		<cfscript>
			// page params
			searchTerm = getValue("searchTerm","");
			msgFromEntryID = getValue("msgFromEntryID",0);
			applicationID = getValue("applicationID",0);
			hostID = getValue("hostID",0);
			severityID = getValue("severityID",0);
			startDate = getValue("startDate","1/1/1800");
			endDate = getValue("endDate","1/1/3000");
			search_cfid = getValue("search_cfid","");
			search_cftoken = getValue("search_cftoken","");
							
			// if we are passing an entryID, then get the message from there
			if(searchTerm eq "" and val(msgFromEntryID) gt 0) {
				oEntry = getService("app").getEntry( msgFromEntryID );
				searchTerm = oEntry.getMessage();
				setValue("searchTerm", searchTerm);
			} else {
				setValue("msgFromEntryID", "");
			}
							
			// perform search				
			qryEntries = getService("app").searchEntries(searchTerm, applicationID, hostID, severityID, startDate, endDate, search_cfid, search_cftoken);
			setValue("qryEntries", qryEntries);
			
			if(applicationID neq "" and Not isNumeric(applicationID)) setValue("applicationID", qryEntries.applicationID);
			if(hostID neq "" and Not isNumeric(hostID)) setValue("hostID", qryEntries.hostID);
			
			// save the last entryID on a cookie, this allows to detect unread entries
			lastEntryID = arrayMax( listToArray( valueList(qryEntries.entryID) ) );
			if(not structKeyExists(cookie,"lastbugread")) {
				cookie.lastbugread = lastEntryID;
			}
			setValue("lastbugread", cookie.lastbugread);

			// set the page title to reflect any recenly received messages
			if(lastEntryID gt cookie.lastbugread) {
				setValue("applicationTitle", getValue("applicationTitle") & " (#lastEntryID-cookie.lastbugread#)");
			}
		</cfscript>
			
		<!--- get the data for the filter dropdowns --->
		<cfquery name="qryApplications" dbtype="query">
			SELECT DISTINCT applicationID, applicationCode FROM qryEntries ORDER BY applicationCode
		</cfquery>
		<cfset setValue("qryApplications", qryApplications)>	

		<cfquery name="qryHosts" dbtype="query">
			SELECT DISTINCT hostID, hostName FROM qryEntries ORDER BY hostName
		</cfquery>
		<cfset setValue("qryHosts", qryHosts)>	

		<cfset setValue("pageTitle", "Details View")>
			
		<cfset setView("log")>	
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
			try {
				// start service
				getService("app").startService();
				getService("app").getConfig().reload();
				setMessage("info","BugLogListener has been started!");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("main");
		</cfscript>	
	</cffunction>
	
	<cffunction name="doStop" access="public" returnType="void">
		<cfset getService("app").stopService()>
		<cfset setMessage("info","BugLogListener has been stopped!")>
		<cfset setNextEvent("main")>
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
	
</cfcomponent>