<cfset slackConfig = request.requestState.slackConfig>

<cfoutput>
	<h3>Slack Integration:</h3>

	<div style="margin-left:30px;line-height:24px;">
		<cfif !allowConfigEditing><div style="color:##990000;line-height:18px;font-weight:bold;margin-bottom:10px;">#editingSettingsNotAllowedMsg#</div></cfif>


		<form name="slack" action="index.cfm" method="post">
			<input type="hidden" name="event" value="admin.doSaveSlackSettings">
			<table>
				<tr>
					<td>Enabled:</td>
					<td>
						<input type="radio" name="enabled" value="true" <cfif slackConfig.enabled>checked</cfif> <cfif !allowConfigEditing>disabled</cfif>> Yes
						&nbsp;
						<input type="radio" name="enabled" value="false" <cfif not slackConfig.enabled>checked</cfif> <cfif !allowConfigEditing>disabled</cfif>> No
					</td>
				</tr>
				<tr>
					<td>Endpoint:</td>
					<td><input type="text" name="endpoint" value="#slackConfig.endpoint#" class="formField" <cfif !allowConfigEditing>disabled</cfif>></td>
				</tr>
			</table>
			<br />
			<input type="submit" name="btnSave" value="Apply Changes" <cfif !allowConfigEditing>disabled</cfif>>
		</form>
	</div>

</cfoutput>