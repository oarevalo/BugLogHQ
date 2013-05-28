<cfset oUser = request.requestState.oUser>
<cfset userID = val(oUser.getUserID())>
<cfset userName = oUser.getUsername()>
<cfset password = oUser.getPassword()>
<cfset isAdmin = oUser.getIsAdmin()>
<cfset email = oUser.getEmail()>
<cfset apiKey = oUser.getAPIKey()>

<cfset userAppIDs = []>
<cfloop array="#rs.userApps#" index="i">
	<cfset arrayAppend(userAppIds,i.getApplicationID())>
</cfloop>

<cfoutput>
	<cfinclude template="../includes/menu.cfm">
	
	<form name="frmDelete" action="index.cfm" method="post">
		<input type="hidden" name="event" value="admin.doSaveUser">
		<input type="hidden" name="userID" value="#userID#">
		<br />
		<table>
			<tr>
				<td style="width:100px;"><b>Username:</b></td>
				<td><input type="text" name="username" value="#username#" class="formField"></td>
			</tr>
			<cfif userID eq 0>
				<tr>
					<td><b>Password:</b></td>
					<td><input type="text" name="password" value="#password#" class="formField"></td>
				</tr>
			</cfif>
			<tr>
				<td><b>Email:</b></td>
				<td><input type="text" name="email" value="#email#" class="formField"></td>
			</tr>
			<tr>
				<td><b>Administrator?</b></td>
				<td>
					<input type="radio" name="isadmin" value="1" <cfif isAdmin>checked</cfif>>Yes 
					<input type="radio" name="isadmin" value="0" <cfif not isAdmin>checked</cfif>>No
					<div class="formFieldTip">
						Admin users can modify configuration and manage other users.
					</div>
				</td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr valign="top">
				<td><b>Allowed<br>Applications:</b></td>
				<td>
					<select name="applicationIDList" multiple="true" size="5" <cfif isAdmin>disabled</cfif>>
						<cfloop query="rs.apps">
							<option value="#rs.apps.applicationID#" <cfif arrayFind(userAppIds,rs.apps.applicationID)>selected</cfif>>#rs.apps.code#</option>
						</cfloop>
					</select>
					<div class="formFieldTip">
						Use this field to restrict the amount of applications a non-administrator user is able to view.
						Also, if the user submits bug reports using their own API Key, only bug reports for the allowed
						applications will be accepted.<br>
						Leave empty to allow access to all applications.
					</div>
				</td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr valign="top">
				<td><b>User API Key:</b></td>
				<td>
					<cfif len(APIKey)>
						<label><input type="checkbox" name="removeAPIKey" value="1"> Remove API Key</label>
						<input type="text" name="APIKey" value="#APIKey#" readonly="true" class="formField">
						<div class="formFieldTip">
							Remember to enable API Key requirement in the <a href="index.cfm?event=admin.main&panel=APISecurity">API Security</a> section
							for key checking to be enforced.
						</div>
					<cfelse>
						<label><input type="checkbox" name="assignAPIKey" value="1"> Generate API Key</label>
					</cfif>
				</td>
			</tr>
		</table>
		<br /><br />
		<input type="submit" name="btngo" value="Apply Changes">
		&nbsp;&nbsp;
		<a href="index.cfm?event=admin.main&panel=userManagement">Go Back</a>
	
	</form>
</cfoutput>
