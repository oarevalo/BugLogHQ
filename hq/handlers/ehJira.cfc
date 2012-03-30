<cfcomponent extends="eventHandler">
	
	<cffunction name="dspSendToJira" access="public" returntype="void">
		<cfscript>
			var oJIRA = getService("jira");
			var entryID = getValue("entryID");
			var thisHost = '';

			// get the url for the current host
			if(cgi.server_port_secure) thisHost = "https://"; else thisHost = "http://";
			thisHost = thisHost & cgi.server_name;
			if(cgi.server_port neq 80) thisHost = thisHost & ":" & cgi.server_port;
			
			try {
				if(val(entryID) eq 0) throw("Please select an entry to view");		
				
				oEntry = getService("app").getEntry(entryID);
				projects = oJIRA.getProjects();
				issueTypes = oJIRA.getIssueTypes();
				
				// set values
				setValue("oEntry", oEntry);
				setValue("projects", projects);
				setValue("issueTypes", issueTypes);
				setValue("thisHost", thisHost);
				setView("vwSendToJira");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehGeneral.dspEntry","entryID=#entryID#");
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

			setNextEvent("ehGeneral.dspEntry","entryID=#entryID#");
			
		</cfscript>
	</cffunction>
	
</cfcomponent>