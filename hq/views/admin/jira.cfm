<cfset jiraConfig = request.requestState.jiraConfig>

<cfoutput>
	<h3>JIRA Integration:</h3>
	
	<div style="margin-left:30px;line-height:24px;">
		<cfif !allowConfigEditing><div style="color:##990000;line-height:18px;font-weight:bold;margin-bottom:10px;">#editingSettingsNotAllowedMsg#</div></cfif>
		
		<br />
		<div class="alert alert-info">
			<p>
			<b>IMPORTANT!</b><br>
			As of BugLogHQ 1.8.2 Jira integration requires the use of the REST endpoint. Atlassian has indicated that the SOAP implementation
			will be retired and only recommends using REST for external integrations. 
			</p>
		</div>
		
		<form name="jira" action="index.cfm" method="post">
			<input type="hidden" name="event" value="admin.doSaveJiraSettings">
			<table>
				<tr>
					<td>Enabled:</td>
					<td>
						<input type="radio" name="enabled" value="true" <cfif jiraConfig.enabled>checked</cfif> <cfif !allowConfigEditing>disabled</cfif>> Yes
						&nbsp;
						<input type="radio" name="enabled" value="false" <cfif not jiraConfig.enabled>checked</cfif> <cfif !allowConfigEditing>disabled</cfif>> No
					</td>
				</tr>
				<tr>
					<td>Endpoint:</td>
					<td><input type="text" name="endpoint" value="#jiraConfig.endpoint#" class="formField" <cfif !allowConfigEditing>disabled</cfif>></td>
				</tr>
				<tr>
					<td>Username:</td>
					<td><input type="text" name="username" value="#jiraConfig.username#" class="formField" <cfif !allowConfigEditing>disabled</cfif>></td>
				</tr>
				<tr>
					<td>Password:</td>
					<td><input type="password" name="password" value="#jiraConfig.password#" class="formField" <cfif !allowConfigEditing>disabled</cfif>></td>
				</tr>
			</table>
			<br />
			<input type="submit" name="btnSave" value="Apply Changes" <cfif !allowConfigEditing>disabled</cfif>>
		</form>
	</div>
	
</cfoutput>