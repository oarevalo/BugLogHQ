<cfparam name="request.requestState.purgeHistoryDays" default="30">

<cfset currentUser = request.requestState.currentUser>
<cfset qryUsers = request.requestState.qryUsers>
<cfset purgeHistoryDays = request.requestState.purgeHistoryDays>


<h2 style="margin-bottom:3px;">BugLog Settings & Management</h2>
<cfinclude template="../includes/menu.cfm">

<cfoutput>
	<h3>Change Password:</h3>
	<div style="margin-left:30px;line-height:24px;">
		<form name="frmChangePassword" action="index.cfm" method="post">
			<input type="hidden" name="event" value="ehAdmin.doChangePassword">
			
			Current Password: <input type="password" name="currentPassword" value="" class="formField" style="width:120px;"><br />
			New Password: <input type="password" name="newPassword" value="" class="formField" style="width:120px;"><br />
			Confirm New Password: <input type="password" name="newPassword2" value="" class="formField" style="width:120px;"><br /><br />
			
			<input type="submit" name="btn" value="Change Password">
		</form>
		<br />
	</div>

	<hr />

	<cfif currentUser.getIsAdmin()>
		<h3>User Management:</h3>
		<div style="margin-left:30px;line-height:24px;">
			<table width="300">
				<tr>
					<th width="15">&nbsp;</th>
					<th align="left">Username</th>
					<th>Administrator?</th>
					<th>&nbsp;</th>
				</tr>
				<cfloop query="qryUsers">
					<tr>
						<td width="15">#qryUsers.currentRow#.</td>
						<td><a href="index.cfm?event=ehAdmin.dspUser&userID=#qryUsers.userID#">#qryUsers.username#</a></td>
						<td align="center">#yesNoFormat(qryUsers.isAdmin)#</td>
						<td align="center"><a href="index.cfm?event=ehAdmin.dspDeleteUser&userID=#qryUsers.userID#">[Delete]</a></td>
					</tr>
				</cfloop>
			</table>
			<br /><a href="index.cfm?event=ehAdmin.dspUser">[ Create New User ]</a>
			<br /><br />
		</div>
				
		<hr />
		
		<h3>Purge History:</h3>
		<div style="margin-left:30px;line-height:24px;">
			<form name="frmPurge" action="index.cfm" method="post">
				<input type="hidden" name="event" value="ehAdmin.doPurgeHistory">
				
				Delete all bug reports older than
				<input type="text" name="purgeHistoryDays" value="#purgeHistoryDays#" class="formField" style="width:40px;">
				days.<br />
				<input type="checkbox" name="deleteOrphans"> Delete also orphan hosts, application and severity records.<br /><br />
				<input type="submit" name="btn" value="DELETE!">
			</form>
		</div>
		
		<br />
	</cfif>
	
</cfoutput>