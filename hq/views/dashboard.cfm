<cfset qryData = rs.qryData>
<cfset dateMask = rs.dateFormatMask>

<cfsavecontent variable="tmpHead">
	<cfoutput>
		<script type="text/javascript">
			function doSearch() {
				var frm = document.frmSearch;
				frm.submit();
			}
			
			// miliseconds
			var interval,delay = #val(rs.refreshSeconds)*1000#;

			function startInterval(){ // start interval
				runIntervalAjax();
				interval = setInterval(function(){
            		runIntervalAjax();
				},delay);
			}
			
			function runIntervalAjax(){		
				$("##dashboardContent").load("index.cfm?event=dashboardContent");
			}

			$(document).ready(function(){
				startInterval()
			});
			
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
	<div id="dashboardContent">Loading...</div>

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
