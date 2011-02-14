<cfset rs = request.requestState>
<cfset rs.enabled = isBoolean(rs.enabled) and rs.enabled>

<cfset intervalOpts = [
				{label="Every Hour", value="1"},
				{label="Every 6 Hours", value="6"},
				{label="Every 12 Hours", value="12"},
				{label="Daily", value="24"},
				{label="Weekly", value="168"}
			]>

<cfoutput>
	<h3>Digest Settings:</h3>
	
	<div style="margin-left:30px;line-height:24px;">
		<cfif !allowConfigEditing><div style="color:##990000;line-height:18px;font-weight:bold;margin-bottom:10px;">#editingSettingsNotAllowedMsg#</div></cfif>

		<p>The BugLog Digest is a report sent via email containing a summary of BugLog activity for the last X hours. You can configure how
		often you want to receive the report.</p>

		<form name="settings" action="index.cfm" method="post">
			<input type="hidden" name="event" value="ehAdmin.doSaveDigestSettings">
			<table>
				<tr valign="top">
					<td>Enabled?:</td>
					<td>
						<input type="radio" name="enabled" value="true" <cfif rs.enabled>checked</cfif> <cfif !allowConfigEditing>disabled</cfif>> Yes
						&nbsp;
						<input type="radio" name="enabled" value="false" <cfif not rs.enabled>checked</cfif> <cfif !allowConfigEditing>disabled</cfif>> No
					</td>
				</tr>
				<tr valign="top">
					<td>Recipients:</td>
					<td>
						<input type="text" name="recipients" value="#rs.recipients#" class="formField" <cfif !allowConfigEditing>disabled</cfif>>
						<div class="formFieldTip">
							Enter one or more email addresses to receive the digest. If empty, it will be sent to the administrator's email address.
						</div>
					</td>
				</tr>
				<tr valign="top">
					<td>Interval:</td>
					<td>
						<select name="interval">
							<cfloop array="#intervalOpts#" index="opt">
								<option value="#opt.value#" <cfif rs.interval eq opt.value>selected</cfif>>#opt.label#</option>
							</cfloop>
						</select>
						<div class="formFieldTip">
							This indicates how often to receive the digest report. 
						</div>
					</td>
				</tr>
				<tr valign="top">
					<td>Start Time:</td>
					<td>
						<input type="text" name="startTime" value="#rs.startTime#" class="formField" <cfif !allowConfigEditing>disabled</cfif>>
						<div class="formFieldTip">
							The time at which the digest will be sent. Use the format HH:mm.
						</div>
					</td>
				</tr>
				<tr valign="top">
					<td>Send If Empty?:</td>
					<td>
						<input type="radio" name="sendIfEmpty" value="true" <cfif rs.sendIfEmpty>checked</cfif> <cfif !allowConfigEditing>disabled</cfif>> Yes
						&nbsp;
						<input type="radio" name="sendIfEmpty" value="false" <cfif not rs.sendIfEmpty>checked</cfif> <cfif !allowConfigEditing>disabled</cfif>> No
						<div class="formFieldTip">
							Do you want the digest report to be sent even if there is nothing to report?
						</div>
					</td>
				</tr>
			</table>
			<br />
			<input type="submit" name="btnSave" value="Apply Changes" <cfif !allowConfigEditing>disabled</cfif>>
		</form>
	</div>
	
</cfoutput>