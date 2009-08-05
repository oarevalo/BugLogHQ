<cfparam name="request.requestState.oEntry">
<cfparam name="request.requestState.jiraEnabled">

<cfset oEntry = request.requestState.oEntry>
<cfset oApp = oEntry.getApplication()>
<cfset oHost = oEntry.getHost()>
<cfset oSource = oEntry.getSource()>
<cfset oSeverity = oEntry.getSeverity()>

<cfset jiraEnabled = request.requestState.jiraEnabled>

<script type="text/javascript">
	function toggle(sec) {
		var d = document.getElementById(sec);
		d.style.display = (d.style.display=='block') ? 'none' : 'block';
	}
</script>

<cfset tmpSeverity = oSeverity.getCode()>
<cfset htmlReport = oEntry.getHTMLReport()>

<cfoutput>
<h2>Bug ###oEntry.getEntryID()# : <span style="color:##cc0000;">#oEntry.getMessage()#</span></h2>

<p>
	<table width="100%" class="criteriaTable" cellpadding="0" cellspacing="0">
		<tr>
			<td style="border-right:1px solid ##666;">
				<img alt="" width="16" height="16" src="images/icons/arrow_undo.png" align="absmiddle" />
				<a href="index.cfm">Return To Log</a>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<img width="16" height="16" src="images/icons/email.png" align="absmiddle" />
				<a href="##" onclick="toggle('dSendForm')">Send to email</a>
				
				<cfif isBoolean(jiraEnabled) and jiraEnabled>
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<img width="16" height="16" src="images/icons/jira.png" align="absmiddle" />
					<a href="index.cfm?event=ehJira.dspSendToJira&entryID=#entryID#">Send to JIRA</a>
				</cfif>
			</td>
			<td align="center" style="border-left:1px solid ##fff;border-right:1px solid ##666;" width="150">
				<cfset tmpImgName = "images/severity/default.png">
				<cfif tmpSeverity neq "">
					<cfif fileExists(expandPath("images/severity/#lcase(tmpSeverity)#.png"))>
						<cfset tmpImgName = "images/severity/#lcase(tmpSeverity)#.png">
					</cfif>
				</cfif>
				<img src="#tmpImgName#" 
						align="bottom"
						alt="#lcase(tmpSeverity)#" 
						title="#lcase(tmpSeverity)#">
				#tmpSeverity#		
			</td>
			<td align="center" style="border-left:1px solid ##fff;border-right:1px solid ##666;" width="150">
				<a href="index.cfm?event=ehGeneral.dspMain&applicationID=#oApp.getApplicationID()#">#oApp.getCode()#</a>
			</td>
			<td align="center" width="150" style="border-left:1px solid ##fff;">
				<a href="index.cfm?event=ehGeneral.dspMain&hostID=#oHost.getHostID()#">#oHost.getHostname()#</a>
			</td>
		</tr>
	</table>
</p>

<!--- Send to email form --->
<div id="dSendForm" style="display:none;background-color:##f9f9f9;" class="criteriaTable">
	<div style="margin:10px;padding-top:10px;">
	<form name="frmSend" action="index.cfm" method="post" style="padding:0px;margin:0px;">
		<input type="hidden" name="event" value="ehGeneral.doSend">
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
		<td>#oEntry.getExceptionMessage()#</td>
	</tr>
	<tr>
		<td><b>Exception Detail:</b></td>
		<td>#oEntry.getExceptionDetails()#</td>
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
