<cfparam name="request.requestState.maxRows" default="3">
<cfparam name="request.requestState.numDays" default="30">
<cfparam name="request.requestState.datePart" default="d">
<cfparam name="request.requestState.applicationID" default="0">
<cfparam name="request.requestState.datePartName" default="">
<cfparam name="request.requestState.startDate" default="">

<cfparam name="request.requestState.qryApplications" default="#queryNew('')#">
<cfparam name="request.requestState.qryAppSummary" default="#queryNew('')#">
<cfparam name="request.requestState.qryHostSummary" default="#queryNew('')#">
<cfparam name="request.requestState.qryMsgSummary" default="#queryNew('')#">
<cfparam name="request.requestState.qryTimeline" default="#queryNew('')#">

<cfset maxRows = request.requestState.maxRows>
<cfset numDays = request.requestState.numDays>
<cfset datePart = request.requestState.datePart>
<cfset applicationID = request.requestState.applicationID>
<cfset datePartName = request.requestState.datePartName>
<cfset startDate = request.requestState.startDate>
<cfset qryApplications = request.requestState.qryApplications>
<cfset qryAppSummary = request.requestState.qryAppSummary>
<cfset qryHostSummary = request.requestState.qryHostSummary>
<cfset qryMsgSummary = request.requestState.qryMsgSummary>
<cfset qryTimeline = request.requestState.qryTimeline>

<cfset tmpAppName = "All">


<h2 style="margin-bottom:3px;">BugLog Stats</h2>
<cfinclude template="../includes/menu.cfm">
<br>

<cfoutput>
	<form name="frmSearch" action="index.cfm" method="post">
		<input type="hidden" name="event" value="ehStats.dspMain">
		<table  width="100%" class="criteriaTable" cellpadding="0" cellspacing="0">
			<tr align="center">
				<td>
					Show Top: &nbsp;&nbsp;
					<select name="maxRows" style="width:50px;" onchange="this.form.submit()">
						<option value="3" <cfif maxRows eq 3>selected</cfif>>3</option>
						<option value="5" <cfif maxRows eq 5>selected</cfif>>5</option>
						<option value="10" <cfif maxRows eq 10>selected</cfif>>10</option>
						<option value="15" <cfif maxRows eq 15>selected</cfif>>15</option>
					</select>
				</td>
				<td style="border-right:1px solid ##666;">
					Show for last: &nbsp;&nbsp;
					<select name="numDays" style="width:100px;" onchange="this.form.submit()">
						<option value="1" <cfif numDays eq 1>selected</cfif>>24 hours</option>
						<option value="7" <cfif numDays eq 7>selected</cfif>>7 days</option>
						<option value="30" <cfif numDays eq 30>selected</cfif>>30 days</option>
						<option value="60" <cfif numDays eq 60>selected</cfif>>60 days</option>
						<option value="120" <cfif numDays eq 120>selected</cfif>>120 days</option>
						<option value="360" <cfif numDays eq 360>selected</cfif>>360 days</option>
					</select>
				</td>
				<td align="right" style="border-left:1px solid ##fff;"><b>Timeline:</b></td>
				<td>
					Breakdown by: &nbsp;&nbsp;
					<select name="datePart" style="width:100px;" onchange="this.form.submit()">
						<option value="y" <cfif datePart eq "y">selected</cfif>>Years</option>
						<option value="m" <cfif datePart eq "m">selected</cfif>>Months</option>
						<option value="d" <cfif datePart eq "d">selected</cfif>>Days</option>
						<option value="h" <cfif datePart eq "h">selected</cfif>>Hours</option>
					</select>
				</td>
				<td>
					Application: &nbsp;&nbsp;
					<select name="applicationID" style="width:150px;" onchange="this.form.submit()">
						<option value="0">All</option>
						<cfset tmp = applicationID>
						<cfloop query="qryApplications">
							<cfif qryApplications.applicationID eq tmp>
								<cfset tmpAppName = qryApplications.code>
								<option value="#qryApplications.applicationID#" selected>#qryApplications.code#</option>
							<cfelse>
								<option value="#qryApplications.applicationID#">#qryApplications.code#</option>
							</cfif>
						</cfloop>
					</select>
				</td>
			</tr>
		</table>
	</form>
</cfoutput>
<br>	

<p align="center">
	<cfchart chartwidth="290" title="Top #maxRows# Applications" show3d="yes" xaxistitle="Application" url="index.cfm?event=ehGeneral.dspMain&applicationID=$ITEMLABEL$">
		<cfchartseries query="qryAppSummary" type="bar" itemcolumn="applicationCode" valuecolumn="numcount" >
	</cfchart>
	<cfchart chartwidth="290" title="Top #maxRows# HostNames" show3d="yes" xaxistitle="Host" url="index.cfm?event=ehGeneral.dspMain&hostID=$ITEMLABEL$">
		<cfchartseries query="qryHostSummary" type="bar" itemcolumn="hostname" valuecolumn="numcount" paintstyle="raise">
	</cfchart>
	<cfchart chartwidth="290" title="Top #maxRows# Messages" show3d="yes" xaxistitle="Message" url="index.cfm?event=ehGeneral.dspMain&searchTerm=$ITEMLABEL$">
		<cfchartseries query="qryMsgSummary" type="bar" itemcolumn="message" valuecolumn="numcount" paintstyle="raise">
	</cfchart>
	<br>

	<cfchart chartwidth="700" markersize="5" xaxistitle="#datePartName#"  yaxistitle="Bug count" title="Timeline [#tmpAppName#]">
		<cfchartseries query="qryTimeline" type="bar" markerstyle="snow" itemcolumn="DatePartValue" valuecolumn="numcount" paintstyle="raise">
	</cfchart>
</p>

