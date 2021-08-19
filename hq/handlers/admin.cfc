<cfcomponent extends="eventHandler">

	<cfset variables.msgs = {
				userNotAllowed = "You must be an administrator to access this section",
				userNotAllowedAction = "You must be an administrator to modify application settings",
				editingSettingsNotAllowed = "Editing of settings is currently not allowed. All configuration changes must be done directly in the config file. To allow editing settings through the UI you must enable it in your BugLogHQ config file."
			}>

	<cffunction name="main" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			var app = getService("app");
			var cfg = app.getConfig();
			var jira = getService("jira");
			var slack = getService("slack");
			var jiraConfig = structNew();
			var slackConfig = structNew();
			var panel = getValue("panel");

			if(panel eq "") {
				if(user.getIsAdmin())
					panel = "general";
				else
					panel = "changePassword";
			}

			try {
				switch(panel) {
					case "general":
						if(not user.getIsAdmin()) throw(type="validation", message=variables.msgs.userNotAllowed);
						setValue("adminEmail", cfg.getSetting("general.adminEmail",""));
						setValue("autoStart", app.getServiceSetting("autoStart",true));
						setValue("allowPublicRSS", cfg.getSetting("rss.allowPublicAccess",false));
						setValue("autoCreateApplication", cfg.getSetting("autocreate.application",true));
						setValue("autoCreateSeverity", cfg.getSetting("autocreate.severity",true));
						setValue("autoCreateHost", cfg.getSetting("autocreate.host",true));
						break;

					case "changePassword":
						break;

					case "userManagement":
						if(not user.getIsAdmin()) throw(type="validation", message=variables.msgs.userNotAllowed);
						setValue("qryUsers", app.getUsers() );
						break;
						
					case "appManagement":
						if(not user.getIsAdmin()) throw(type="validation", message=variables.msgs.userNotAllowed);
						setValue("qryData", app.getApplications() );
						break;

					case "hostManagement":
						if(not user.getIsAdmin()) throw(type="validation", message=variables.msgs.userNotAllowed);
						setValue("qryData", app.getHosts() );
						break;

					case "severityManagement":
						if(not user.getIsAdmin()) throw(type="validation", message=variables.msgs.userNotAllowed);
						setValue("qryData", app.getSeverities() );
						break;

					case "purgeHistory":
						if(not user.getIsAdmin()) throw(type="validation", message=variables.msgs.userNotAllowed);
						setValue("purgeHistoryDays", cfg.getSetting("purging.numberOfDays",30));
						setValue("enabled", cfg.getSetting("purging.enabled",false));
						break;

					case "APISecurity":
						if(not user.getIsAdmin()) throw(type="validation", message=variables.msgs.userNotAllowed);
						setValue("requireAPIKey", app.getServiceSetting("requireAPIKey",false));
						setValue("APIKey", app.getServiceSetting("APIKey"));
						break;

					case "jira":
						if(not user.getIsAdmin()) throw(type="validation", message=variables.msgs.userNotAllowed);
						jiraConfig.enabled = jira.getSetting("enabled",false);
						jiraConfig.endpoint = jira.getSetting("endpoint");
						jiraConfig.username = jira.getSetting("username");
						jiraConfig.password = jira.getSetting("password");
						setValue("jiraConfig",jiraConfig);
						break;

					case "slack":
						if(not user.getIsAdmin()) throw(type="validation", message=variables.msgs.userNotAllowed);
						slackConfig.enabled = slack.getSetting("enabled",false);
						slackConfig.endpoint = slack.getSetting("endpoint");
						setValue("slackConfig",slackConfig);
						break;

					case "digest":
						if(not user.getIsAdmin()) throw(type="validation", message=variables.msgs.userNotAllowed);
						digestConfig = app.getDigestSettings();
						setValue("enabled", digestConfig.enabled);
						setValue("recipients", digestConfig.recipients);
						setValue("interval", digestConfig.schedulerIntervalHours);
						setValue("startTime", digestConfig.schedulerStartTime);
						setValue("sendIfEmpty", digestConfig.sendIfEmpty);
						setValue("app", digestConfig.application);
						setValue("host", digestConfig.host);
						setValue("severity", digestConfig.severity);
						break;

					case "listeners":
						setValue("APIKey", app.getServiceSetting("APIKey"));
						setValue("bugLogHREF", app.getBaseBugLogHREF());
						break;
				}

				setValue("panel", panel);
				setValue("allowConfigEditing", isConfigEditingAllowed());
				setValue("pageTitle", "BugLog Settings & Management");
				setView("admin");
				
			} catch(validation e) {
				setMessage("warning",e.message);
				setNextEvent("main");				

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("main");				
			}
		</cfscript>
	</cffunction>

	<cffunction name="user" access="public" returntype="void">
		<cfscript>
			var userID = getValue("userID");
			var oUser = 0;
			var app = getService("app");
			
			try {
				if(userID gt 0) 
					oUser = app.getUserByID(userID);
				else
					oUser = app.getBlankUser();
				
				setValue("apps",app.getApplications());
				setValue("userApps",app.getUserApplications(val(userID)));
				setValue("oUser",oUser);			
				setValue("pageTitle", "BugLog Settings & Management > Add/Edit User");	
				setView("editUser");
				
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("admin.main");				
			}
		</cfscript>
	</cffunction>

	<cffunction name="deleteUser" access="public" returntype="void">
		<cfscript>
			var userID = getValue("userID");
			
			try {
				if(userID eq 0) setNextEvent("admin.main");
				setValue("userID",userID);				
				setValue("pageTitle", "BugLog Settings & Management > Delete User");	
				setView("deleteUser");
				
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("admin.main");				
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="doChangePassword" access="public" returntype="void">
		<cfscript>
			var currentPassword = getValue("currentPassword");
			var newPassword = getValue("newPassword");
			var newPassword2 = getValue("newPassword2");
			var user = getValue("currentUser");
			
			try {
				if(getService("app").checkLogin(user.getUsername(), currentPassword) eq 0) {setMessage("warning","The current password is invalid"); setNextEvent("admin.main","panel=changePassword");}
				if(newPassword eq "") {setMessage("warning","Password cannot be empty"); setNextEvent("admin.main","panel=changePassword");}
				if(newPassword neq newPassword2) {setMessage("warning","The new passwords do not match"); setNextEvent("admin.main","panel=changePassword");}
				getService("app").setUserPassword(user, newPassword);
				setMessage("info","Password has been changed");
				setNextEvent("admin.main","panel=changePassword");
							
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("admin.main","panel=changePassword");				
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="doPurgeHistory" access="public" returntype="void">
		<cfscript>
			var purgeHistoryDays = val(getValue("purgeHistoryDays"));
			var runnow = getValue("runnow",false);
			var enabled = getValue("enabled",false);
			var user = getValue("currentUser");
			var config = getService("app").getConfig();
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning",variables.msgs.userNotAllowedAction); setNextEvent("admin.main","panel=purgeHistory");}
				config.setSetting("purging.numberOfDays", purgeHistoryDays);
				config.setSetting("purging.enabled", enabled);
				if(runnow) {
					getService("app").purgeHistory(purgeHistoryDays);
					setMessage("info","Settings saved and History purged. The BugLog service must be restarted for changes to take effect.");
				} else {
					setMessage("info","Purge History settings saved. The BugLog service must be restarted for changes to take effect.");
				}
				setNextEvent("admin.main","panel=purgeHistory");
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("admin.main","panel=purgeHistory");				
			}
		</cfscript>
	</cffunction>

	<cffunction name="doSaveUser" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			var userID = getValue("userID");
			var username = getValue("username");
			var password = getValue("password");
			var isAdmin = getValue("isAdmin",false);
			var email = getValue("email");
			var apps = getValue("applicationIDList");
			
			try {
				if(username eq "") throw(type="validation", message="Username cannot be empty");
				if(val(userID) eq 0 and password eq "") throw(type="validation", message="Password cannot be empty");

				if(userID gt 0) 
					oUser = getService("app").getUserByID(userID);
				else
					oUser = getService("app").getBlankUser();

				oUser.setUsername(username);
				if(userID eq 0) oUser.setPassword(hash(password));
				oUser.setIsAdmin(isAdmin);
				oUser.setEmail(email);
				
				if(getValue("removeAPIKey",false))
					oUser.setAPIKey("");
				if(getValue("assignAPIKey",false))
					oUser.setAPIKey(createuuid());
				
				getService("app").saveUser(oUser);
				getService("app").setUserApplications(oUser.getUserID(), listToArray(apps));
				
				setMessage("info","User information has been saved");
				setNextEvent("admin.user","userID=#oUser.getUserID()#");
							
			} catch(validation e) {
				setMessage("warning",e.message);
				setNextEvent("admin.user","userID=#userID#&username=#username#&isAdmin=#isAdmin#");
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("admin.user","userID=#userID#&username=#username#&isAdmin=#isAdmin#");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doDeleteUser" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			var userID = getValue("userID");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning",variables.msgs.userNotAllowedAction); setNextEvent("admin.main","panel=userManagement");}
				getService("app").deleteUser(userID);
				setMessage("info","User has been deleted");
				setNextEvent("admin.main","panel=userManagement");
							
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("admin.main","panel=userManagement");
			}
		</cfscript>
	</cffunction>
		
	<cffunction name="doSetAPISecSettings" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			var requireAPIKey = getValue("requireAPIKey",false);
			var APIKey = getValue("APIKey");
			var generateNewKey = getValue("generateNewKey");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning",variables.msgs.userNotAllowedAction); setNextEvent("admin.main","panel=APISecurity");}
				if(not isConfigEditingAllowed()) {setMessage("warning",variables.msgs.editingSettingsNotAllowed); setNextEvent("admin.main","panel=APISecurity");}
				if(generateNewKey neq "") APIKey = createUUID();
				getService("app").setServiceSetting("requireAPIKey", requireAPIKey);
				getService("app").setServiceSetting("APIKey", APIKey);
				setMessage("info","API security settings updated. You must restart the BugLogListener service for changes to take effect.");
				setNextEvent("admin.main","panel=APISecurity");
							
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("admin.main","panel=APISecurity");
			}
		</cfscript>	
	</cffunction>	

	<cffunction name="doSaveJiraSettings" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			var enabled = getValue("enabled",false);
			var endpoint = getValue("endpoint");
			var username = getValue("username");
			var password = getValue("password");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning",variables.msgs.userNotAllowedAction); setNextEvent("admin.main","panel=jira");}
				if(not isConfigEditingAllowed()) {setMessage("warning",variables.msgs.editingSettingsNotAllowed); setNextEvent("admin.main","panel=jira");}
				getService("jira").setSetting("enabled", enabled)
									.setSetting("endpoint", endpoint)
									.setSetting("username", username)
									.setSetting("password", password)
									.reinit();

				setMessage("info","JIRA integration settings updated.");
				setNextEvent("admin.main","panel=jira");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("admin.main","panel=jira");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doSaveSlackSettings" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			var enabled = getValue("enabled",false);
			var endpoint = getValue("endpoint");

			try {
				if(not user.getIsAdmin()) {setMessage("warning",variables.msgs.userNotAllowedAction); setNextEvent("admin.main","panel=slack");}
				if(not isConfigEditingAllowed()) {setMessage("warning",variables.msgs.editingSettingsNotAllowed); setNextEvent("admin.main","panel=slack");}
				getService("slack").setSetting("enabled", enabled)
									.setSetting("endpoint", endpoint)
									.reinit();

				setMessage("info","Slack integration settings updated.");
				setNextEvent("admin.main","panel=slack");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("admin.main","panel=slack");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doSaveGeneralSettings" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			var autoStart = getValue("autoStart",false);
			var adminEmail = getValue("adminEmail");
			var allowPublicRSS = getValue("allowPublicRSS",false);
			var autoCreateApplication = getValue("autoCreateApplication",false);
			var autoCreateHost = getValue("autoCreateHost",false);
			var autoCreateSeverity = getValue("autoCreateSeverity",false);
			var config = getService("app").getConfig();
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning",variables.msgs.userNotAllowedAction); setNextEvent("admin.main");}
				if(not isConfigEditingAllowed()) {setMessage("warning",variables.msgs.editingSettingsNotAllowed); setNextEvent("admin.main");}
				getService("app").setServiceSetting("autoStart", autoStart);
				config.reload();
				config.setSetting("general.adminEmail", adminEmail);
				config.setSetting("rss.allowPublicAccess", allowPublicRSS);
				config.setSetting("autoCreate.application", autoCreateApplication);
				config.setSetting("autoCreate.host", autoCreateHost);
				config.setSetting("autoCreate.severity", autoCreateSeverity);

				setMessage("info","General settings updated.");
				setNextEvent("admin.main","panel=general");
							
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("admin.main","panel=general");
			}
		</cfscript>	
	</cffunction>		

	<cffunction name="doSaveDigestSettings" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			var enabled = getValue("enabled",false);
			var recipients = getValue("recipients");
			var interval = getValue("interval");
			var startTime = getValue("startTime");
			var sendIfEmpty = getValue("sendIfEmpty",false);
			var app = getValue("app");
			var host = getValue("host");
			var severity = getValue("severity");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning",variables.msgs.userNotAllowedAction); setNextEvent("admin.main","panel=digest");}
				if(not isConfigEditingAllowed()) {setMessage("warning",variables.msgs.editingSettingsNotAllowed); setNextEvent("admin.main","panel=digest");}
				if(interval eq "") {setMessage("warning","Please set the digest interval"); setNextEvent("admin.main","panel=digest");};
				if(startTime eq "") {setMessage("warning","Please enter the start time"); setNextEvent("admin.main","panel=digest");};
				getService("app").setDigestSettings(enabled, recipients, interval, startTime, sendIfEmpty, severity, app, host);
				setMessage("info","Digest settings settings updated. You must restart the BugLogListener service for changes to take effect.");
				setNextEvent("admin.main","panel=digest");
							
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("admin.main","panel=digest");
			}
		</cfscript>	
	</cffunction>	
		
	<cffunction name="doSaveApplication" access="public" returntype="void">
		<cfscript>
			var id = getValue("id");
			var code = getValue("code");
			var name = getValue("name");
			var user = getValue("currentUser");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning",variables.msgs.userNotAllowedAction); setNextEvent("admin.main");}
				if(code eq "") throw(type="validation", message="Code cannot be empty");
				if(name eq "") throw(type="validation", message="Name cannot be empty");

				getService("app").saveApplication(id,code,name);
				
				setMessage("info","Application has been saved");
				setNextEvent("admin.main","panel=appManagement");
							
			} catch(validation e) {
				setMessage("warning",e.message);
				setNextEvent("admin.main","panel=appManagement&id=#id#&code=#code#&name=#name#");
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("admin.main","panel=appManagement&id=#id#&code=#code#&name=#name#");
			}		
		</cfscript>
	</cffunction>	
		
	<cffunction name="doDeleteApplication" access="public" returntype="void">
		<cfscript>
			var id = val(getValue("id"));
			var entryAction = getValue("entryAction");
			var moveToAppID = val(getValue("moveToAppID"));
			var user = getValue("currentUser");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning",variables.msgs.userNotAllowedAction); setNextEvent("admin.main");}
				if(id eq 0) setNextEvent("admin.main");
				if(entryAction eq "") throw(type="validation", message="Select what action to take with existing bug reports that link to this application");
				if(entryAction eq "move" and moveToAppID eq 0)  throw(type="validation", message="Select the application to migrate existing bug reports that link to this application");

				getService("app").deleteApplication(id,entryAction,moveToAppID);
				
				setMessage("info","Application has been deleted");
				setNextEvent("admin.main","panel=appManagement");
							
			} catch(validation e) {
				setMessage("warning",e.message);
				setNextEvent("admin.main","panel=appManagement&id=DELETE:#id#");
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("admin.main","panel=appManagement&id=DELETE:#id#");
			}		
		</cfscript>
	</cffunction>	
		
	<cffunction name="doSaveHost" access="public" returntype="void">
		<cfscript>
			var id = getValue("id");
			var name = getValue("name");
			var user = getValue("currentUser");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning",variables.msgs.userNotAllowedAction); setNextEvent("admin.main");}
				if(name eq "") throw(type="validation", message="Name cannot be empty");

				getService("app").saveHost(id,name);
				
				setMessage("info","Host has been saved");
				setNextEvent("admin.main","panel=hostManagement");
							
			} catch(validation e) {
				setMessage("warning",e.message);
				setNextEvent("admin.main","panel=hostManagement&id=#id#&code=#code#&name=#name#");
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("admin.main","panel=hostManagement&id=#id#&code=#code#&name=#name#");
			}		
		</cfscript>
	</cffunction>	
		
	<cffunction name="doDeleteHost" access="public" returntype="void">
		<cfscript>
			var id = val(getValue("id"));
			var entryAction = getValue("entryAction");
			var moveToHostID = val(getValue("moveToHostID"));
			var user = getValue("currentUser");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning",variables.msgs.userNotAllowedAction); setNextEvent("admin.main");}
				if(id eq 0) setNextEvent("admin.main");
				if(entryAction eq "") throw(type="validation", message="Select what action to take with existing bug reports that link to this host");
				if(entryAction eq "move" and moveToHostID eq 0)  throw(type="validation", message="Select the host name to migrate existing bug reports that link to this host");

				getService("app").deleteHost(id,entryAction,moveToHostID);
				
				setMessage("info","Hostname has been deleted");
				setNextEvent("admin.main","panel=hostManagement");
							
			} catch(validation e) {
				setMessage("warning",e.message);
				setNextEvent("admin.main","panel=hostManagement&id=DELETE:#id#");
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("admin.main","panel=hostManagement&id=DELETE:#id#");
			}		
		</cfscript>
	</cffunction>	

	<cffunction name="doSaveSeverity" access="public" returntype="void">
		<cfscript>
			var id = getValue("id");
			var code = getValue("code");
			var user = getValue("currentUser");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning",variables.msgs.userNotAllowedAction); setNextEvent("admin.main");}
				if(code eq "") throw(type="validation", message="Code cannot be empty");

				getService("app").saveSeverity(id,code);
				
				setMessage("info","Severity has been saved");
				setNextEvent("admin.main","panel=severityManagement");
							
			} catch(validation e) {
				setMessage("warning",e.message);
				setNextEvent("admin.main","panel=severityManagement&id=#id#&code=#code#");
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("admin.main","panel=severityManagement&id=#id#&code=#code#");
			}		
		</cfscript>
	</cffunction>	
		
	<cffunction name="doDeleteSeverity" access="public" returntype="void">
		<cfscript>
			var id = val(getValue("id"));
			var entryAction = getValue("entryAction");
			var moveToSeverityID = val(getValue("moveToSeverityID"));
			var user = getValue("currentUser");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning",variables.msgs.userNotAllowedAction); setNextEvent("admin.main");}
				if(id eq 0) setNextEvent("admin.main");
				if(entryAction eq "") throw(type="validation", message="Select what action to take with existing bug reports that link to this severity");
				if(entryAction eq "move" and moveToSeverityID eq 0)  throw(type="validation", message="Select the severity to migrate existing bug reports that link to this severity");

				getService("app").deleteSeverity(id,entryAction,moveToSeverityID);
				
				setMessage("info","Severity code has been deleted");
				setNextEvent("admin.main","panel=severityManagement");
							
			} catch(validation e) {
				setMessage("warning",e.message);
				setNextEvent("admin.main","panel=severityManagement&id=DELETE:#id#");
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("admin.main","panel=severityManagement&id=DELETE:#id#");
			}		
		</cfscript>
	</cffunction>	
						
	<cffunction name="isConfigEditingAllowed" access="private" returntype="boolean">
		<cfset var rtn = false>
		<cfset var allowConfigEditing = getSetting("allowConfigEditing")>
		<cfset var config = getService("app").getConfig()>
		<cfif isBoolean(allowConfigEditing)>
			<cfset rtn = allowConfigEditing />
		<cfelseif allowConfigEditing eq "">
			<cfset rtn = false />
		<cfelse>
			<cfset rtn = listFindNoCase(allowConfigEditing, config.getConfigKey())>
		</cfif>
		<cfreturn rtn />
	</cffunction>
	
</cfcomponent>
