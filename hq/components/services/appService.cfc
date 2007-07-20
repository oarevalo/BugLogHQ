<cfcomponent>
	
	<cfset variables.path = "">
	<cfset variables.cfcPath = "">
	<cfset variables.OSPathSeparator = createObject("java","java.lang.System").getProperty("file.separator")>

	<cffunction name="init" access="public" returntype="appService">
		<cfargument name="path" type="string" required="true">
		
		<cfset variables.path = arguments.path>

		<!--- get the path in dot notation --->
		<cfset variables.cfcPath = replace(variables.path, variables.OSPathSeparator, ".", "ALL")>
		<cfif left(variables.cfcPath,1) eq ".">
			<cfset variables.cfcPath = right(variables.cfcPath, len(variables.cfcPath)-1)>
		</cfif>
		<cfif right(variables.cfcPath,1) eq ".">
			<cfset variables.cfcPath = left(variables.cfcPath, len(variables.cfcPath)-1)>
		</cfif>

		<cfreturn this>		
	</cffunction>

	<!--- Interface for BugLogListener Running Instance ---->

	<cffunction name="getServiceInfo" access="public" returntype="struct">
		<cfscript>
			var stInfo = structNew();
			var oService = createModelObject("components.service").init();
			
			stInfo.isRunning = oService.isRunning();
			stInfo.startedOn = "";
			
			if(stInfo.isRunning) {
				stInfo.startedOn = oService.getService().getStartedOn();
			}
			
			return stInfo;
		</cfscript>
	</cffunction>
	
	<cffunction name="startService" access="public" returntype="void">
		<cfscript>
			var oService = createModelObject("components.service").init();
			oService.start( );
		</cfscript>
	</cffunction>

	<cffunction name="stopService" access="public" returntype="void">
		<cfscript>
			var oService = createModelObject("components.service").init();
			oService.stop();
		</cfscript>
	</cffunction>

	<cffunction name="searchEntries" access="public" returntype="query">
		<cfargument name="searchTerm" type="string" required="true">
		<cfargument name="applicationID" type="string" required="false" default="0">
		<cfargument name="hostID" type="string" required="false" default="0">
		<cfargument name="severityID" type="numeric" required="false" default="0">
		<cfargument name="startDate" type="date" required="false" default="1/1/1800">
		<cfargument name="endDate" type="date" required="false" default="1/1/3000">
		<cfargument name="search_cfid" type="string" required="false" default="">
		<cfargument name="search_cftoken" type="string" required="false" default="">
		<cfscript>
			var oEntryFinder = 0;
			var qry = 0;
			var oFinder = 0;
			var o = 0;

			// if applicationID is not numeric, assume it is the applicationCode
			if(Not isNumeric(arguments.applicationID)) {
				oFinder = createModelObject("components.appFinder").init();
				o = oFinder.findByCode(arguments.applicationID);
				arguments.applicationID = o.getApplicationID();
			}

			// if hostID is not numeric, assume it is the hostname
			if(Not isNumeric(arguments.hostID)) {
				oFinder = createModelObject("components.hostFinder").init();
				o = oFinder.findByName(arguments.hostID);
				arguments.hostID = o.getHostID();
			}
			
			arguments.applicationID = val(arguments.applicationID);
			arguments.hostID = val(arguments.hostID);
			
			// get entries
			oEntryFinder = createModelObject("components.entryFinder").init();
			qry = oEntryFinder.search(argumentCollection = arguments);
			
			return qry;
		</cfscript>
	</cffunction>

	<cffunction name="getEntry" access="public" returntype="any">
		<cfargument name="entryID" type="numeric" required="true">
		<cfscript>
			var oEntryFinder = 0;
			var qry = 0;

			// create the dao factory
			oEntryFinder = createModelObject("components.entryFinder").init();
			
			// get entries
			qry = oEntryFinder.findByID(arguments.entryID);
			
			return qry;
		</cfscript>
	</cffunction>
	
	<cffunction name="getApplications" access="public" returntype="query">
		<cfscript>
			var oDAO = 0;
			var qry = 0;

			// create the dao factory
			oDAO = createModelObject("components.db.DAOFactory").getDAO("application");
			
			// get entries
			qry = oDAO.getAll();
			
			return qry;
		</cfscript>
	</cffunction>	

	<cffunction name="getHosts" access="public" returntype="query">
		<cfscript>
			var oDAO = 0;
			var qry = 0;

			// create the dao factory
			oDAO = createModelObject("components.db.DAOFactory").getDAO("host");
			
			// get entries
			qry = oDAO.getAll();
			
			return qry;
		</cfscript>
	</cffunction>	
	
	<cffunction name="sendEntry" access="public" returntype="void">
		<cfargument name="entryID" type="numeric" required="true">
		<cfargument name="sender" type="string" required="true">
		<cfargument name="recipient" type="string" required="true">
		<cfargument name="comment" type="string" required="false" default="">
		
		<cfset var oEntry = getEntry(arguments.entryID)>
		<cfset var bugURL = "http://#cgi.HTTP_HOST##cgi.script_name#?event=ehGeneral.dspEntry&entryID=#arguments.entryID#">
		
		<cfmail from="#arguments.sender#" 
				to="#arguments.recipient#" 
				type="html" 
				subject="Bug ###arguments.entryID#: #oEntry.getMessage()#">
			<cfif arguments.comment neq "">
				#arguments.comment#
				<hr>
			</cfif>

			<table style="font-size:12px;">
				<tr>
					<td><b>Date/Time:</b></td>
					<td>#lsDateFormat(oEntry.getdatetime())# - #lsTimeFormat(oEntry.getdatetime())#</td>
				</tr>
				<tr>
					<td><b>Application:</b></td>
					<td>#oEntry.getapplication().getName()#</td>
				</tr>
				<tr>
					<td><b>Host:</b></td>
					<td>#oEntry.gethost().getHostName()#</td>
				</tr>
				<tr>
					<td><b>Template Path:</b></td>
					<td>#oEntry.gettemplate_Path()#</td>
				</tr>
				<tr valign="top">
					<td><b>Exception Message:</b></td>
					<td>#oEntry.getexceptionMessage()#</td>
				</tr>
				<tr valign="top">
					<td><b>Exception Detail:</b></td>
					<td>#oEntry.getExceptionDetails()#</td>
				</tr>
			</table>			
			
			<hr>
			Click on the following link to view full bug report: 
			<a href="#bugURL#">#bugURL#</a>
			<br><br><br>
			** This email has been sent from the BugLog server at 
			<a href="http://#cgi.HTTP_HOST##cgi.script_name#">http://#cgi.HTTP_HOST##cgi.script_name#</a>
		</cfmail>
		
	</cffunction>
	
	<cffunction name="checkLogin" access="public" returntype="numeric" hint="Checks username and password, and returns userID of corresponding user. If not correct, returns 0">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		
		<cfscript>
			var oFinder = 0;
			var o = 0;

			// create the finder
			oFinder = createModelObject("components.userFinder").init();
			
			// see if the user exists
			try {
				o = oFinder.findByUsername( arguments.username );
				if(o.getPassword() neq arguments.password) {
					return 0;	// wrong password
				}
			
			} catch(userFinderException.usernameNotFound e) {
				return 0;		// wrong username
			}
			
			return true;
		</cfscript>		
	</cffunction>
	
	<!----- Private Methods ---->
	<cffunction name="createModelObject" access="private" returntype="any">
		<cfargument name="cfc" type="string" required="true">
		<cfreturn createObject("component", variables.cfcPath & "." & arguments.cfc)>
	</cffunction>
	

</cfcomponent>