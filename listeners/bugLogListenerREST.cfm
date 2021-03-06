<!--- See if we this is a named instance of buglog --->
<cfif structKeyExists(request,"bugLogInstance") and request.bugLogInstance neq "">
    <cfset instance = request.bugLogInstance>
<cfelse>
    <cfset instance = "">
</cfif>

<!--- Create Listener Service --->
<cfset listener = createObject("component","listener").init( instance ) />

<!--- CORS: Enables Cross Domain Access in newer Browsers --->
<cfset requestHeaders = getHttpRequestData().headers />
<cfset cors = listener.getCorsSettings()/>
<cfif cors.enabled and structKeyExists( requestHeaders, "Origin" ) and cgi.request_method eq "OPTIONS">
    <cfheader name="Access-Control-Allow-Origin" value="#cors.allowOrigin#" />
    <cfheader name="Access-Control-Allow-Methods" value="#cors.allowMethods#" />
    <cfheader name="Access-Control-Allow-Headers" value="#cors.allowHeaders#" />
    <cfheader name="Access-Control-Max-Age" value="#cors.maxAge#" />
    <cfheader name="Access-Control-Allow-Credentials" value="#cors.allowCredentials#" />
    <!---
    Respond with these headers - the browser will cache these 'permissions'
    and immediately follow-up with the original request
    --->
    <cfcontent type="text/plain" reset="true" />
    <cfabort />
    <cfelseif listFindNoCase("GET,POST", cgi.request_method)>
    <!---
    Simple GET requests:
    When the request is GET or POST, and no custom headers are sent, then no preflight check is required.
    The browser accepts the response providing we allow it to with the Access-Control-Allow-Origin header
    We allow any host to do simple x-domain GET requests
    --->
    <cfheader name="Access-Control-Allow-Origin" value="#cors.allowOrigin#" />
</cfif>

<!--- CF Settings --->
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
<cfparam name="args.CFID" type="string" default="">
<cfparam name="args.CFTOKEN" type="string" default="">
<cfparam name="args.userAgent" type="string" default="">
<cfparam name="args.templatePath" type="string" default="">
<cfparam name="args.HTMLReport" type="string" default="">
<cfparam name="args.APIKey" type="string" default="">

<!--- log how we got this report --->
<cfset args.source = ucase(cgi.request_method)>

<!--- Log the bug --->
<cfinvoke component="#listener#" method="logEntry" argumentcollection="#args#">

<cfoutput>"OK"</cfoutput>