<cfcomponent name="ehGeneral" extends="eventHandler">

	<cffunction name="onApplicationStart" access="public" returntype="void">
	</cffunction>

	<cffunction name="onRequestStart" access="public" returntype="void">
		<cfscript>
			var appTitle = getSetting("applicationTitle", application.applicationName);
			var event = getEvent();
			var hostName = CreateObject("java", "java.net.InetAddress").getLocalHost().getHostName();
			
			try {
				// make sure that we always access everything via events
				if(event eq "") {
					throw("All requests must specify the event to execute. Direct access to views is not allowed");
				}

				// check login
				if(not listFindNoCase("ehGeneral.doLogin,ehGeneral.dspLogin,ehRSS.dspRSS",event) and 
					(Not structKeyExists(session,"userID") or session.userID eq 0)) {
					setMessage("Warning","Please enter your username and password");
					setNextEvent("ehGeneral.dspLogin");
				}

				// get status of buglog server
				stInfo = getService("app").getServiceInfo();
				
				// set generally available values on the request context
				setValue("hostName", hostName);
				setValue("applicationTitle", appTitle);
				setValue("stInfo", stInfo);

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}
		</cfscript>

	</cffunction>

	<cffunction name="onRequestEnd">
		<!--- code to execute at the end of each request --->
	</cffunction>

	<cffunction name="dspLogin" access="public" returntype="void">
		<cfset setView("vwLogin")>
		<cfset setLayout("Layout.Clean")>
	</cffunction>

	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			// page params
			searchTerm = getValue("searchTerm","");
			applicationID = getValue("applicationID",0);
			hostID = getValue("hostID",0);
			severityID = getValue("severityID",0);
			startDate = getValue("startDate","1/1/1800");
			endDate = getValue("endDate","1/1/3000");
			search_cfid = getValue("search_cfid","");
			search_cftoken = getValue("search_cftoken","");
							
			// perform search				
			qryEntries = getService("app").searchEntries(searchTerm, applicationID, hostID, severityID, startDate, endDate, search_cfid, search_cftoken);
			setValue("qryEntries", qryEntries);
			
			if(applicationID neq "" and Not isNumeric(applicationID)) setValue("applicationID", qryEntries.applicationID);
			if(hostID neq "" and Not isNumeric(hostID)) setValue("hostID", qryEntries.hostID);
			
			// save the last entryID on a cookie, this allows to detect unread entries
			lastEntryID = arrayMax( listToArray( valueList(qryEntries.entryID) ) );
			if(not structKeyExists(client,"lastbugread")) {
				client.lastbugread = lastEntryID;
			}
			setValue("lastbugread", client.lastbugread);

			// set the page title to reflect any recenly received messages
			if(lastEntryID gt client.lastbugread) {
				setValue("applicationTitle", getValue("applicationTitle") & " (#lastEntryID-client.lastbugread#)");
			}
		</cfscript>
			
		<cfset setView("vwMain")>
	</cffunction>
	
	<cffunction name="dspLog" access="public" returntype="void">
		<cfscript>
			// page params
			searchTerm = getValue("searchTerm","");
			applicationID = getValue("applicationID",0);
			hostID = getValue("hostID",0);
			severityID = getValue("severityID",0);
			startDate = getValue("startDate","1/1/1800");
			endDate = getValue("endDate","1/1/3000");
			search_cfid = getValue("search_cfid","");
			search_cftoken = getValue("search_cftoken","");
							
			// perform search				
			qryEntries = getService("app").searchEntries(searchTerm, applicationID, hostID, severityID, startDate, endDate, search_cfid, search_cftoken);
			setValue("qryEntries", qryEntries);
			
			if(applicationID neq "" and Not isNumeric(applicationID)) setValue("applicationID", qryEntries.applicationID);
			if(hostID neq "" and Not isNumeric(hostID)) setValue("hostID", qryEntries.hostID);
			
			// save the last entryID on a cookie, this allows to detect unread entries
			lastEntryID = arrayMax( listToArray( valueList(qryEntries.entryID) ) );
			if(not structKeyExists(client,"lastbugread")) {
				client.lastbugread = lastEntryID;
			}
			setValue("lastbugread", client.lastbugread);

			// set the page title to reflect any recenly received messages
			if(lastEntryID gt client.lastbugread) {
				setValue("applicationTitle", getValue("applicationTitle") & " (#lastEntryID-client.lastbugread#)");
			}
		</cfscript>
			
		<cfset setView("vwLog")>	
	</cffunction>

	<cffunction name="dspEntry" access="public" returntype="void">
		<cfscript>
			try {
				entryID = getValue("entryID");

				if(val(entryID) eq 0) throw("Please select an entry to view");		
				
				oEntry = getService("app").getEntry(entryID);
				
				// update lastread setting
				if(structKeyExists(client, "lastbugread") and entryID gte client.lastbugread) {
					client.lastbugread = entryID;
				}
				
				// set values
				setValue("oEntry", oEntry);
				setView("vwEntry");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehGeneral.dspMain");
			}
		</cfscript>
	</cffunction>	
	
	<cffunction name="dspRSS" access="public" returntype="void">
		<cfscript>
			try {
				qryApplications = getService("app").getApplications();
				qryHosts = getService("app").getHosts();
				
				// set values
				setValue("qryApplications", qryApplications);
				setValue("qryHosts", qryHosts);
				
				setView("vwRSS");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehGeneral.dspMain");
			}
		</cfscript>	
	</cffunction>
	
	<cffunction name="doStart" access="public">
		<cfscript>
			try {
				// start service
				getService("app").startService();
				setMessage("info","BugLogListener has been started!");
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("ehGeneral.dspMain");
		</cfscript>	
	</cffunction>
	
	<cffunction name="doStop">
		<cfset getService("app").stopService()>
		<cfset setMessage("info","BugLogListener has been stopped!")>
		<cfset setNextEvent("ehGeneral.dspMain")>
	</cffunction>

	<cffunction name="doSend" access="public">
		<cfscript>
			try {
				entryID = getValue("entryID",0);
				sender = getSetting("contactEmail");
				recipient = getValue("to","");
				comment = getValue("comment","");
				
				if(val(entryID) eq 0) throw("Please select an entry to send");		
				if(recipient eq "") throw("Please enter the email address of the recipient");
				
				oEntry = getService("app").sendEntry(entryID, sender, recipient, comment);
				
				setMessage("info","Email has been sent!");
			
			} catch(custom e) {
				setMessage("warning",e.message);

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("ehGeneral.dspEntry","entryID=#entryID#");
		</cfscript>		
	</cffunction>
	
	<cffunction name="doLogin" access="public">
		<cfscript>
			var username = "";
			var password = "";
			var userID = 0;
			
			try {
				username = getValue("username","");
				password = getValue("password","");
				
				if(username eq "") throw("Please enter your username");		
				if(password eq "") throw("Please enter your password");
				
				userID = getService("app").checkLogin(username, password);
				if(userID eq 0) throw("Invalid username/password combination");
				
				session.userID = userID;
				setNextEvent("ehGeneral.dspMain");
				
			} catch(custom e) {
				setMessage("warning",e.message);
				setNextEvent("ehGeneral.dspLogin");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehGeneral.dspLogin");
			}

		</cfscript>		
	</cffunction>
	
	<cffunction name="doLogoff" access="public">
		<cfset structDelete(session,"userID")>
		<cfset setMessage("information","Thank you for using BugLogHQ")>
		<cfset setNextEvent("ehGeneral.dspLogin")>
	</cffunction>
		

</cfcomponent>