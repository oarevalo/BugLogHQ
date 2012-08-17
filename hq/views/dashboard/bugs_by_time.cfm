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
	<cfset qryChart = queryNew("datePartValue,numCount")>
	<cfset theDate = rs.criteria.startDate>

	<cfloop from="1" to="#units#" index="i">
		<cfquery name="qryTimeline" dbtype="query">
			SELECT count(*) as numCount
				FROM qryData
				WHERE 
					<cfswitch expression="#datePartName#">
						<cfcase value="minute">
							entry_minute=#minute(theDate)#
							and entry_hour=#hour(theDate)#
							and entry_day = #day(theDate)#
							and entry_month = #month(theDate)#
							and entry_year = #year(theDate)#
							<cfset datePartValue = timeFormat(theDate,"mm")>
							<cfset theDate = dateAdd("n",1,theDate)>
						</cfcase>
						<cfcase value="hour">
							entry_hour=#hour(theDate)#
							and entry_day = #day(theDate)#
							and entry_month = #month(theDate)#
							and entry_year = #year(theDate)#
							<cfset datePartValue = timeFormat(theDate,"h tt")>
							<cfset theDate = dateAdd("h",1,theDate)>
						</cfcase>
						<cfcase value="day">
							entry_day = #day(theDate)#
							and entry_month = #month(theDate)#
							and entry_year = #year(theDate)#
							<cfset datePartValue = dateFormat(theDate,"mm/dd")>
							<cfset theDate = dateAdd("d",1,theDate)>
						</cfcase>
						<cfcase value="month">
							entry_month = #month(theDate)#
							and entry_year = #year(theDate)#
							<cfset datePartValue = dateFormat(theDate,"Mmm")>
							<cfset theDate = dateAdd("m",1,theDate)>
						</cfcase>
					</cfswitch>
		</cfquery>
		<cfset queryAddRow(qryChart)>
		<cfset querySetCell(qryChart,"datePartValue",datePartValue)>
		<cfset querySetCell(qryChart,"numCount",val(qryTimeline.numCount))>
	</cfloop>

	<cfoutput>
		<b>Timeline (#subtitle#)</b><br />
		<cfchart chartwidth="600" markersize="5" xaxistitle="#datePartName#"  yaxistitle="Count" sortXAxis="no" show3d="false">
			<cfchartseries query="qryChart" type="bar"
							paintStyle="light"
							markerStyle="circle"
							itemcolumn="DatePartValue" 
							valuecolumn="numcount">
		</cfchart>
	</cfoutput>
</cfif>
