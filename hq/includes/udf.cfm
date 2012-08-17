<!--- commonly used user-defined functions for use in views --->

<cffunction name="getSeverityIconURL" returntype="string">
	<cfargument name="severityCode" type="string" required="true">
	<cfset var tmpURL = "images/severity/#lcase(severityCode)#.png">
	<cfif not fileExists(expandPath(tmpURL))>
		<cfset tmpURL = "images/severity/default.png">
	<cfelse>
		<cfset tmpURL = "images/severity/#lcase(severityCode)#.png">
	</cfif>
	<cfreturn tmpURL>
</cffunction>

<cffunction name="getColorCodeByCount" returnType="string">
	<cfargument name="count" type="string" required="true">
	<cfset var code = "info">
	<cfif count gt 50>
		<cfset code = "important">
	<cfelseif count gt 25>
		<cfset code = "warning">
	</cfif>
	<cfreturn code />
</cffunction>

<cffunction name="getColorCodeBySeverity" returnType="string">
	<cfargument name="severityCode" type="string" required="true">
	<cfset var code = "">
	<cfswitch expression="#severityCode#">
		<cfcase value="fatal">
			<cfset code = "important">
		</cfcase>
		<cfcase value="error">
			<cfset code = "warning">
		</cfcase>
		<cfcase value="info">
			<cfset code = "info">
		</cfcase>
		<cfdefaultcase>
			<cfset code = "default">
		</cfdefaultcase>
	</cfswitch>		
	<cfreturn code />
</cffunction>