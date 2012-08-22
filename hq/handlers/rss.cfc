<cfcomponent extends="eventHandler">
	
	<cffunction name="rss" access="public">
		<cfscript>
			var applicationID = getValue("applicationID",0);
			var hostID = getValue("hostID",0);
			var maxEntries = 15;

			// get data
			var qryEntries = getService("app").searchEntries("", applicationID, hostID);

			// sort data to put newest entries first
			qryEntries = sortQuery(qryEntries, "createdOn", "DESC");

			// build rss feed
			var meta = structNew();
			meta.title = "BugLog";
			meta.link = "http://#cgi.HTTP_HOST##cgi.script_name#";
			meta.description = "Recently received bugs";
			
			var data = queryNew("title,body,link,subject,date");
			for(var i=1;i lte min(maxEntries, qryEntries.recordCount);i=i+1) {
				queryAddRow(data,1);
				querySetCell(data,"title","Bug ###qryEntries.entryID[i]#: " & qryEntries.message[i]);
				querySetCell(data,"body",composeMessage(qryEntries.createdOn[i], qryEntries.applicationCode[i], qryEntries.hostName[i], qryEntries.templatePath[i], qryEntries.severityCode[i], qryEntries.exceptionMessage[i], qryEntries.exceptionDetails[i] ));
				querySetCell(data,"link","http://#cgi.HTTP_HOST##cgi.script_name#?event=entry&entryID=" & qryEntries.entryID[i]);
				querySetCell(data,"subject","Subject");
				querySetCell(data,"date",now());
			}
			var rss = getService("rss");
			var rssXML = rss.generateRSS("rss1",data,meta);

			setValue("rssXML", rssXML);
			setView("feed");
			setLayout("xml");
		</cfscript>
	</cffunction>
	
	<cffunction name="composeMessage" access="private" returntype="string">
		<cfargument name="datetime" type="string" required="true">
		<cfargument name="applicationCode" type="string" required="true">
		<cfargument name="hostName" type="string" required="true">
		<cfargument name="templatePath" type="string" required="true">
		<cfargument name="severityCode" type="string" required="true">
		<cfargument name="exceptionMessage" type="string" required="true">
		<cfargument name="ExceptionDetails" type="string" required="true">

		<cfset var tmpHTML = "">

		<cfsavecontent variable="tmpHTML">
			<cfoutput>
			<table style="font-size:12px;">
				<tr>
					<td><b>Date/Time:</b></td>
					<td>#lsDateFormat(arguments.datetime)# - #lsTimeFormat(arguments.datetime)#</td>
				</tr>
				<tr>
					<td><b>Application:</b></td>
					<td>#arguments.applicationCode#</td>
				</tr>
				<tr>
					<td><b>Host:</b></td>
					<td>#arguments.hostname#</td>
				</tr>
				<tr>
					<td><b>Severity:</b></td>
					<td>#arguments.severityCode#</td>
				</tr>
				<tr>
					<td><b>Template Path:</b></td>
					<td>#arguments.templatePath#</td>
				</tr>
				<tr valign="top">
					<td><b>Exception Message:</b></td>
					<td>#arguments.exceptionMessage#</td>
				</tr>
				<tr valign="top">
					<td><b>Exception Detail:</b></td>
					<td>#arguments.ExceptionDetails#</td>
				</tr>
			</table>
			</cfoutput>
		</cfsavecontent>
		<cfreturn tmpHTML>
	</cffunction>

	
	<cffunction name="sortQuery" access="private" hint="Sorts a query by the given field">
		<cfargument name="qry" type="query" required="yes">
		<cfargument name="sortBy" type="string" required="yes">
		<cfargument name="sortOrder" type="string" required="no" default="ASC">
		
		<cfset var qryNew = QueryNew("")>
		
		<cfquery name="qryNew" dbtype="query">
			SELECT *
				FROM arguments.qry
				ORDER BY #Arguments.SortBy# #Arguments.SortOrder#
		</cfquery>		
		
		<cfreturn qryNew>
	</cffunction>	
	
</cfcomponent>