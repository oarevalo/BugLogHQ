<cfcomponent extends="eventHandler">
	
	<cfset variables.msgs = {
				userNotAllowed = "You must be an administrator to access this section",
				userNotAllowedAction = "You must be an administrator to modify application settings",
				editingSettingsNotAllowed = "Editing of settings is currently not allowed. All configuration changes must be done directly in the config file. To allow editing settings through the UI you must enable it in your BugLogHQ config file."
			}>
	
	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			var app = getService("app");
			var cfg = getService("config");
			var jira = getService("jira");
			var jiraConfig = structNew();
			var panel = getValue("panel","general");
			
			try {
				switch(panel) {
					case "general":
						if(not user.getIsAdmin()) throw(variables.msgs.userNotAllowed,"validation");
						setValue("adminEmail", cfg.getSetting("general.adminEmail",""));
						setValue("autoStart", app.getServiceSetting("autoStart",true));
						break;

					case "changePassword":
						break;

					case "userManagement":
						if(not user.getIsAdmin()) throw(variables.msgs.userNotAllowed,"validation");
						setValue("qryUsers", app.getUsers() );
						break;

					case "purgeHistory":
						if(not user.getIsAdmin()) throw(variables.msgs.userNotAllowed,"validation");
						setValue("purgeHistoryDays", cfg.getSetting("purging.numberOfDays",30));
						setValue("enabled", cfg.getSetting("purging.enabled",false));
						break;

					case "APISecurity":
						if(not user.getIsAdmin()) throw(variables.msgs.userNotAllowed,"validation");
						setValue("requireAPIKey", app.getServiceSetting("requireAPIKey",false));
						setValue("APIKey", app.getServiceSetting("APIKey"));
						break;

					case "jira":
						if(not user.getIsAdmin()) throw(variables.msgs.userNotAllowed,"validation");
						jiraConfig.enabled = jira.getSetting("enabled",false);
						jiraConfig.wsdl = jira.getSetting("wsdl");
						jiraConfig.username = jira.getSetting("username");
						jiraConfig.password = jira.getSetting("password");
						setValue("jiraConfig",jiraConfig);				
						break;

					case "digest":
						if(not user.getIsAdmin()) throw(variables.msgs.userNotAllowed,"validation");
						digestConfig = app.getDigestSettings();
						setValue("enabled", digestConfig.enabled);			
						setValue("recipients", digestConfig.recipients);			
						setValue("interval", digestConfig.schedulerIntervalHours);			
						setValue("startTime", digestConfig.schedulerStartTime);			
						setValue("sendIfEmpty", digestConfig.sendIfEmpty);			
						break;
				}

				setValue("panel", panel);
				setValue("allowConfigEditing", isConfigEditingAllowed());
				setView("vwAdmin");
				
			} catch(validation e) {
				setMessage("warning",e.message);
				setNextEvent("ehGeneral.dspMain");				

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehGeneral.dspMain");				
			}
		</cfscript>
	</cffunction>

	<cffunction name="dspUser" access="public" returntype="void">
		<cfscript>
			var userID = getValue("userID");
			var oUser = 0;
			
			try {
				if(userID gt 0) 
					oUser = getService("app").getUserByID(userID);
				else
					oUser = getService("app").getBlankUser();
				
				setValue("oUser",oUser);				
				setView("vwEditUser");
				
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehAdmin.dspMain");				
			}
		</cfscript>
	</cffunction>

	<cffunction name="dspDeleteUser" access="public" returntype="void">
		<cfscript>
			var userID = getValue("userID");
			
			try {
				if(userID eq 0) setNextEvent("ehAdmin.dspMain");
				setValue("userID",userID);				
				setView("vwDeleteUser");
				
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehAdmin.dspMain");				
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
				if(getService("app").checkLogin(user.getUsername(), currentPassword) eq 0) {setMessage("warning","The current password is invalid"); setNextEvent("ehAdmin.dspMain","panel=changePassword");}
				if(newPassword eq "") {setMessage("warning","Password cannot be empty"); setNextEvent("ehAdmin.dspMain","panel=changePassword");}
				if(newPassword neq newPassword2) {setMessage("warning","The new passwords do not match"); setNextEvent("ehAdmin.dspMain","panel=changePassword");}
				getService("app").setUserPassword(user, newPassword);
				setMessage("info","Password has been changed");
				setNextEvent("ehAdmin.dspMain","panel=changePassword");
							
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehAdmin.dspMain","panel=changePassword");				
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="doPurgeHistory" access="public" returntype="void">
		<cfscript>
			var purgeHistoryDays = val(getValue("purgeHistoryDays"));
			var runnow = getValue("runnow",false);
			var enabled = getValue("enabled",false);
			var user = getValue("currentUser");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning",variables.msgs.userNotAllowedAction); setNextEvent("ehAdmin.dspMain","panel=purgeHistory");}
				getService("config").setSetting("purging.numberOfDays", purgeHistoryDays);
				getService("config").setSetting("purging.enabled", enabled);
				if(runnow) {
					getService("app").purgeHistory(purgeHistoryDays);
					setMessage("info","Settings saved and History purged. The BugLog service must be restarted for changes to take effect.");
				} else {
					setMessage("info","Purge History settings saved. The BugLog service must be restarted for changes to take effect.");
				}
				setNextEvent("ehAdmin.dspMain","panel=purgeHistory");
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehAdmin.dspMain","panel=purgeHistory");				
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
			
			try {
				if(username eq "") throw("Username cannot be empty","validation");
				if(val(userID) eq 0 and password eq "") throw("Password cannot be empty","validation");

				if(userID gt 0) 
					oUser = getService("app").getUserByID(userID);
				else
					oUser = getService("app").getBlankUser();

				oUser.setUsername(username);
				if(userID eq 0) oUser.setPassword(hash(password));
				oUser.setIsAdmin(isAdmin);
				oUser.setEmail(email);

				getService("app").saveUser(oUser);
				setMessage("info","User information has been saved");
				setNextEvent("ehAdmin.dspMain","panel=userManagement");
							
			} catch(validation e) {
				setMessage("warning",e.message);
				setNextEvent("ehAdmin.dspUser","userID=#userID#&username=#username#&isAdmin=#isAdmin#");
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehAdmin.dspUser","userID=#userID#&username=#username#&isAdmin=#isAdmin#");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doDeleteUser" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			var userID = getValue("userID");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning",variables.msgs.userNotAllowedAction); setNextEvent("ehAdmin.dspMain","panel=userManagement");}
				getService("app").deleteUser(userID);
				setMessage("info","User has been deleted");
				setNextEvent("ehAdmin.dspMain","panel=userManagement");
							
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehAdmin.dspMain","panel=userManagement");
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
				if(not user.getIsAdmin()) {setMessage("warning",variables.msgs.userNotAllowedAction); setNextEvent("ehAdmin.dspMain","panel=APISecurity");}
				if(not isConfigEditingAllowed()) {setMessage("warning",variables.msgs.editingSettingsNotAllowed); setNextEvent("ehAdmin.dspMain","panel=APISecurity");}
				if(generateNewKey neq "") APIKey = createUUID();
				getService("app").setServiceSetting("requireAPIKey", requireAPIKey);
				getService("app").setServiceSetting("APIKey", APIKey);
				setMessage("info","API security settings updated. You must restart the BugLogListener service for changes to take effect.");
				setNextEvent("ehAdmin.dspMain","panel=APISecurity");
							
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehAdmin.dspMain","panel=APISecurity");
			}
		</cfscript>	
	</cffunction>	

	<cffunction name="doSaveJiraSettings" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			var enabled = getValue("enabled",false);
			var wsdl = getValue("wsdl");
			var username = getValue("username");
			var password = getValue("password");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning",variables.msgs.userNotAllowedAction); setNextEvent("ehAdmin.dspMain","panel=jira");}
				if(not isConfigEditingAllowed()) {setMessage("warning",variables.msgs.editingSettingsNotAllowed); setNextEvent("ehAdmin.dspMain","panel=jira");}
				getService("jira").setSetting("enabled", enabled)
									.setSetting("wsdl", wsdl)
									.setSetting("username", username)
									.setSetting("password", password);

				setMessage("info","JIRA integration settings updated.");
				setNextEvent("ehAdmin.dspMain","panel=jira");
							
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehAdmin.dspMain","panel=jira");
			}
		</cfscript>	
	</cffunction>	
			
	<cffunction name="doSaveGeneralSettings" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			var autoStart = getValue("autoStart",false);
			var adminEmail = getValue("adminEmail");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning",variables.msgs.userNotAllowedAction); setNextEvent("ehAdmin.dspMain");}
				if(not isConfigEditingAllowed()) {setMessage("warning",variables.msgs.editingSettingsNotAllowed); setNextEvent("ehAdmin.dspMain");}
				getService("app").setServiceSetting("autoStart", autoStart);
				getService("config").reload();
				getService("config").setSetting("general.adminEmail", adminEmail);

				setMessage("info","General settings updated.");
				setNextEvent("ehAdmin.dspMain","panel=general");
							
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehAdmin.dspMain","panel=general");
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
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning",variables.msgs.userNotAllowedAction); setNextEvent("ehAdmin.dspMain","panel=digest");}
				if(not isConfigEditingAllowed()) {setMessage("warning",variables.msgs.editingSettingsNotAllowed); setNextEvent("ehAdmin.dspMain","panel=digest");}
				if(interval eq "") {setMessage("warning","Please set the digest interval"); setNextEvent("ehAdmin.dspMain","panel=digest");};
				if(startTime eq "") {setMessage("warning","Please enter the start time"); setNextEvent("ehAdmin.dspMain","panel=digest");};
				getService("app").setDigestSettings(enabled, recipients, interval, startTime, sendIfEmpty);
				setMessage("info","Digest settings updated.");
				setNextEvent("ehAdmin.dspMain","panel=digest");
							
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehAdmin.dspMain","panel=digest");
			}
		</cfscript>	
	</cffunction>	
		
	<cffunction name="isConfigEditingAllowed" access="private" returntype="boolean">
		<cfset var rtn = false>
		<cfset var allowConfigEditing = getSetting("allowConfigEditing")>
		<cfif isBoolean(allowConfigEditing)>
			<cfset rtn = allowConfigEditing />
		<cfelseif allowConfigEditing eq "">
			<cfset rtn = false />
		<cfelse>
			<cfset rtn = listFindNoCase(allowConfigEditing, getService("config").getConfigKey())>
		</cfif>
		<cfreturn rtn />
	</cffunction>
	
</cfcomponent>