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
	<cfinclude template="dashboard/bugs_by_msg.cfm">	
	
	<cfif rs.refreshSeconds gt 0>
		<p style="margin-top:10px;font-size:10px;">* Page will refresh automatically every #rs.refreshSeconds# seconds.</p>
	</cfif>	
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
