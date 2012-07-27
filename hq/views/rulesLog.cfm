<cfset rs = request.requestState>
<cfset lines = listToArray(rs.logcontents,chr(10))>

<cfset startIndex = arrayLen(lines)>
<cfset endIndex = max(arrayLen(lines)-100,2)>

<h2 style="margin-bottom:3px;">BugLog Rules > View Log</h2>
<cfinclude template="../includes/menu.cfm">

<cfoutput>
	<br />
	<form name="frm" method="get" action="index.cfm">
		<input type="hidden" name="event" value="extensions.rulesLog">
		<b>Logs Directory:</b>
		<input type="text" name="logsDir" value="#rs.logsDir#" size="100">
		<input type="submit" value="Reload">
	</form>
	<br />
	
	<!--- Data table --->
	<cfif arrayLen(lines) gt 0>
	<div style="font-size:10px;line-height:20px;margin-top:10px;font-weight:bold;">
		Showing last  #startIndex-endIndex# log entries
	</div>
	<table class="browseTable" style="width:100%">	
		<tr>
			<cfloop list="#lines[1]#" index="fld">
				<th>#replace(fld,"""","","All")#</th>
			</cfloop>
		</tr>
		<cfif startIndex gt 1>
			<cfloop from="#startIndex#" to="#endIndex#" index="i" step="-1">
				<cfset fields = listToArray(lines[i],",")>
				<tr <cfif i mod 2>class="altRow"</cfif>>
					<cfloop array="#fields#" index="fld">
						<td>#replace(fld,"""","","All")#</td>
					</cfloop>
				</tr>
			</cfloop>
		</cfif>
	</table>
	</cfif>
	
	<br /><br />
</cfoutput>
