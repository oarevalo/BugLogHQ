<cfcomponent extends="eventHandler">
	
	<cffunction name="sendToJira" access="public" returntype="void">
		<cfscript>
			var oJIRA = getService("jira");
			var entryID = getValue("entryID");

			try {
				if(val(entryID) eq 0) throw(type="validation", message="Please select an entry to view");		
				
				oEntry = getService("app").getEntry(entryID);
				projects = oJIRA.getProjects();
				issueTypes = oJIRA.getIssueTypes();
				
				// set values
				setValue("oEntry", oEntry);
				setValue("projects", projects);
				setValue("issueTypes", issueTypes);
				setValue("bugLogEntryHREF", getService("app").getBugEntryHREF(entryID));
				setView("sendToJira");

			} catch(validation e) {
				setMessage("warning",e.message);
				setNextEvent("entry","entryID=#entryID#");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("entry","entryID=#entryID#");
			}
		</cfscript>				
	</cffunction>

	<cffunction name="doSendToJira" access="public" returntype="void">
		<cfscript>
			var oJIRA = getService("jira");
			var entryID = getValue("entryID",0);
			var project = getValue("project");
			var issueType = getValue("issueType");
			var summary = getValue("summary");
			var description = getValue("description");
			var issue = {};
			
			try {
				if(val(entryID) eq 0) throw(type="validation", message="Please select an entry to send");		
				if(summary eq "") throw(type="validation", message="Please enter a summary for this issue");
				
				issue = oJira.createIssue(project,issueType,summary,description);
				
				setMessage("info","Issue ###issue.key# has been added to Jira.");
			
			} catch(validation e) {
				setMessage("warning",e.message);

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("entry","entryID=#entryID#");
			
		</cfscript>
	</cffunction>
	
	<cffunction name="getIssueTypes" access="public" returntype="void">
		<cfscript>
			var oJIRA = getService("jira");
			var projectKey = getValue("projectKey");

			try {
				issueTypes = oJIRA.getIssueTypes(projectKey);
				setValue("data", issueTypes);

			} catch(any e) {
				setValue("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}
			
			setLayout("json");
		</cfscript>			
	</cffunction>
	
</cfcomponent>