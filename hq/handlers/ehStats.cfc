<cfcomponent name="ehStats" extends="eventHandler">

	<cffunction name="dspMain">
		<cftry>
			<cfscript>
				criteria = structNew();
				if(structKeyExists(cookie,"criteria") and isJSON(cookie.criteria)) {
					criteria = deserializeJSON(cookie.criteria);
				}
				
				// make sure we have a complete criteria struct w/ default values
				if(not isStruct(criteria)) criteria = structNew();
				if(not structKeyExists(criteria,"numdays")) criteria.numDays = 30;
				if(not structKeyExists(criteria,"applicationID")) criteria.applicationID = 0;

				maxRows = getValue("maxRows", 3);
				numDays = getValue("numDays", criteria.numDays);
				datePart = getValue("datePart", "d");
				applicationID = getValue("applicationID", criteria.applicationID);
				
				startDate = dateAdd("d", val(numDays) * -1, now());
				datePartName = replaceList(datePart,  "y,m,d,h,n", "year,month,day,hour,minute");
				switch(datePart) {
					case "y": datePartName = "year"; break;
					case "m": datePartName = "month"; break;
					case "d": datePartName = "day"; break;
					case "h": datePartName = "hour"; break;
					case "n": datePartName = "minute"; break;
					default : datePartName = "day";
				}
				
				// search all entries
				qryEntries = getService("app").searchEntries(searchTerm = "", startDate = startDate);
				
				// get applications list
				qryApplications = getService("app").getApplications();
			</cfscript>
					
			
			<!--- count by application --->
			<cfquery name="qryAppSummary" dbtype="query" maxrows="#maxRows#">
				SELECT ApplicationCode, COUNT(*) as NumCount
					FROM qryEntries
					GROUP BY ApplicationCode
					ORDER BY NumCount DESC
			</cfquery>
			
			<!--- count by host --->
			<cfquery name="qryHostSummary" dbtype="query" maxrows="#maxRows#">
				SELECT hostName, COUNT(*) as NumCount
					FROM qryEntries
					GROUP BY hostName
					ORDER BY NumCount DESC
			</cfquery>
			
			<!--- count by message --->
			<cfquery name="qryMsgSummary" dbtype="query" maxrows="#maxRows#">
				SELECT message, COUNT(*) as NumCount
					FROM qryEntries
					GROUP BY message
					ORDER BY NumCount DESC
			</cfquery>
			
			
			<!--- count by timeline --->
			<cfquery name="qryTimeline" dbtype="query">
				SELECT entry_#datePartName# as DatePartValue, COUNT(*) as NumCount
					FROM qryEntries
					<cfif applicationID gt 0>
						WHERE applicationID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#applicationID#">
					</cfif>
					GROUP BY entry_#datePartName#
					ORDER BY entry_#datePartName#
			</cfquery>
			<!--- entry_year, entry_month, entry_day, entry_hour, entry_minute --->


			<cfscript>
				setValue("maxRows", maxRows);
				setValue("numDays", numDays);
				setValue("datePart", datePart);
				setValue("startDate", startDate);
				setValue("datePartName", datePartName);
				setValue("applicationID", applicationID);

				setValue("qryApplications", qryApplications);
				setValue("qryAppSummary", qryAppSummary);
				setValue("qryHostSummary", qryHostSummary);
				setValue("qryMsgSummary", qryMsgSummary);
				setValue("qryTimeline", qryTimeline);

				setView("vwStats");
			</cfscript>
			
			<cfcatch type="any">
				<cfset setMessage("error",cfcatch.message)>
				<cfset getService("bugTracker").notifyService(cfcatch.message, cfcatch)>
				<cfset setNextEvent("ehGeneral.dspMain")>
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>