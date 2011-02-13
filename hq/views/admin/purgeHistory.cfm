<cfparam name="request.requestState.purgeHistoryDays" default="30">
<cfparam name="request.requestState.enabled" default="false">
<cfset purgeHistoryDays = request.requestState.purgeHistoryDays>
<cfset enabled = request.requestState.enabled>

<cfoutput>
	<h3>Purge History:</h3>
	<div style="margin-left:30px;line-height:24px;">
		<form name="frmPurge" action="index.cfm" method="post">
			<input type="hidden" name="event" value="ehAdmin.doPurgeHistory">
			
			Delete all bug reports older than
			<input type="text" name="purgeHistoryDays" value="#purgeHistoryDays#" class="formField" style="width:40px;">
			days.<br />
			<input type="checkbox" name="enabled" value="true" <cfif isBoolean(enabled) and enabled>checked</cfif>> 
			Purge history automatically every day?<br />
			<input type="checkbox" name="runnow" value="true"> 
			<span style="color:##990000">DELETE HISTORY NOW!</span><br /><br />
			<input type="submit" name="btn" value="Apply Changes">
		</form>
	</div>
</cfoutput>