<cfsetting enablecfoutputonly="true">

<!--- This endpoint must respond to both JSON and regular HTTP requests --->
<cfset requestBody = toString( getHttpRequestData().content ) />
<cfif isJSON(requestBody)>
	<!--- json is what we got --->
	<cfset args = deserializeJSON(requestBody)>
	<cfset args.message = args.message>
<cfelse>
	<!--- This is a regular http request, so let's build a 
		collection of all incoming URL & Form parameters --->
	<cfset args = duplicate(form) />
	<cfset structAppend(args, url) />
</cfif>

<!--- Make sure we have the required elements --->
<cfparam name="args.message" type="string" default="">
<cfparam name="args.applicationCode" type="string" default="Unknown">
<cfparam name="args.dateTime" type="date" default="#now()#">
<cfparam name="args.severityCode" type="string" default="ERROR">
<cfparam name="args.hostName" type="string" default="#cgi.REMOTE_ADDR#">
<cfparam name="args.exceptionMessage" default="">
<cfparam name="args.exceptionDetails" default="">
<cfparam name="args.domain" default="">
<cfparam name="args.CFID" type="string" default="">
<cfparam name="args.CFTOKEN" type="string" default="">
<cfparam name="args.userAgent" type="string" default="">
<cfparam name="args.templatePath" type="string" default="">
<cfparam name="args.HTMLReport" type="string" default="">
<cfparam name="args.APIKey" type="string" default="">

<!--- log how we got this report --->
<cfset args.source = ucase(cgi.request_method)>

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


<cfoutput>"OK"</cfoutput>