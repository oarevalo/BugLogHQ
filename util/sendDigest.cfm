<cfparam name="instance" type="string" default="default">
<cfsetting enablecfoutputonly="true">

<!--- Handle service initialization if necessary --->
<cfset oService = createObject("component", "bugLog.components.service").init( instanceName = instance )>
<cfset oAppService = createObject("component","bugLog.components.hq.appService").init(instanceName = instance)>

<cfset oConfig = oService.getConfig()>
<cfset settings = oAppService.getDigestSettings()>

<cfset adminEmail = oConfig.getSetting("general.adminEmail")>
<cfset recipients = adminEmail>

<cfif !settings.enabled>
	<cfoutput>Digest report is not enabled.</cfoutput>
	<cfabort>
</cfif>
<cfif adminEmail eq "" or !isValid("email",adminEmail)>
	<cfoutput>The Administrator Email setting must be a valid email address.</cfoutput>
	<cfabort>
</cfif>

<cfscript>
	if(trim(settings.recipients) neq "" and find("@",settings.recipients))
		recipients = trim(settings.recipients);
</cfscript>

<cfsavecontent variable="tmpHTML">
	<cfoutput>
		<cfinclude template="renderDigest.cfm">
		<p style="font-family: arial,sans-serif;color:##666;font-size:11px;margin-top:20px;">
			** This email has been sent from the BugLogHQ server at 
			<a href="#thisHost#">#thisHost#</a>
		</p>
	</cfoutput>
</cfsavecontent>		

<cfif qrydata.recordCount gt 0 or (qryData.recordCount eq 0 and settings.sendIfEmpty)>
	<cfmail from="#adminEmail#" 
			to="#recipients#"
			subject="BugLogHQ Digest"
			type="html">#tmpHTML#</cfmail>
	<cfoutput>Done. (email sent to #recipients#)</cfoutput>.
<cfelse>
	<cfoutput>Done. (email not sent)</cfoutput>.
</cfif>

