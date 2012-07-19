<cfcomponent>
	
	<!--- Application settings --->
	<cfset this.name = "bugLogHQ"> 
	<cfset this.clientManagement = false> 
	<cfset this.sessionManagement = true> 
	<cfset this.setClientCookies = true>
	<cfset this.setDomainCookies = false>	

	<!--- create an application mapping to bugLog location --->
	<cfset this.rootDir = replace(getDirectoryFromPath(getcurrentTemplatePath()),"hq","")>
	<cfset this.mappings[ "/bugLog" ] = left(this.rootDir,len(this.rootDir)-1) />

	<cffunction name="onRequestStart">
		<cfargument name="pageName" type="string" required="false" default="">

		<!--- see if this is a request for a named instance.
			A "named instance" is a separate deployment of buglog under a different directory other than /buglog or web root.
			A single server can host multiple named instances at the same time.
		 --->
		<cfset var current_path_dir = replace(getDirectoryFromPath(cgi.script_name), "/", "", "ALL")>
		<cfif current_path_dir neq "hq" and current_path_dir neq "bugLoghq">
			<!--- custom buglog instance name (same as url of containing folder, but without slashes) --->
			<cfset request.bugLogInstance = current_path_dir>
		</cfif>
	</cffunction>
	
</cfcomponent>

