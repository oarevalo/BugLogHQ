<cfoutput>
	<h3>Change Password:</h3>
	<div style="margin-left:30px;line-height:24px;">
		<form name="frmChangePassword" action="index.cfm" method="post">
			<input type="hidden" name="event" value="ehGeneral.doUpdatePassword">
			<table>
				<tr>
					<td>New Password:</td>
					<td><input type="password" name="newPassword" value="" class="formField" style="width:120px;"></td>
				</tr>
				<tr>
					<td>Confirm New Password:</td>
					<td><input type="password" name="newPassword2" value="" class="formField" style="width:120px;"></td>
				</tr>
			</table>
			<br />
			<input type="submit" name="btn" value="Change Password">
		</form>
	</div>
</cfoutput>
