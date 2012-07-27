<cfset userID = request.requestState.userID>

<h2 style="margin-bottom:3px;">BugLog Settings & Management</h2>
<cfinclude template="../includes/menu.cfm">

<cfoutput>
	<form name="frmDelete" action="index.cfm" method="post">
		<input type="hidden" name="event" value="admin.doDeleteUser">
		<input type="hidden" name="userID" value="#userID#">
		<p>
			Are you sure you wish to delete the user?<br /><br />
			<input type="submit" name="btngo" value="Yes, Delete User">
			&nbsp;&nbsp;
			<a href="index.cfm?event=admin.main&panel=userManagement">No, do NOT delete user</a>
		</p> 
	</form>
</cfoutput>
