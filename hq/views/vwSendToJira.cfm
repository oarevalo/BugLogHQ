<cfparam name="request.requestState.entryID">
<cfparam name="request.requestState.oEntry">
<cfparam name="request.requestState.qryProjects">
<cfparam name="request.requestState.qryIssueTypes">

<cfset entryID = request.requestState.entryID>
<cfset oEntry = request.requestState.oEntry>
<cfset qryProjects = request.requestState.qryProjects>
<cfset qryIssueTypes = request.requestState.qryIssueTypes>

<cfset oApp = oEntry.getApplication()>
<cfset oHost = oEntry.getHost()>
<cfset oSource = oEntry.getSource()>
<cfset oSeverity = oEntry.getSeverity()>
<cfset tmpSeverity = oSeverity.getCode()>
<cfset tmpMessage = oEntry.getMessage()>

<cfsavecontent variable="defaultDescription">
<cfoutput>
* *Date/Time:* #lsDateFormat(oEntry.getDateTime())# - #lsTimeFormat(oEntry.getDateTime())#
* *Application:* #oApp.getCode()#
* *Host:* #oHost.getHostname()#
* *Severity:* #tmpSeverity#

*User Agent:*
#oEntry.getUserAgent()#


*Template Path:*
#oEntry.getTemplate_Path()#


*Exception Message:*
#oEntry.getExceptionMessage()#


*Exception Detail:*
#oEntry.getExceptionDetails()#


*CFID / CFTOKEN:* 
#oEntry.getCFID()# &nbsp;&nbsp;/&nbsp;&nbsp; #oEntry.getCFTOKEN()#


* Issue submitted via BugLogHQ
</cfoutput>
</cfsavecontent>

<cfparam name="summary" default="Bug ###entryID#: #tmpMessage#">
<cfparam name="description" default="#defaultDescription#">

<cfoutput>
<h2>Bug ###oEntry.getEntryID()# : <span style="color:##cc0000;">#oEntry.getMessage()#</span></h2>

<p>
	<table width="100%" class="criteriaTable" cellpadding="0" cellspacing="0">
		<tr>
			<td style="border-right:1px solid ##666;">
				<img alt="" width="16" height="16" src="images/icons/arrow_undo.png" align="absmiddle" />
				<a href="index.cfm?event=ehGeneral.dspEntry&entryID=#entryID#">Return To Bug</a>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</td>
			<cfif tmpSeverity neq "">
				<td align="center" style="border-left:1px solid ##fff;border-right:1px solid ##666;" width="150">
					<img src="images/severity/#lcase(tmpSeverity)#.png" 
							align="bottom"
							alt="#lcase(tmpSeverity)#" 
							title="#lcase(tmpSeverity)#">
					#tmpSeverity#		
				</td>
			</cfif>
			<td align="center" style="border-left:1px solid ##fff;border-right:1px solid ##666;" width="150">
				<a href="index.cfm?event=ehGeneral.dspMain&applicationID=#oApp.getApplicationID()#">#oApp.getCode()#</a>
			</td>
			<td align="center" width="150" style="border-left:1px solid ##fff;">
				<a href="index.cfm?event=ehGeneral.dspMain&hostID=#oHost.getHostID()#">#oHost.getHostname()#</a>
			</td>
		</tr>
	</table>
</p>

<div style="background-color:##f9f9f9;" class="criteriaTable">
<div style="margin:10px;padding-top:10px;">
	<form name="frmSend" action="index.cfm" method="post" style="padding:0px;margin:0px;">
		<input type="hidden" name="event" value="ehJira.doSendToJira">
		<input type="hidden" name="entryID" value="#oEntry.getEntryID()#">
		<table width="100%">
			<tr>
				<td style="width:100px;"><b>Project:</b></td>
				<td>
					<select name="project" class="formField" style="padding:2px;">
						<cfloop query="qryProjects">
							<option value="#qryProjects.projectID#">#qryProjects.name# (#qryProjects.projectkey#)</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td style="width:100px;"><b>Issue Type:</b></td>
				<td>
					<select name="issueType" class="formField" style="padding:2px;">
						<cfloop query="qryIssueTypes">
							<option value="#qryIssueTypes.issueTypeID#">#qryIssueTypes.name#</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td><b>Summary:</b></td>
				<td><input type="text" name="summary" value="#summary#" class="formField" style="width:90%;padding:2px;"></td>
			</tr>
			<tr valign="top">
				<td><b>Description:</b></td>
				<td><textarea name="description" rows="25" style="width:90%;padding:2px;" class="formField">#description#</textarea></td>
			</tr>
		</table>
		<input type="submit" value="Send" name="btnSubmit">
	</form>
</div>
</div>


</cfoutput>