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

<cffunction name="showDate" returnType="string">
	<cfargument name="theDate" type="any" required="true">
	<cfargument name="mask" type="string" required="false" default="">
	<cfset var rtn = "">
	<cfif mask eq "">
		<cfif structKeyExists(request.requestState,"dateFormatMask") and request.requestState.dateFormatMask neq "">
			<cfset mask = request.requestState.dateFormatMask>
		<cfelse>
			<cfset mask = "dd/mm/yy">
		</cfif>
	</cfif>
	<cfset rtn = dateFormat(theDate,mask)>
	<cfreturn rtn>
</cffunction>

<cffunction name="showDateTime" returnType="string">
	<cfargument name="theDateTime" type="any" required="true">
	<cfargument name="dateMask" type="string" required="false" default="">
	<cfargument name="timeMask" type="string" required="false" default="">
	<cfset var rtn = "">
	<cfif structKeyExists(request.requestState,"timezoneInfo") and request.requestState.timezoneInfo neq "">
		<cfset theDateTime = request.requestState.dateConvertZ("local2zone",theDateTime,request.requestState.timezoneInfo)>
	</cfif>
	<cfset rtn = showDate(theDateTime,dateMask)>
	<cfif timeMask neq "">
		<cfset rtn = rtn & " " & lsTimeFormat(theDateTime,timeMask)>
	<cfelse>
		<cfset rtn = rtn & " " & lsTimeFormat(theDateTime)>
	</cfif>
	<cfreturn rtn>
</cffunction>


