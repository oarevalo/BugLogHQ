<cfparam name="request.requestState.adminEmail" default="">
<cfparam name="request.requestState.autoStart" default="true">
<cfset adminEmail = request.requestState.adminEmail>
<cfset autoStart = request.requestState.autoStart>

<cfoutput>
	<h3>General Settings:</h3>
	
	<div style="margin-left:30px;line-height:24px;">
		<form name="settings" action="index.cfm" method="post">
			<input type="hidden" name="event" value="ehAdmin.doSaveGeneralSettings">
			<table>
				<tr valign="top">
					<td>Admin Email:</td>
					<td>
						<input type="text" name="adminEmail" value="#adminEmail#" class="formField">
						<div class="formFieldTip">
							This email address is used as the sender address for all emails sent by buglog
						</div>
					</td>
				</tr>
				<tr valign="top">
					<td>Enable Auto-Start:</td>
					<td>
						<input type="radio" name="autoStart" value="true" <cfif autoStart>checked</cfif>> Yes
						&nbsp;
						<input type="radio" name="autoStart" value="false" <cfif not autoStart>checked</cfif>> No
						<div class="formFieldTip">
							This setting controls whether the BugLog service will be automatically started when
							a bug report is received, even if the service is not active.<br />
							Disable this setting to completely shut down the service.
						</div>
					</td>
				</tr>
			</table>
			<br />
			<input type="submit" name="btnSave" value="Apply Changes">
		</form>
	</div>
	
</cfoutput>