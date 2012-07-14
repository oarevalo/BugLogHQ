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
	
	<cfset this.dirs.handlers = "handlers">
	<cfset this.dirs.layouts = "layouts">
	<cfset this.dirs.views = "views">

	<cfset this.mainHandler = "ehGeneral">
	<cfset this.defaultEvent = "dspMain">
	<cfset this.defaultLayout = "Layout.Main">
	<cfset this.configDoc = "config/config.xml.cfm">

</cfcomponent>
