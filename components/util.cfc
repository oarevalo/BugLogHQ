<cfcomponent>

	<cffunction name="init" access="public" returnType="util">
		<cfreturn this />
	</cffunction>

	<cffunction name="getBugEntryHREF" access="public" returntype="string" hint="Returns the URL to a given bug report">
		<cfargument name="entryID" type="numeric" required="true" hint="the id of the bug report">
		<cfargument name="config" type="any" required="true" hint="the main config object">
		<cfargument name="instanceName" type="string" required="false" default="default" hint="the current buglog instance name">
		<cfset var buglogHref = getBugLogHQAppHREF(config, instanceName) />
		<cfset var href = buglogHref & "index.cfm?event=entry&entryID=#arguments.entryID#" />
		<cfreturn href />
	</cffunction>

	<cffunction name="getBaseBugLogHREF" access="public" returntype="string" hint="Returns a web accessible URL to buglog">
		<cfargument name="config" type="any" required="true" hint="the main config object">
		<cfargument name="instanceName" type="string" required="false" default="default" hint="the current buglog instance name">
		<cfscript>
			var buglogPath = "";
			var externalURL = config.getSetting("general.externalURL");
			var host = getCurrentHost();
			var innerpath = externalURL;
			var external_is_url = false;

			// normalize instance name
			if(instanceName eq "" or instanceName eq "default")
				instanceName = "bugLog";

			// check if the externalURL setting points to a full URL
			// if this is the case, then that will be assumed to be the location
			// where the bugLog application is installed 
			if(left(externalURL,4) eq "http") {
				external_is_url = true;
				host = externalURL;
				innerpath = "";
			}
			
			// make sure we have a backslash at the end
			if(right(host,1) neq "/")
				host = host & "/";

			// build the path
			if((innerpath eq "/" or (innerpath eq "" and external_is_url)) and instanceName eq "bugLog") {
				buglogPath = host;
			} else {
				if(innerpath eq "/") {
					buglogPath = host & instanceName;
				} else {
					if(left(innerpath,1) eq "/")
						innerpath = right(innerpath,len(innerpath)-1);

					if(innerpath neq "") {
						if(right(innerpath,1) neq "/")
							innerpath = innerpath & "/";
						if(instanceName eq "bugLog")					
							buglogPath = host & innerpath;
						else
							buglogPath = host & innerpath & instanceName;
					} else {
						buglogPath = host & instanceName;
					}
				}
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

	<cffunction name="getParentPath" access="public" returntype="string" hint="returns the path to the parent folder of a given template">
		<cfargument name="templatePath" type="string" required="true">
		<cfset var path = GetDirectoryFromPath(GetDirectoryFromPath(arguments.templatePath).ReplaceFirst( "[\\\/]{1}$", "" ))>
		<cfif path.endsWith("/") or path.endsWith("\")>
			<cfset path = left(path,len(path)-1)>
		</cfif>
		<cfreturn path>
	</cffunction>

</cfcomponent>