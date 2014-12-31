<cfparam name="request.requestState.oEntry">
<cfparam name="request.requestState.jiraEnabled">

<cfset oEntry = request.requestState.oEntry>
<cfset oApp = oEntry.getApplication()>
<cfset oHost = oEntry.getHost()>
<cfset oSource = oEntry.getSource()>
<cfset oSeverity = oEntry.getSeverity()>

<cfset entryID = oEntry.getEntryID()>

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
						
<cfset rs.pageTitle = "Bug ###entryID# : <span style='color:##cc0000;'>#tmpMessage#</span>">


<cfsavecontent variable="tmpHead">
	<cfoutput>
		<script type="text/javascript">	
			$.ajaxSetup({ cache: false });		
			$(document).ready(function(){
				var d = $("##entry-stats");
				if(d.html()=="") d.html("loading stats...");
				d.load("index.cfm?event=entryStats&entryID=#oEntry.getID()#");
			});
		</script>
	</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#tmpHead#">


<cfoutput>

<!--- Page headers --->			
<cfinclude template="../includes/menu.cfm">

<p style="margin-top:10px;">
	<table width="100%" class="criteriaTable" cellpadding="0" cellspacing="0">
		<tr>
			<td style="border-right:1px solid ##ccc;">
				<img width="16" height="16" src="#rs.assetsPath#images/icons/email.png" align="absmiddle" />
				<a href="##" id="sendToEmailLink">Send to email</a>
				
				<cfif isBoolean(jiraEnabled) and jiraEnabled>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<img width="16" height="16" src="#rs.assetsPath#images/icons/jira.png" align="absmiddle" />
					<a href="index.cfm?event=jira.sendToJira&entryID=#entryID#">Send to JIRA</a>
				</cfif>

				&nbsp;&nbsp;&nbsp;&nbsp;
				<img width="16" height="16" src="#rs.assetsPath#images/icons/cross.png" align="absmiddle" />
				<a href="##" onclick="$('##dDeleteReport').slideToggle();">Delete</a>

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
				<td align="center" style="border-left:1px solid ##fff;border-right:1px solid ##ccc;width:100px;">
					<cfset tmpImgURL = getSeverityIconURL(tmpSeverity)>
					<cfset color_code_severity = getColorCodeBySeverity(tmpSeverity)>
					<span class="badge badge-#color_code_severity#">
						<img src="#tmpImgURL#" align="absmiddle" alt="#tmpSeverity#" title="#tmpSeverity#">
						#lcase(tmpSeverity)#
					</span>
				</td>
			</cfif>
			<td align="center" style="border-left:1px solid ##fff;border-right:1px solid ##ccc;width:200px;">
				<span class="label">Application:</span>
				<a href="index.cfm?event=main&applicationID=#oApp.getApplicationID()#">#oApp.getCode()#</a>
			</td>
			<td align="center" style="border-left:1px solid ##fff;width:200px;">
				<span class="label">Host:</span>
				<a href="index.cfm?event=main&hostID=#oHost.getHostID()#">#oHost.getHostname()#</a>
			</td>
		</tr>
	</table>
</p>

<!--- Delete bug report form --->
<div id="dDeleteReport" style="display:none;background-color:##f9f9f9;" class="criteriaTable">
	<div style="margin:10px;padding-top:10px;">
	<form name="frmDelete" action="index.cfm" method="post" style="padding:0px;margin:0px;">
		<input type="hidden" name="event" value="doDelete">
		<input type="hidden" name="entryID" value="#oEntry.getEntryID()#">
		<div style="margin-bottom:10px;">
			<span class="label label-important">DELETE BUG REPORT?</span>
		</div>
		<label><input type="radio" name="deleteScope" value="this" checked="true"> Delete this bug report only</label>
		<label><input type="radio" name="deleteScope" value="app-host"> Delete all reports with the same message on this application on this host</label>
		<label><input type="radio" name="deleteScope" value="app"> Delete all reports with the same message on this application on all hosts</label>
		<br>
		<input type="submit" value="Delete" name="btnSubmit">
	</form>
	</div>
</div>


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

<table id="entry-content">
<tr valign="top">
	<td id="entry-details">
		<table class="table table-condensed table-bordered table-striped">
			<tbody>
				<tr>
					<td style="width:115px;"><b>Date/Time:</b></td>
					<td>#showDateTime(oEntry.getCreatedOn())#</td>
				</tr>
				<tr>
					<td><b>User Agent:</b></td>
					<td>#oEntry.getUserAgent()#</td>
				</tr>
				<cfif oEntry.getTemplate_Path() neq "">
					<tr>
						<td><b>Template Path:</b></td>
						<td>#oEntry.getTemplate_Path()#</td>
					</tr>
				</cfif>
				<tr>
					<td><b>Exception Message:</b></td>
					<td class="breakable">#HtmlEditFormat(oEntry.getExceptionMessage())#</td>
				</tr>
				<tr>
					<td><b>Exception Detail:</b></td>
					<td id="exceptiondetail">#HtmlCodeFormat(oEntry.getExceptionDetails())#</td>
				</tr>
				<cfif oEntry.getCFID() neq "" or oEntry.getCFTOKEN() neq "">
					<tr>
						<td><b>CFID / CFTOKEN:</b></td>
						<td>#oEntry.getCFID()# &nbsp;&nbsp;/&nbsp;&nbsp; #oEntry.getCFTOKEN()#</td>
					</tr>
				</cfif>
			</tbody>
		</table>
	</td>
	<td style="width:5px;"></td>
	<td id="entry-stats"></td>
</tr>
</table>


<cfif htmlReport neq "">
	<h2>HTML Report</h2>
	#htmlReport#
</cfif>
</cfoutput>
<br>
<br>
<p>
	<a href="index.cfm"><strong>Return To Log</strong></a>
</p>	
