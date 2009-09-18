<cfcomponent extends="eventHandler">
	
	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			var qryUsers = 0;
			var app = getService("app");
			var jira = getService("jira");
			var jiraConfig = structNew();
			
			try {
				
				if( user.getIsAdmin() ) {
					qryUsers = app.getUsers();
					
					jiraConfig.enabled = jira.getSetting("enabled",false);
					jiraConfig.wsdl = jira.getSetting("wsdl");
					jiraConfig.username = jira.getSetting("username");
					jiraConfig.password = jira.getSetting("password");
				}	
				
				setValue("requireAPIKey", app.getServiceSetting("requireAPIKey",false));
				setValue("APIKey", app.getServiceSetting("APIKey"));
				setValue("qryUsers",qryUsers);				
				setValue("jiraConfig",jiraConfig);				
				setView("vwAdmin");
				
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
				if(currentPassword neq user.getPassword()) {setMessage("warning","The current password is invalid"); setNextEvent("ehAdmin.dspMain");}
				if(newPassword neq newPassword2) {setMessage("warning","The new passwords do not match"); setNextEvent("ehAdmin.dspMain");}
				user.setPassword(newPassword);
				getService("app").saveUser(user);
				setMessage("info","Password has been changed");
				setNextEvent("ehGeneral.dspMain");
							
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehAdmin.dspMain");				
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="doPurgeHistory" access="public" returntype="void">
		<cfscript>
			var purgeHistoryDays = val(getValue("purgeHistoryDays"));
			var deleteOrphans = getValue("deleteOrphans",false);
			var user = getValue("currentUser");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning","You must be an administrator to purge history"); setNextEvent("ehAdmin.dspMain");}
				getService("app").purgeHistory(purgeHistoryDays, deleteOrphans);
				setMessage("info","History purged");
				setNextEvent("ehGeneral.dspMain");
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehAdmin.dspMain");				
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
			
			try {
				if(userID gt 0) 
					oUser = getService("app").getUserByID(userID);
				else
					oUser = getService("app").getBlankUser();

				oUser.setUsername(username);
				oUser.setPassword(password);
				oUser.setIsAdmin(isAdmin);

				getService("app").saveUser(oUser);
				setMessage("info","User information has been saved");
				setNextEvent("ehAdmin.dspMain");
							
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
				if(not user.getIsAdmin()) {setMessage("warning","You must be an administrator to delete a user"); setNextEvent("ehAdmin.dspMain");}
				getService("app").deleteUser(userID);
				setMessage("info","User has been deleted");
				setNextEvent("ehAdmin.dspMain");
							
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehAdmin.dspUser");
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
				if(not user.getIsAdmin()) {setMessage("warning","You must be an administrator to set the API security settings"); setNextEvent("ehAdmin.dspMain");}
				if(generateNewKey neq "") APIKey = createUUID();
				getService("app").setAPIsecSettings(requireAPIKey, APIKey);
				setMessage("info","API security settings updated. You must restart the BugLogListener service for changes to take effect.");
				setNextEvent("ehAdmin.dspMain");
							
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehAdmin.dspMain");
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
				if(not user.getIsAdmin()) {setMessage("warning","You must be an administrator to set the JIRA integration settings"); setNextEvent("ehAdmin.dspMain");}
				getService("jira").setSetting("enabled", enabled)
									.setSetting("wsdl", wsdl)
									.setSetting("username", username)
									.setSetting("password", password)
									.saveSettings();

				setMessage("info","JIRA integration settings updated.");
				setNextEvent("ehAdmin.dspMain");
							
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehAdmin.dspMain");
			}
		</cfscript>	
	</cffunction>	
			
</cfcomponent>