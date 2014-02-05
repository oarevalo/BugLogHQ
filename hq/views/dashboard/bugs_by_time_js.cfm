<cfscript>
	datePartName = "";
	switch(rs.criteria.numDays) {
		case "120": 
			units=6;
			datePartName = "month"; 
			subtitle = "Last 6 months";
			break;
		case "360": 
			units=12;
			datePartName = "month"; 
			subtitle = "Last 12 months";
			break;
		case "7": 
			units=7;
			datePartName = "day"; 
			subtitle = "Last 7 days";
			break;
		case "30": 
			units=30;
			datePartName = "day"; 
			subtitle = "Last 30 days";
			break;
		case "60": 
			units=60;
			datePartName = "day"; 
			subtitle = "Last 60 days";
			break;
		case "1": 
			units=24;
			datePartName = "hour"; 
			subtitle = "Last 24 hours";
			break;
		case "0.5": 
			units=12;
			datePartName = "hour"; 
			subtitle = "Last 12 hours";
			break;
		case "0.25": 
			units=6;
			datePartName = "hour"; 
			subtitle = "Last 6 hours";
			break;
		case "0.125": 
			units=3;
			datePartName = "hour"; 
			subtitle = "Last 3 hours";
			break;
		case "0.0417": 
			units=60;
			datePartName = "minute"; 
			subtitle = "Last hour";
			break;
	}
</cfscript>
	
<cfif datePartName neq "">
	<cfset qryChart = queryNew("datePartValue,numCount,checkDate")>
	<cfset theDate = rs.criteria.startDate>
	<cfloop from="0" to="#units#" index="i">
		<cfquery name="qryTimeline" dbtype="query">
			SELECT count(*) as numCount
				FROM qryData
				WHERE 
					<cfswitch expression="#datePartName#">
						<cfcase value="minute">
							<cfset theDate = dateAdd("n",i,rs.criteria.startDate)>
							entry_minute=#minute(theDate)#
							and entry_hour=#timeFormat(theDate,"H")#
							and entry_day = #day(theDate)#
							and entry_month = #month(theDate)#
							and entry_year = #year(theDate)#
							<cfset datePartValue = timeFormat(theDate,"h:mm tt")>
						</cfcase>
						<cfcase value="hour">
							<cfset theDate = dateAdd("h",i,rs.criteria.startDate)>
							entry_hour=#timeFormat(theDate,"H")#
							and entry_day = #day(theDate)#
							and entry_month = #month(theDate)#
							and entry_year = #year(theDate)#
							<cfif i eq 0 or hour(theDate) eq 0>
								<cfset datePartValue = dateFormat(theDate,"m/d") & " " & timeFormat(theDate,"h tt")>
							<cfelse>
								<cfset datePartValue = timeFormat(theDate,"h tt")>
							</cfif>
						</cfcase>
						<cfcase value="day">
							<cfset theDate = dateAdd("d",i,rs.criteria.startDate)>
							entry_day = #day(theDate)#
							and entry_month = #month(theDate)#
							and entry_year = #year(theDate)#
							<cfset datePartValue = dateFormat(theDate,"m/d")>
						</cfcase>
						<cfcase value="month">
							<cfset theDate = dateAdd("m",i,rs.criteria.startDate)>
							entry_month = #month(theDate)#
							and entry_year = #year(theDate)#
							<cfif month(theDate) eq 1 or i eq 0>
								<cfset datePartValue = dateFormat(theDate,"Mmm yy")>
							<cfelse>
								<cfset datePartValue = dateFormat(theDate,"Mmm")>
							</cfif>
						</cfcase>
					</cfswitch>
		</cfquery>
		<cfset queryAddRow(qryChart)>
		<cfset querySetCell(qryChart,"datePartValue",datePartValue)>
		<cfset querySetCell(qryChart,"numCount",val(qryTimeline.numCount))>
		<cfset querySetCell(qryChart,"checkDate",theDate)>
	</cfloop>

	<cfoutput>
		<style>
		##chart_container {
		        position: relative;
		        font-family: Arial, Helvetica, sans-serif;
		        margin-top:20px;
		}
		##chart {
		        position: relative;
		        margin-left:20px;
		}
		##y_axis {
		        position: absolute;
		        top: 0;
		        bottom: 0;
		        left:-25px;
		}
		##x_axis {
			position:relative;
			left:20px;
			height:40px;
			text-align:center;
		}
		.rickshaw_graph .detail .x_label { display: none }
		</style>
		
		<b>Timeline (#subtitle#)</b><br />
		<div id="chart_container">
			<div id="y_axis"></div>
		    <div id="chart"></div>
			<div id="x_axis"></div>
		</div>
		 
		<script> 
		var palette = new Rickshaw.Color.Palette( { scheme: 'colorwheel' } );
		var graph = new Rickshaw.Graph( {
		    element: document.querySelector("##chart"), 
			height:200,
			stroke: true,
			renderer: 'bar',
		    series: [{
		        color: palette.color(),
		        name: "Bug Reports",
		        data: [ 
					<cfloop query="qryChart">
						{x:#qryChart.currentrow#, y:#qryChart.numCount#},
					</cfloop>
					]
		    }]
		});
		var format = function(n) {
			var map = {
				<cfloop query="qryChart">
					#qryChart.currentrow#:'#qryChart.datePartValue#',
				</cfloop>
			};
			return map[n];
		}
		var y_axis = new Rickshaw.Graph.Axis.Y( {
		        graph: graph,
		        orientation: 'left',
		        tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
				ticks:6,
		        element: document.getElementById('y_axis')
		} );
		var x_axis = new Rickshaw.Graph.Axis.X( {
		        graph: graph,
		        orientation: 'bottom',
		        element: document.getElementById('x_axis'),
		        tickFormat:format,
		        ticks:6
		} );
		var hoverDetail = new Rickshaw.Graph.HoverDetail( {
			graph: graph,
			formatter: function(series, x, y) {
				content = format(x)+":  "+y;
				return content;
			}
		} );
		
		function drawChart() {
			var w = $("##chart").width();
			graph.configure({width:w});
			graph.render();
		}
		window.onload = drawChart();
		window.onresize = drawChart;
		</script> 	
	</cfoutput>
</cfif>

