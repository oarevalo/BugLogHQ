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
</cfoutput>
