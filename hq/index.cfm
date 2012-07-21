<!---
	BugLog HQ 
--->

<!--- create main application controller --->
<cfset app = createObject("component","bugLog.core.coreApp") />


<!--- Framework Settings --->
<cfset app.paths.app = "/bugLog/hq">
<cfset app.paths.core = "/bugLog/core">
<cfset app.paths.coreImages = "../core/images">
<cfset app.paths.html = "">

<cfset app.dirs.handlers = "handlers">
<cfset app.dirs.layouts = "layouts">
<cfset app.dirs.views = "views">

<cfset app.mainHandler = "ehGeneral">
<cfset app.defaultEvent = "dspMain">
<cfset app.defaultLayout = "Layout.Main">
<cfset app.configDoc = "config/config.xml.cfm">


<!--- For named instances, we must tell them where the html assets are located --->
<cfif structKeyExists(request, "bugLogInstance")>
	<cfset app.paths.html = "/bugLog/hq/">
</cfif>


<!--- Invoke controller --->
<cfset app.onRequestStart()>


<!--- Render view --->
<cfinclude template="/bugLog/core/core.cfm">
