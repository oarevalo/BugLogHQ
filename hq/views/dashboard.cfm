<cfset qryData = rs.qryEntries>
<cfset dateMask = rs.dateFormatMask>

<cfsavecontent variable="tmpHead">
	<cfoutput>
		<script type="text/javascript">	
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
		<!---
		<link type="text/css" rel="stylesheet" href="#rs.assetsPath#/includes/rickshaw/rickshaw.min.css">
		<script src="#rs.assetsPath#/includes/d3/d3.min.js"></script> 
		<script src="#rs.assetsPath#/includes/d3/d3.layout.min.js"></script> 
		<script src="#rs.assetsPath#/includes/rickshaw/rickshaw.min.js"></script> 
		--->
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

	<p style="font-size:10px;margin-top:10px">
		* Content will refresh automatically every #rs.refreshSeconds# seconds.
	</p>
</cfoutput>

