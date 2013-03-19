<cfcomponent displayName="extensionsService" hint="This component provides interaction with the extensions mechanism for buglog">
	
	<cfset variables.oDAO = 0>
	<cfset variables.aRules = []>
	
	<!--- this is the path to the extensions components --->
	<cfset variables.extensionsPath = "bugLog.extensions.">
	
	<cffunction name="init" access="public" returnType="extensionsService">
		<cfargument name="dao" type="bugLog.components.lib.dao.DAO" required="true">
		<cfscript>
			// store the dao object for the extensions table
			variables.oDAO = arguments.dao;
	
			// read and parse the different types of extensions
			loadExtensions();
		</cfscript>
						
		<cfreturn this>
	</cffunction>

	<cffunction name="getRules" access="public" returntype="array">
		<cfreturn variables.aRules>
	</cffunction>

	<cffunction name="loadExtensions" access="private" returntype="void">
		<cfset var qry = variables.oDAO.getAll()>
		<cfset var st = {}>
		<cfset var obj = 0>
		<cfset var pathToRuleCFC = "">

		<cfset variables.aRules = []>

		<cfloop query="qry">
			<cfswitch expression="#qry.type#">
				<cfcase value="rule">
					<cfset pathToRuleCFC = variables.extensionsPath & "rules." & qry.name>
					<cfset st = {
								id = qry.extensionID,
								component = pathToRuleCFC,
								description = qry.description,
								config = {},
								enabled = (qry.enabled gt 0),
								createdBy = qry.createdBy,
								createdOn = qry.createdOn
							}>
					<cfif isJson(qry.properties)>
						<cfset st.config = deserializeJSON(qry.properties)>
					</cfif>
					<cfset obj = createObject("component",pathToRuleCFC).init(argumentCollection = st.config)>
					<cfset st.instance = obj>
					<cfset arrayAppend(variables.aRules, duplicate(st))>
				</cfcase>
			</cfswitch>
		</cfloop>	
	</cffunction>

	<cffunction name="removeRule" access="public" returntype="void" hint="removes a rule from the active rules">
		<cfargument name="index" type="string" required="true">
		<cfset variables.oDAO.delete(variables.aRules[index].id)>
		<cfset loadExtensions()>
	</cffunction>
	
	<cffunction name="updateRule" access="public" returntype="void" hint="updates the settings of a rule">
		<cfargument name="index" type="string" required="true">
		<cfargument name="properties" type="struct" required="true">
		<cfargument name="description" type="string" required="false" default="">
		<cfset variables.oDAO.save(id = variables.aRules[index].id,
								description = arguments.description,
								properties = serializeJSON(arguments.properties))>
		<cfset loadExtensions()>
	</cffunction>

	<cffunction name="createRule" access="public" returntype="void" hint="creates a new rule">
		<cfargument name="ruleName" type="string" required="true">
		<cfargument name="properties" type="struct" required="true">
		<cfargument name="description" type="string" required="false" default="">
		<cfargument name="createdBy" type="numeric" required="false" default="0">
		<cfset var args = {name = arguments.ruleName,
							type = 'rule',
							description = arguments.description,
							properties = serializeJSON(arguments.properties),
							enabled = 1}>
		<cfif arguments.createdBy gt 0>
			<cfset args.createdBy = arguments.createdBy>
		</cfif>
		<cfset variables.oDAO.save(argumentCollection = args)>
		<cfset loadExtensions()>
	</cffunction>

	<cffunction name="enableRule" access="public" returntype="void" hint="enables a rule for processing">
		<cfargument name="index" type="string" required="true">
		<cfset variables.oDAO.save(id = variables.aRules[index].id, enabled = 1)>
		<cfset loadExtensions()>
	</cffunction>

	<cffunction name="disableRule" access="public" returntype="void" hint="disables a rule for processing">
		<cfargument name="index" type="string" required="true">
		<cfset variables.oDAO.save(id = variables.aRules[index].id, enabled = 0)>
		<cfset loadExtensions()>
	</cffunction>
	
	<cffunction name="getHistory" access="public" returntype="query" hint="returns the history of rule firings">
		<cfargument name="sinceDate" type="date" required="false" default="1/1/1800">
		<cfargument name="userID" type="numeric" required="false" default="0">
		<cfset var dsn = variables.oDAO.getDataProvider().getConfig().getDSN()>
		<cfset var qry = 0>
		<cfquery name="qry" datasource="#dsn#">
			SELECT el.extensionLogID, el.createdOn,
						ext.extensionID, ext.name, ext.type, ext.description,   
						e.entryID, e.message, e.mydatetime, e.createdOn as entry_createdOn,
						a.applicationID, a.code as application_code,
						h.hostID, h.hostName,
						s.severityID, s.name as severity_code
				FROM bl_extensionlog el
					INNER JOIN bl_Extension ext ON el.extensionID = ext.extensionID
					INNER JOIN bl_Entry e ON el.entryID = e.entryID 
					INNER JOIN bl_Application a ON e.applicationID = a.applicationID
					INNER JOIN bl_Host h ON e.hostID = h.hostID
					INNER JOIN bl_Severity s ON e.severityID = s.severityID
				WHERE 1=1
				<cfif arguments.sinceDate neq "1/1/1800">
					AND el.createdOn >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.sinceDate#">
				</cfif>
				<cfif arguments.userID gt 0>
					AND e.applicationID IN (
						SELECT applicationID 
							FROM bl_UserApplication
							WHERE userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.userID#">
					)
				</cfif>
				ORDER BY el.createdOn DESC
		</cfquery>
		<cfreturn qry>		
	</cffunction>
	
</cfcomponent>