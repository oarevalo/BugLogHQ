<cfcomponent>
	
	<cfset variables.instance = {
									jira = 0,
									configPath = "",
									config = { }
								}>
								
	<cffunction name="init" access="public" returntype="jiraService">
		<cfargument name="jiraConfigPath" required="true" type="string">

		<cfset loadConfig( expandPath(arguments.jiraConfigPath) )>
		
		<cfset variables.instance.jira  = createObject("component","bugLog.components.jiraService").init( wsdl = getSetting("wsdl"),
																											username = getSetting("username"),
																											password = getSetting("password") )>
		
		<cfreturn this>
	</cffunction>

	<cffunction name="getProjects" access="public" returntype="array">
		<cfreturn variables.instance.jira.getProjects()>
	</cffunction>

	<cffunction name="getIssueTypes" access="public" returntype="array">
		<cfreturn variables.instance.jira.getIssueTypes()>
	</cffunction>
	
	<cffunction name="createIssue" access="public" returntype="void">
		<cfargument name="project" type="string" required="true">
		<cfargument name="issueType" type="string" required="true">
		<cfargument name="summary" type="string" required="true">
		<cfargument name="description" type="string" required="true">
		<cfreturn variables.instance.jira.createIssue(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="getSetting" returnType="string" access="public" hint="Returns the given config setting, if doesnt exist, returns empty or default value">
		<cfargument name="settingName" type="string" required="true">
		<cfargument name="defaultValue" type="string" required="false" default="">
		<cfset var cfg = getConfig()>
		<cfset var rtn = arguments.defaultValue>
		<cfif structKeyExists(cfg, arguments.settingName)>
			<cfset rtn = cfg[arguments.settingName]>
		</cfif>
		<cfreturn rtn>
	</cffunction>
	
	<cffunction name="setSetting" returntype="jiraService" access="public">
		<cfargument name="settingName" type="string" required="true">
		<cfargument name="settingValue" type="string" required="true">
		<cfset cfg[arguments.settingName] = arguments.settingValue>
		<cfreturn this>
	</cffunction>

	<cffunction name="saveSettings" returntype="void" access="public">
		<cfthrow message="not implemented">
	</cffunction>
	
	
	<!--- Private Methods --->
	
	<cffunction name="loadConfig" returntype="void" access="private" hint="loads config settings into memory">
		<cfargument name="configPath" required="true" type="string">
		<cfscript>
			var cfg = structNew();
			var xmlDoc = 0;
			var xmlNode = 0;
		
			variables.instance.configPath = arguments.configPath;
			
			xmlDoc = xmlParse( variables.instance.configPath );
			
			for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				xmlNode = xmlDoc.xmlRoot.xmlChildren[i];
				cfg[xmlNode.xmlName] = xmlNode.xmlText;
			}

			variables.instance.config = cfg;		
		</cfscript>
	</cffunction>
	
	<cffunction name="getConfig" returnType="struct" access="private" hint="returns the struct with the config settings">
		<cfreturn variables.instance.config>
	</cffunction>

</cfcomponent>