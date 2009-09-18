<cfparam name="request.requestState.requireAPIKey" default="false">
<cfparam name="request.requestState.APIKey" default="">
<cfset requireAPIKey = request.requestState.requireAPIKey>
<cfset APIKey = request.requestState.APIKey>

<cfoutput>
	<h3>API Security:</h3>
	<div style="margin-left:30px;line-height:24px;">
		<form name="frmSecurity" action="index.cfm" method="post">
			<input type="hidden" name="event" value="ehAdmin.doSetAPISecSettings">
			
			<input type="checkbox" name="requireAPIKey" value="true" <cfif requireAPIKey>checked</cfif>> Require the use of an API key to submit bug reports.<br />

			API Key:
			<input type="text" name="APIKey" value="#APIKey#" class="formField">
			<input type="submit" name="generateNewKey" value="Generate New Key">
			<br /><br />

			<input type="submit" name="btn" value="Apply Changes">
		</form>
	</div>
</cfoutput>