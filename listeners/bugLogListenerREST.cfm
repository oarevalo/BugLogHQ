<!--- Build a collection of all incoming URL & Form parameters --->
<cfset args = duplicate(form) />
<cfset structAppend(args, url) />

<!--- Make sure we have the required elements --->
<cfparam name="args.message" type="string" default="">
<cfparam name="args.applicationCode" type="string" default="Unknown">
<cfparam name="args.dateTime" type="date" default="#now()#">
<cfparam name="args.severityCode" type="string" default="ERROR">
<cfparam name="args.hostName" type="string" default="#cgi.REMOTE_ADDR#">
<cfparam name="args.exceptionMessage" default="">
<cfparam name="args.exceptionDetails" default="">
<cfparam name="args.CFID" type="string" default="">
<cfparam name="args.CFTOKEN" type="string" default="">
<cfparam name="args.userAgent" type="string" default="">
<cfparam name="args.templatePath" type="string" default="">
<cfparam name="args.HTMLReport" type="string" default="">
<cfparam name="args.APIKey" type="string" default="">

<!--- log how we got this report --->
<cfset args.source = ucase(cgi.HTTP_METHOD)>

<!--- See if we this is a named instance of buglog --->
<cfif structKeyExists(request,"bugLogInstance") and request.bugLogInstance neq "">
	<cfset instance = request.bugLogInstance>
<cfelse>
	<cfset instance = "">
</cfif>

<!--- log entry --->
<cfset listener = createObject("component","listener")
							.init( instance )
							.logEntry(
								argumentCollection = args
							) />

