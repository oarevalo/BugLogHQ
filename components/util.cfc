<cfcomponent>

	<cffunction name="init" access="public" returnType="util">
		<cfreturn this />
	</cffunction>

	<cffunction name="getBugEntryHREF" access="public" returntype="string" hint="Returns the URL to a given bug report">
		<cfargument name="entryID" type="numeric" required="true" hint="the id of the bug report">
		<cfargument name="config" type="any" required="true" hint="the main config object">
		<cfargument name="instanceName" type="string" required="false" default="default" hint="the current buglog instance name">
		<cfset var buglogHref = getBugLogHQAppHREF(config, instanceName) />
		<cfset var href = buglogHref & "index.cfm?event=ehGeneral.dspEntry&entryID=#arguments.entryID#" />
		<cfreturn href />
	</cffunction>

	<cffunction name="getBaseBugLogHREF" access="public" returntype="string" hint="Returns a web accessible URL to buglog">
		<cfargument name="config" type="any" required="true" hint="the main config object">
		<cfargument name="instanceName" type="string" required="false" default="default" hint="the current buglog instance name">
		<cfscript>
			var buglogPath = "";
			var externalURL = config.getSetting("general.externalURL");

			// if there is an external url defined and it looks like a full URL, 
			// then use that one as the buglog path
			if(externalURL neq "") {
				if(left(externalURL,4) eq "http") {
					buglogPath = externalURL;	
				} else {
					// if the external url is a relative path,
					// then get the host from the current request
					buglogPath = getCurrentHost() & "/" & externalPath;
				}		
			} else {
				// there is no external url defined, so we use
				// the current host and assume the application is located
				// at either the buglog dir or a named instance dir
				if(instanceName eq "default" or instanceName eq "")
					buglogPath = getCurrentHost() & "/bugLog";
				else
					buglogPath = getCurrentHost() & "/" & instanceName;
			}
			
			// make sure we have a backslash at the end
			if(right(buglogPath,1) neq "/")
				buglogPath = buglogPath & "/";
				
			return buglogPath;
		</cfscript>
	</cffunction>

	<cffunction name="getBugLogHQAssetsHREF" access="public" returntype="string" hint="Returns a web accessible URL to use to obtain buglog HQ assets (images,html,js,etc)">
		<cfargument name="config" type="any" required="true" hint="the main config object">
		<cfset var buglogHref = getBaseBugLogHREF(config) & "hq/" />
		<cfreturn buglogHref>
	</cffunction>

	<cffunction name="getBugLogHQAppHREF" access="public" returntype="string" hint="Returns a web accessible URL to buglog HQ app (only for linking into the app code itself, not assets)">
		<cfargument name="config" type="any" required="true" hint="the main config object">
		<cfargument name="instanceName" type="string" required="false" default="default" hint="the current buglog instance name">
		<cfset var buglogHref = getBaseBugLogHREF(config, instanceName) />
		<cfif instanceName eq "default" or instanceName eq "">
			<cfset buglogHref = buglogHref & "hq/">
		</cfif>
		<cfreturn buglogHref>
	</cffunction>

	<cffunction name="getCurrentHost" access="public" returntype="string" hint="gets the current host based on the CGI scope">
		<cfscript>
			var thisHost = "";
			if(cgi.server_port_secure) thisHost = "https://"; else thisHost = "http://";
			thisHost = thisHost & cgi.server_name;
			if(cgi.server_port neq 80 and cgi.server_port neq 443) thisHost = thisHost & ":" & cgi.server_port;
			return thisHost;
		</cfscript>
	</cffunction>

</cfcomponent>