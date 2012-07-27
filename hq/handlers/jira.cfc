<cfcomponent extends="eventHandler">
	
	<cffunction name="sendToJira" access="public" returntype="void">
		<cfscript>
			var oJIRA = getService("jira");
			var entryID = getValue("entryID");

			try {
				if(val(entryID) eq 0) throw("Please select an entry to view");		
				
				oEntry = getService("app").getEntry(entryID);
				projects = oJIRA.getProjects();
				issueTypes = oJIRA.getIssueTypes();
				
				// set values
				setValue("oEntry", oEntry);
				setValue("projects", projects);
				setValue("issueTypes", issueTypes);
				setValue("bugLogEntryHREF", getService("app").getBugEntryHREF(entryID));
				setView("sendToJira");

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
			
			try {
				if(val(entryID) eq 0) throw("Please select an entry to send");		
				if(summary eq "") throw("Please enter a summary for this issue");
				
				oJira.createIssue(project,issueType,summary,description);
				
				setMessage("info","Bug report sent to JIRA!");
			
			} catch(custom e) {
				setMessage("warning",e.message);

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("entry","entryID=#entryID#");
			
		</cfscript>
	</cffunction>
	
</cfcomponent>