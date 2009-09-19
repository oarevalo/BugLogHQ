<cfset qryUsers = request.requestState.qryUsers>

<cfoutput>
	<h3>User Management:</h3>
	<div style="margin-left:30px;">
		<table width="450" border="1" style="border-collapse:collapse;border-color:##ccc;" cellpadding="2">
			<tr>
				<th width="15">&nbsp;</th>
				<th align="left">Username</th>
				<th>Administrator?</th>
				<th>&nbsp;</th>
			</tr>
			<cfloop query="qryUsers">
				<tr>
					<td width="15" align="right">#qryUsers.currentRow#.</td>
					<td><a href="index.cfm?event=ehAdmin.dspUser&userID=#qryUsers.userID#">#qryUsers.username#</a></td>
					<td align="center" style="width:90px;">#yesNoFormat(qryUsers.isAdmin)#</td>
					<td align="center" style="width:110px;">
						<a href="index.cfm?event=ehAdmin.dspUser&userID=#qryUsers.userID#">[ Edit ]</a>
						&nbsp;
						<a href="index.cfm?event=ehAdmin.dspDeleteUser&userID=#qryUsers.userID#">[ Delete ]</a> 
					</td>
				</tr>
			</cfloop>
		</table>
		<br /><a href="index.cfm?event=ehAdmin.dspUser">[ Create New User ]</a>
		<br /><br />
	</div>
</cfoutput>