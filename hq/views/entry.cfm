<cfparam name="request.requestState.oEntry">
<cfparam name="request.requestState.jiraEnabled">

<cfset oEntry = request.requestState.oEntry>
<cfset oApp = oEntry.getApplication()>
<cfset oHost = oEntry.getHost()>
<cfset oSource = oEntry.getSource()>
<cfset oSeverity = oEntry.getSeverity()>

<cfset jiraEnabled = request.requestState.jiraEnabled>
<cfset ruleTypes = request.requestState.ruleTypes>

<cfset tmpCreateRuleURL = "?event=extensions.rule&application=#oApp.getCode()#&host=#oHost.getHostName()#&severity=#oSeverity.getCode()#">

<cfset tmpSeverity = oSeverity.getCode()>
<cfset htmlReport = oEntry.getHTMLReport()>
<cfif oEntry.getMessage() eq "">
	<cfset tmpMessage = "<em>No message</em>">
<cfelse>		
	<cfset tmpMessage = HtmlEditFormat(oEntry.getMessage())>
</cfif>

<cfoutput>
<h2>Bug ###oEntry.getEntryID()# : <span style="color:##cc0000;">#tmpMessage#</span></h2>

<p>
	<table width="100%" class="criteriaTable" cellpadding="0" cellspacing="0">
		<tr>
			<td style="border-right:1px solid ##666;">
				<img alt="" width="16" height="16" src="#rs.assetsPath#images/icons/arrow_undo.png" align="absmiddle" />
				<a href="index.cfm">Return To Log</a>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<img width="16" height="16" src="#rs.assetsPath#images/icons/email.png" align="absmiddle" />
				<a href="##" id="sendToEmailLink">Send to email</a>
				
				<cfif isBoolean(jiraEnabled) and jiraEnabled>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<img width="16" height="16" src="#rs.assetsPath#images/icons/jira.png" align="absmiddle" />
					<a href="index.cfm?event=jira.sendToJira&entryID=#entryID#">Send to JIRA</a>
				</cfif>

				&nbsp;&nbsp;&nbsp;&nbsp;
				<select name="ruleName" style="width:100px;" onchange="if(this.value!='') document.location='#tmpCreateRuleURL#&ruleName='+this.value">
					<option value="">Create rule...</option>
					<cfloop array="#ruleTypes#" index="rule">
						<cfset ruleName = listLast(rule.name,".")>
						<option value="#ruleName#">#ruleName#</option>
					</cfloop>
				</select>
			</td>
			<cfif tmpSeverity neq "">
				<td align="center" style="border-left:1px solid ##fff;border-right:1px solid ##666;width:100px;">
					<cfset tmpImgName = "images/severity/default.png">
					<cfif fileExists(expandPath("images/severity/#lcase(tmpSeverity)#.png"))>
						<cfset tmpImgName = "images/severity/#lcase(tmpSeverity)#.png">
					</cfif>
					<img src="#rs.assetsPath##tmpImgName#" 
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

<!--- Send to email form --->
<div id="dSendForm" style="display:none;background-color:##f9f9f9;" class="criteriaTable">
	<div style="margin:10px;padding-top:10px;">
	<form name="frmSend" action="index.cfm" method="post" style="padding:0px;margin:0px;">
		<input type="hidden" name="event" value="doSend">
		<input type="hidden" name="entryID" value="#oEntry.getEntryID()#">
		<strong>Recipient(s):</strong><br />
		<input type="text" name="to" value="" style="width:90%;">
		<br><br>
		<strong>Comments:</strong><br />
		<textarea name="comment" rows="4" style="width:90%;padding:2px;">Hi, can you take a look at this?</textarea>
		<br><br>
		<input type="submit" value="Send" name="btnSubmit">
	</form>
	</div>
</div>
<br />
	
<table style="font-size:12px;">
	<tr>
		<td><b>Date/Time:</b></td>
		<td>#lsDateFormat(oEntry.getDateTime())# - #lsTimeFormat(oEntry.getDateTime())#</td>
	</tr>
	<tr>
		<td><b>Severity:</b></td>
		<td>#tmpSeverity#</td>
	</tr>
	<tr>
		<td><b>User Agent:</b></td>
		<td>#oEntry.getUserAgent()#</td>
	</tr>
	<tr>
		<td><b>Template Path:</b></td>
		<td>#oEntry.getTemplate_Path()#</td>
	</tr>
	<tr>
		<td><b>Exception Message:</b></td>
		<td>#HtmlEditFormat(oEntry.getExceptionMessage())#</td>
	</tr>
	<tr>
		<td><b>Exception Detail:</b></td>
		<td id="exceptiondetail">#HtmlCodeFormat(oEntry.getExceptionDetails())#</td>
	</tr>
	<tr>
		<td><b>CFID / CFTOKEN:</b></td>
		<td>#oEntry.getCFID()# &nbsp;&nbsp;/&nbsp;&nbsp; #oEntry.getCFTOKEN()#</td>
	</tr>
	<tr>
		<td><b>Received via:</b></td>
		<td>#oSource.getName()#</td>
	</tr>
</table>
<br><br>


<h2>HTML Report</h2>
<cfif htmlReport neq "">
	#htmlReport#
<cfelse>
	<em>Empty</em>
</cfif>
</cfoutput>
<br>
<br>
<p>
	<a href="index.cfm"><strong>Return To Log</strong></a>
</p>	
