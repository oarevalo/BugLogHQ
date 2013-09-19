<cfparam name="request.requestState.entryID">
<cfparam name="request.requestState.oEntry">
<cfparam name="request.requestState.projects">
<cfparam name="request.requestState.issueTypes">

<cfset entryID = request.requestState.entryID>
<cfset oEntry = request.requestState.oEntry>
<cfset projects = request.requestState.projects>
<cfset issueTypes = request.requestState.issueTypes>

<cfset oApp = oEntry.getApplication()>
<cfset oHost = oEntry.getHost()>
<cfset oSource = oEntry.getSource()>
<cfset oSeverity = oEntry.getSeverity()>
<cfset tmpSeverity = oSeverity.getCode()>
<cfset tmpMessage = oEntry.getMessage()>

<cfset dateTimeStr = showDateTime(oEntry.getCreatedOn())>

<cfsavecontent variable="defaultDescription">
<cfoutput>
*BugLog URL:* [#rs.bugLogEntryHREF#]
*Date/Time:* #dateTimeStr#
*Application:* #oApp.getCode()#
*Host:* #oHost.getHostname()#
*Severity:* #tmpSeverity#

*User Agent:*
#oEntry.getUserAgent()#


*Template Path:*
#oEntry.getTemplate_Path()#

<cfif oEntry.getExceptionMessage() neq "">
*Exception Message:*
#oEntry.getExceptionMessage()#
</cfif>

<cfif oEntry.getExceptionDetails() neq "">
*Exception Detail:*
#oEntry.getExceptionDetails()#
</cfif>

_Issue submitted via BugLogHQ_
</cfoutput>
</cfsavecontent>

<cfparam name="summary" default="Bug ###entryID#: #tmpMessage#">
<cfparam name="description" default="#defaultDescription#">
<cfparam name="project" default="">

<cfoutput>
<h2>Bug ###oEntry.getEntryID()# : <span style="color:##cc0000;">#oEntry.getMessage()#</span></h2>

<p>
	<table width="100%" class="criteriaTable" cellpadding="0" cellspacing="0">
		<tr>
			<td style="border-right:1px solid ##666;">
				<img alt="" width="16" height="16" src="#rs.assetsPath#images/icons/arrow_undo.png" align="absmiddle" />
				<a href="index.cfm?event=entry&entryID=#entryID#">Return To Bug</a>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</td>
			<cfif tmpSeverity neq "">
				<td align="center" style="border-left:1px solid ##fff;border-right:1px solid ##666;" width="150">
					<img src="#rs.assetsPath#images/severity/#lcase(tmpSeverity)#.png" 
							align="bottom"
							alt="#lcase(tmpSeverity)#" 
							title="#lcase(tmpSeverity)#">
					#tmpSeverity#		
				</td>
			</cfif>
			<td align="center" style="border-left:1px solid ##fff;border-right:1px solid ##666;" width="150">
				<a href="index.cfm?event=main&applicationID=#oApp.getApplicationID()#">#oApp.getCode()#</a>
			</td>
			<td align="center" width="150" style="border-left:1px solid ##fff;">
				<a href="index.cfm?event=main&hostID=#oHost.getHostID()#">#oHost.getHostname()#</a>
			</td>
		</tr>
	</table>
</p>

<div style="background-color:##f9f9f9;" class="criteriaTable">
<div style="margin:10px;padding-top:10px;">
	<form name="frmSend" action="index.cfm" method="post" style="padding:0px;margin:0px;">
		<input type="hidden" name="event" value="jira.doSendToJira">
		<input type="hidden" name="entryID" value="#oEntry.getEntryID()#">
		<table width="100%">
			<tr>
				<td style="width:100px;"><b>Project:</b></td>
				<td>
					<select name="project" id="project" class="formField" style="padding:2px;">
						<option value="">-- Select Project --</option>
						<cfloop array="#projects#" index="item">
							<option value="#item.key#" <cfif project eq item.key>selected</cfif>>#item.name# (#item.key#)</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td style="width:100px;"><b>Issue Type:</b></td>
				<td>
					<cfif arrayLen(issueTypes) gt 0>
						<select name="issueType" id="issueType" class="formField" style="padding:2px;">
						</select>
					</cfif>
				</td>
			</tr>
			<tr>
				<td><b>Summary:</b></td>
				<td><input type="text" name="summary" value="#summary#" class="formField" style="width:90%;padding:2px;"></td>
			</tr>
			<tr valign="top">
				<td><b>Description:</b></td>
				<td>
					<textarea name="description" rows="25" style="width:90%;padding:2px;" class="formField">#description#</textarea>
					<br />
					<a href="http://jira.atlassian.com/secure/WikiRendererHelpAction.jspa?section=all" target="_blank">Click Here to view the JIRA wiki syntax guide</a>
				</td>
			</tr>
		</table>
		<input type="submit" value="Send" name="btnSubmit">
	</form>
</div>
</div>
</cfoutput>

<script type="text/javascript">
$(document).ready(function(){
	$('#project').change(function(){
		var $this = $(this);
		var $target = $('select#issueType');
		$.getJSON('index.cfm?event=jira.getIssueTypes&projectKey='+$this.val(), function(data){
		    var html = '';
		    $target.empty();
		    for (var i = 0; i< data.length; i++) {
		    	if(!data[i].subtask)
			        html += '<option value="' + data[i].id + '">' + data[i].name + '</option>';
		    }
		    $target.append(html);
		});
	});
})	
</script>

