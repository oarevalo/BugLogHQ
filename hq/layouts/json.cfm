<cfset rs = request.requestState>
<cfsetting enablecfoutputonly="true">
<cfcontent type="application/json" reset="true">
<cfif structKeyExists(rs,"error")>
	<cfparam name="rs.statusCode" default="500">
	<cfheader statuscode="#rs.statusCode#" statustext="error">
	<cfoutput>#serializeJson({error=rs.error,status=rs.statusCode})#</cfoutput>
<cfelse>
	<cfoutput>#serializeJson(rs.data)#</cfoutput>
</cfif>
