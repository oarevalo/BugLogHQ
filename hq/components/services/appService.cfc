<cfcomponent>
	
	<cfset variables.path = "">
	<cfset variables.cfcPath = "">
	<cfset variables.extensionsPath = "">
	<cfset variables.OSPathSeparator = createObject("java","java.lang.System").getProperty("file.separator")>
	<cfset variables.config = 0>

	<cffunction name="init" access="public" returntype="appService">
		<cfargument name="path" type="string" required="true">
		<cfargument name="config" type="any" required="true">

		<cfset variables.path = arguments.path>
		<cfset variables.config = arguments.config>

		<!--- get the path in dot notation --->
		<cfset variables.cfcPath = replace(variables.path, variables.OSPathSeparator, ".", "ALL")>
		<cfif left(variables.cfcPath,1) eq ".">
			<cfset variables.cfcPath = right(variables.cfcPath, len(variables.cfcPath)-1)>
		</cfif>
		<cfif right(variables.cfcPath,1) eq ".">
			<cfset variables.cfcPath = left(variables.cfcPath, len(variables.cfcPath)-1)>
		</cfif>
		
		<!--- set the path for extensions --->
		<cfset variables.extensionsPath = variables.cfcPath & ".extensions.">

		<!--- Load the DAO objects --->
		<cfset variables.oDAOFactory = createModelObject("components.DAOFactory").init( variables.config )>
		<cfset variables.oApplicationDAO = variables.oDAOFactory.getDAO("application")>
		<cfset variables.oEntryDAO = variables.oDAOFactory.getDAO("entry")>
		<cfset variables.oHostDAO = variables.oDAOFactory.getDAO("host")>
		<cfset variables.oSeverityDAO = variables.oDAOFactory.getDAO("severity")>
		<cfset variables.oSourceDAO = variables.oDAOFactory.getDAO("source")>
		<cfset variables.oUserDAO = variables.oDAOFactory.getDAO("user")>

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
			var oService = createModelObject("components.service").init( true );
			oService.start();
		</cfscript>
	</cffunction>

	<cffunction name="stopService" access="public" returntype="void">
		<cfscript>
			var oService = createModelObject("components.service").init();
			oService.stop();
		</cfscript>
	</cffunction>

	<cffunction name="getServiceSetting" access="public" returntype="string">
		<cfargument name="name" type="string" required="true">
		<cfargument name="value" type="string" required="false" default="">
		<cfscript>
			var oService = createModelObject("components.service").init(true);
			return oService.getSetting(arguments.name, arguments.value);
		</cfscript>
	</cffunction>

	<cffunction name="setAPIsecSettings" access="public" returntype="void">
		<cfargument name="requireAPIKey" type="boolean" required="true">
		<cfargument name="APIKey" type="string" required="true">
		<cfset var configPath = expandPath("#variables.path#/config/service-config.xml.cfm")>
		<cfset var xmlDoc = xmlParse( configPath )>
		
		<cfif not structKeyExists(xmlDoc.xmlRoot,"requireAPIKey")>
			<cfset xmlNode = xmlElemNew(xmlDoc, "requireAPIKey")>
			<cfset arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode)>
		</cfif>
		<cfset xmlDoc.xmlRoot.requireAPIKey.xmlText = arguments.requireAPIKey>

		<cfif not structKeyExists(xmlDoc.xmlRoot,"APIKey")>
			<cfset xmlNode = xmlElemNew(xmlDoc, "APIKey")>
			<cfset arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode)>
		</cfif>
		<cfset xmlDoc.xmlRoot.APIKey.xmlText = xmlFormat(arguments.APIKey)>
		
		<cffile action="write" file="#configPath#" output="#toString(xmlDoc)#">
	</cffunction>

	<cffunction name="searchEntries" access="public" returntype="query">
		<cfargument name="searchTerm" type="string" required="true">
		<cfargument name="applicationID" type="string" required="false" default="0">
		<cfargument name="hostID" type="string" required="false" default="0">
		<cfargument name="severityID" type="string" required="false" default="0">
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
				oFinder = createModelObject("components.appFinder").init( variables.oApplicationDAO );
				o = oFinder.findByCode(arguments.applicationID);
				arguments.applicationID = o.getApplicationID();
			}

			// if hostID is not numeric, assume it is the hostname
			if(Not isNumeric(arguments.hostID)) {
				oFinder = createModelObject("components.hostFinder").init( variables.oHostDAO );
				o = oFinder.findByName(arguments.hostID);
				arguments.hostID = o.getHostID();
			}

			// if severityID is not numeric and is not a list and is not _ALL_, assume it is the severityCode
			if(Not isNumeric(arguments.severityID) and listlen(arguments.severityID) eq 1 and arguments.severityID neq "_ALL_") {
				oFinder = createModelObject("components.severityFinder").init( variables.oSeverityDAO );
				o = oFinder.findByCode(arguments.severityID);
				arguments.severityID = o.getSeverityID();
			}
			
			arguments.applicationID = val(arguments.applicationID);
			arguments.hostID = val(arguments.hostID);
			
			// get entries
			oEntryFinder = createModelObject("components.entryFinder").init( variables.oEntryDAO );
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
			oEntryFinder = createModelObject("components.entryFinder").init( variables.oEntryDAO );
			
			// get entries
			qry = oEntryFinder.findByID(arguments.entryID);
			
			return qry;
		</cfscript>
	</cffunction>
	
	<cffunction name="getApplications" access="public" returntype="query">
		<cfreturn variables.oApplicationDAO.getAll()>
	</cffunction>	

	<cffunction name="getHosts" access="public" returntype="query">
		<cfreturn variables.oHostDAO.getAll()>
	</cffunction>	

	<cffunction name="getSeverities" access="public" returntype="query">
		<cfreturn variables.oSeverityDAO.getAll()>
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
			oFinder = createModelObject("components.userFinder").init( oUserDAO );
			
			// see if the user exists
			try {
				o = oFinder.findByUsername( arguments.username );
				if(o.getPassword() neq arguments.password) {
					return 0;	// wrong password
				}
			
			} catch(userFinderException.usernameNotFound e) {
				return 0;		// wrong username
			}
			
			return o.getUserID();
		</cfscript>		
	</cffunction>

	<cffunction name="purgeHistory" access="public" returntype="void">
		<cfargument name="purgeHistoryDays" type="numeric" required="true">
		<cfargument name="deleteOrphans" type="boolean" required="false" default="false">
		
		<cfset var oDataProvider = variables.oDAOFactory.getDataProvider()>
		<cfset var sql = "">
		<cfset var dbType = oDataProvider.getConfig().getDBType()>
		
		<!--- delete entries --->
		<cfsavecontent variable="sql">
			<cfoutput>
				DELETE 
					FROM bl_Entry
					WHERE
					<cfif dbType eq "mysql">
						createdOn < NOW() - INTERVAL #purgeHistoryDays# DAY
					<cfelseif dbType contains "mssql" or dbType eq "access">
						DATEDIFF(day, GETDATE(), createdOn) > #purgeHistoryDays#
					</cfif>
			</cfoutput>
		</cfsavecontent>
		<cfset oDataProvider.exec(sql)>
		
	</cffunction>


	<!----- Extensions ----->	
	<cffunction name="getRules" access="public" returnType="array" hint="Returns all rules that are available">
		<cfset var tmpRulesPath = "/bugLog/extensions/rules">
		<cfset var aRtn = arrayNew(1)>
		<cfset var st = structNew()>
		
		<cfdirectory action="list" directory="#expandPath(tmpRulesPath)#" name="qryDir" listinfo="name">
		<cfquery name="qryDir" dbtype="query">
			SELECT *
				FROM qryDir
				WHERE name not like '%.svn'
					and name not like '%.cvs'
				ORDER BY name
		</cfquery>	

		<cfloop query="qryDir">
			<cfset st = getCFCInfo(variables.extensionsPath & "rules." & listFirst(qryDir.name,".") )>
			<cfset arrayAppend(aRtn, st)>
		</cfloop>

		<cfreturn aRtn>
	</cffunction>
	
	<cffunction name="getActiveRules" access="public" returnType="array" hint="Returns all rules that are active">
		<cfscript>
			// create the extensions service
			var oExtensionsService = createModelObject("components.extensionsService").init();
			return oExtensionsService.getRules();
		</cfscript>
	</cffunction>

	<cffunction name="getRuleInfo" access="public" returnType="struct" hint="Returns information about a given rule">
		<cfargument name="ruleName" type="string" required="true">
		<cfreturn getCFCInfo(variables.extensionsPath & "rules." & arguments.ruleName )>
	</cffunction>

	<cffunction name="saveRule" access="public" returntype="void" hint="adds or updates a rule">
		<cfargument name="index" type="numeric" required="false" default="0">
		<cfargument name="ruleName" type="string" required="true">
		<!--- rule settings are passed as individual arguments --->
		
		<cfscript>
			var stRule = 0; var oExtensionsService = 0;
			var stProperties = 0; var i=0; var prop = "";
			var desc = "";
			
			// get rule info
			stRule = getCFCInfo(variables.extensionsPath & "rules." & arguments.ruleName);
			oExtensionsService = createModelObject("components.extensionsService").init();
			
			stProperties = structNew();
			for(i=1;i lte arrayLen(stRule.properties);i=i+1) {
				prop = stRule.properties[i].name;
				if(structKeyExists(arguments,prop))
					stProperties[prop] = arguments[prop];
			}
			
			if(structKeyExists(arguments,"description"))
				desc = arguments.description;
			
			if(arguments.index gt 0) 
				oExtensionsService.updateRule(arguments.index, stProperties, desc);
			 else 
				oExtensionsService.createRule(arguments.ruleName, stProperties, desc);
		</cfscript>
		
	</cffunction>

	<cffunction name="deleteRule" access="public" returntype="void" hint="delete a rule">
		<cfargument name="index" type="numeric" required="false" default="0">
		<cfscript>
			var oExtensionsService = createModelObject("components.extensionsService").init();
			oExtensionsService.removeRule(arguments.index);
		</cfscript>		
	</cffunction>

	<cffunction name="enableRule" access="public" returntype="void" hint="enables a rule">
		<cfargument name="index" type="numeric" required="false" default="0">
		<cfscript>
			var oExtensionsService = createModelObject("components.extensionsService").init();
			oExtensionsService.enableRule(arguments.index);
		</cfscript>		
	</cffunction>

	<cffunction name="disableRule" access="public" returntype="void" hint="disables a rule">
		<cfargument name="index" type="numeric" required="false" default="0">
		<cfscript>
			var oExtensionsService = createModelObject("components.extensionsService").init();
			oExtensionsService.disableRule(arguments.index);
		</cfscript>		
	</cffunction>


	<!---- User Management ---->
	<cffunction name="getUserByID" access="public" returntype="bugLog.components.user" hint="return the user for the given userid">
		<cfargument name="userID" type="numeric" required="true">
		<cfscript>
			var oFinder = createModelObject("components.userFinder").init( oUserDAO );
			return oFinder.findByID( arguments.userID );
		</cfscript>
	</cffunction>

	<cffunction name="getUsers" access="public" returntype="query" hint="return a query with all users">
		<cfreturn variables.oUserDAO.getAll()>
	</cffunction>

	<cffunction name="saveUser" access="public" returntype="void" hint="Creates or updates a user">
		<cfargument name="userToSave" type="bugLog.components.user" required="true" hint="a user object">
		<cfset arguments.userToSave.save()>
	</cffunction>

	<cffunction name="deleteUser" access="public" returntype="void" hint="Deletes a user">
		<cfargument name="userToDelete" type="bugLog.components.user" required="true" hint="a user object">
		<cfset variables.oUserDAO.delete( arguments.userToDelete.getUserID() )>
	</cffunction>

	<cffunction name="getBlankUser" access="public" returntype="bugLog.components.user" hint="return an empty user object">
		<cfreturn createObject("component","bugLog.components.user").init( variables.oUserDAO ) />
	</cffunction>
	
	<!----- Private Methods ---->
	<cffunction name="createModelObject" access="private" returntype="any">
		<cfargument name="cfc" type="string" required="true">
		<cfreturn createObject("component", variables.cfcPath & "." & arguments.cfc)>
	</cffunction>
	
	<cffunction name="getCFCInfo" access="private" returntype="struct" hint="returns information about a given cfc">
		<cfargument name="cfcPath" type="string" required="true">
		<cfscript>
			var stMD = structNew();
			var st = structNew();
			var o = 0;
			
			st.description = "";
			st.properties = arrayNew(1);
	
			o = createObject("component",arguments.cfcPath);
			stMD = getMetaData(o);
			
			st.name = stMD.name;
			if(structKeyExists(stMD,"hint")) st.description = stMD.hint;
			if(structKeyExists(stMD,"properties")) st.properties = duplicate(stMD.properties);

			return st;
		</cfscript>
	</cffunction>

</cfcomponent>