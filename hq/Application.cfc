<cfcomponent extends="bugLog.core.coreApp">
	
	<!--- Application settings --->
	<cfset this.name = "bugLogHQ"> 
	<cfset this.clientManagement = false> 
	<cfset this.sessionManagement = true> 
	<cfset this.setClientCookies = true>
	<cfset this.setDomainCookies = false>	

	<!--- Framework Settings --->
	<cfset this.paths.app = "/bugLog/hq">
	<cfset this.paths.core = "/bugLog/core">
	<cfset this.paths.html = "">
	
	<cfset this.dirs.handlers = "handlers">
	<cfset this.dirs.layouts = "layouts">
	<cfset this.dirs.views = "views">

	<cfset this.mainHandler = "ehGeneral">
	<cfset this.defaultEvent = "dspMain">
	<cfset this.defaultLayout = "Layout.Main">
	<cfset this.configDoc = "config/config.xml.cfm">

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
			<!--- this is where the html resources are actually located --->
			<cfset this.paths.html = "/bugLog/hq/">
	
			<!--- custom buglog instance name (same as url of containing folder, but without slashes) --->
			<cfset request.bugLogInstance = current_path_dir>
		</cfif>

		<!--- only requests to index.cfm are considered part of the webapp --->
		<cfif getFileFromPath(pageName) eq "index.cfm">
			<cfset super.onRequestStart(pageName)>
		</cfif>
	</cffunction>
	
</cfcomponent>

