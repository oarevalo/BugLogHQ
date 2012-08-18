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
							<cfset datePartValue = timeFormat(theDate,"mm")>
						</cfcase>
						<cfcase value="hour">
							<cfset theDate = dateAdd("h",i,rs.criteria.startDate)>
							entry_hour=#timeFormat(theDate,"H")#
							and entry_day = #day(theDate)#
							and entry_month = #month(theDate)#
							and entry_year = #year(theDate)#
							<cfset datePartValue = timeFormat(theDate,"h tt")>
						</cfcase>
						<cfcase value="day">
							<cfset theDate = dateAdd("d",i,rs.criteria.startDate)>
							entry_day = #day(theDate)#
							and entry_month = #month(theDate)#
							and entry_year = #year(theDate)#
							<cfset datePartValue = dateFormat(theDate,"mm/dd")>
						</cfcase>
						<cfcase value="month">
							<cfset theDate = dateAdd("m",i,rs.criteria.startDate)>
							entry_month = #month(theDate)#
							and entry_year = #year(theDate)#
							<cfif month(theDate) eq 1 or i eq 1>
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
