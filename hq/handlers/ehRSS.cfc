<cfcomponent name="ehGeneral" extends="eventHandler">
	
	<cffunction name="dspRSS" access="public">
		<cfscript>
			applicationID = getValue("applicationID",0);
			hostID = getValue("hostID",0);
			maxEntries = 15;

			qryEntries = getService("app").searchEntries("", applicationID, hostID);

			meta = structNew();
			meta.title = "BugLog";
			meta.link = "http://#cgi.HTTP_HOST##cgi.script_name#";
			meta.description = "Recently received bugs";
			
			data = queryNew("title,body,link,subject,date");
			for(i=1;i lte min(maxEntries, qryEntries.recordCount);i=i+1) {
				queryAddRow(data,1);
				querySetCell(data,"title","Bug ###qryEntries.entryID[i]#: " & qryEntries.message[i]);
				querySetCell(data,"body",composeMessage(qryEntries.mydateTime[i], qryEntries.applicationCode[i], qryEntries.hostName[i], qryEntries.templatePath[i], qryEntries.exceptionMessage[i], qryEntries.exceptionDetails[i] ));
				querySetCell(data,"link","http://#cgi.HTTP_HOST##cgi.script_name#?event=ehGeneral.dspEntry&entryID=" & qryEntries.entryID[i]);
				querySetCell(data,"subject","Subject");
				querySetCell(data,"date",now());
			}
			rss = createObject("component","bugLog.hq.components.rss");
			rssXML = rss.generateRSS("rss1",data,meta);

			setValue("rssXML", rssXML);
			setView("vwFeed");
			setLayout("Layout.XML");
		</cfscript>
	</cffunction>
	
	<cffunction name="composeMessage" access="private" returntype="string">
		<cfargument name="datetime" type="string" required="true">
		<cfargument name="applicationCode" type="string" required="true">
		<cfargument name="hostName" type="string" required="true">
		<cfargument name="templatePath" type="string" required="true">
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
</cfcomponent>