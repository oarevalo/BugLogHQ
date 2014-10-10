<cfcomponent>

	<cffunction name="logEntry" access="remote" returntype="boolean">
		<cfargument name="dateTime" type="Date" required="true">
		<cfargument name="message" type="string" required="true">
		<cfargument name="applicationCode" type="string" required="true">
		<cfargument name="severityCode" type="string" required="true">
		<cfargument name="hostName" type="string" required="true">
		<cfargument name="exceptionMessage" required="false" default="">
		<cfargument name="exceptionDetails" required="false" default="">
		<cfargument name="CFID" type="string" required="false" default="">
		<cfargument name="CFTOKEN" type="string" required="false" default="">
		<cfargument name="userAgent" type="string" required="false" default="">
		<cfargument name="templatePath" type="string" required="false" default="">
		<cfargument name="HTMLReport" type="string" required="false" default="">
		<cfargument name="APIKey" type="string" required="false" default="">
		<cfargument name="domain" required="false" default="">
		
		<!--- log how we got this report --->
		<cfset arguments.source = "SOAP">

		<!--- See if we this is a named instance of buglog --->
		<cfset var instance = getInstanceName()>

		<cfset var listener = createObject("component","listener")
									.init( instance )
									.logEntry(
										argumentCollection = arguments
									) />
									
		<cfreturn true>
	</cffunction>

	<cffunction name="getInstanceName" access="private" returntype="string">
		<cfset var name = "">
		<cfif structKeyExists(request,"bugLogInstance") and request.bugLogInstance neq "">
			<cfset name = request.bugLogInstance>
		</cfif>
		<cfreturn name>
	</cffunction>
	
</cfcomponent>