<cfset jiraConfig = request.requestState.jiraConfig>

<cfoutput>
	<h3>JIRA Integration:</h3>
	
	<div style="margin-left:30px;line-height:24px;">
		<form name="jira" action="index.cfm" method="post">
			<input type="hidden" name="event" value="ehAdmin.doSaveJiraSettings">
			<table>
				<tr>
					<td>Enabled:</td>
					<td>
						<input type="radio" name="enabled" value="true" <cfif jiraConfig.enabled>checked</cfif>> Yes
						&nbsp;
						<input type="radio" name="enabled" value="false" <cfif not jiraConfig.enabled>checked</cfif>> No
					</td>
				</tr>
				<tr>
					<td>WSDL:</td>
					<td><input type="text" name="wsdl" value="#jiraConfig.wsdl#" class="formField"></td>
				</tr>
				<tr>
					<td>Username:</td>
					<td><input type="username" name="username" value="#jiraConfig.username#" class="formField"></td>
				</tr>
				<tr>
					<td>Password:</td>
					<td><input type="password" name="password" value="#jiraConfig.password#" class="formField"></td>
				</tr>
			</table>
			<br />
			<input type="submit" name="btnSave" value="Apply Changes">
		</form>
	</div>
	
</cfoutput>