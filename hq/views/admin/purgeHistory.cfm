<cfparam name="request.requestState.purgeHistoryDays" default="30">
<cfset purgeHistoryDays = request.requestState.purgeHistoryDays>

<cfoutput>
	<h3>Purge History:</h3>
	<div style="margin-left:30px;line-height:24px;">
		<form name="frmPurge" action="index.cfm" method="post">
			<input type="hidden" name="event" value="ehAdmin.doPurgeHistory">
			
			Delete all bug reports older than
			<input type="text" name="purgeHistoryDays" value="#purgeHistoryDays#" class="formField" style="width:40px;">
			days.<br />
			<input type="checkbox" name="deleteOrphans" value="true"> Delete also orphan hosts, application and severity records.<br /><br />
			<input type="submit" name="btn" value="DELETE!">
		</form>
	</div>
</cfoutput>