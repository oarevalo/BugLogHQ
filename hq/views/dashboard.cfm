<cfset qryData = rs.qryData>
<cfset dateMask = rs.dateFormatMask>

<cfsavecontent variable="tmpHead">
	<cfoutput>
		<cfif rs.refreshSeconds gt 0>
			<!-- refresh every X seconds -->
			<meta http-equiv="refresh" content="#rs.refreshSeconds#">
		</cfif>
		
		<script type="text/javascript">
			function doSearch() {
				var frm = document.frmSearch;
				frm.submit();
			}
		</script>	
	</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#tmpHead#">

<cfoutput>
	<!--- Page headers --->			
	<cfinclude template="../includes/menu.cfm">
	
	<!--- Search Criteria / Filters --->			
	<cfinclude template="../includes/filters.cfm">
	
	<!--- Dashboard --->
	<br />
	<table width="100%">
		<tr valign="top">
			<td width="50%">
				<cfinclude template="dashboard/bugs_by_msg.cfm">	
			</td>
			<td style="width:20px;">&nbsp;</td>
			<td align="center">
				<cfinclude template="dashboard/bugs_by_time.cfm">
				<br /><br />
				<cfinclude template="dashboard/bugs_by_app_severity.cfm">	
				<br /><br />
				<cfinclude template="dashboard/bugs_by_severity.cfm">
			</td>
		</tr>
	</table>

	<div style="font-size:10px;margin-top:10px">
		<div style="float:right;width:150px;text-align:right;">
			<a href="index.cfm?event=#rs.event#&resetCriteria=1">Reset Filters</a>
		</div>
				
		<cfif rs.refreshSeconds gt 0>
			<p>* Page will refresh automatically every #rs.refreshSeconds# seconds.</p>
		</cfif>	
	</div>
</cfoutput>


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
