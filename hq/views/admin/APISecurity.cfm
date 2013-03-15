<cfparam name="request.requestState.requireAPIKey" default="false">
<cfparam name="request.requestState.APIKey" default="">
<cfset requireAPIKey = request.requestState.requireAPIKey>
<cfset APIKey = request.requestState.APIKey>

<cfoutput>
	<h3>API Security:</h3>
	<div style="margin-left:30px;line-height:30px;">
		<cfif !allowConfigEditing><div style="color:##990000;line-height:18px;font-weight:bold;margin-bottom:10px;">#editingSettingsNotAllowedMsg#</div></cfif>
		<form name="frmSecurity" action="index.cfm" method="post">
			<input type="hidden" name="event" value="admin.doSetAPISecSettings">
			
			<label>
			<input type="checkbox" name="requireAPIKey" value="true" 
					<cfif requireAPIKey>checked</cfif>
					 <cfif !allowConfigEditing>disabled</cfif>> Require the use of an API key to submit bug reports.<br />
			</label>

			Master API Key:
			<input type="text" name="APIKey" value="#APIKey#" class="formField"  <cfif !allowConfigEditing>disabled</cfif>>
			<input type="submit" name="generateNewKey" value="Generate New Key" 
					onclick="return(confirm('WARNING:\n\nExisting clients will not be able to submit bug reports until updated with the new key'))"
					 <cfif !allowConfigEditing>disabled</cfif>>
			<br /><br />
			<span class="label label-info">Tip:</span>
			You can also assign API keys to individual users in the 
			<a href="index.cfm?event=admin.main&panel=userManagement">User Management</a> section without sharing the master API Key. 
			<br /><br />

			<input type="submit" name="btn" value="Apply Changes" <cfif !allowConfigEditing>disabled</cfif>>
		</form>
	</div>
</cfoutput>