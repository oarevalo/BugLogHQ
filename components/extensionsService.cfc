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

		<cfset variables.aRules = []>

		<cfloop query="qry">
			<cfswitch expression="#qry.type#">
				<cfcase value="rule">
					<cfset st = {
								id = qry.extensionID,
								component = variables.extensionsPath & "rules." & qry.name,
								description = qry.description,
								config = {},
								enabled = (qry.enabled gt 0),
								createdBy = qry.createdBy,
								createdOn = qry.createdOn
							}>
					<cfif isJson(qry.properties)>
						<cfset st.config = deserializeJSON(qry.properties)>
					</cfif>
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
	
</cfcomponent>