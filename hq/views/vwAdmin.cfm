<cfparam name="request.requestState.panel" default="">
<cfset panel = request.requestState.panel>
<cfset currentUser = request.requestState.currentUser>
<cfset isAdmin = currentUser.getIsAdmin()>

<cfset aPanels = [
				{ id = "general", label = "General Settings", display = isAdmin },
				{ id = "changePassword", label = "Change Password", display = true },
				{ id = "userManagement", label = "User Management", display = isAdmin },
				{ id = "purgeHistory", label = "Purge History", display = isAdmin },
				{ id = "APISecurity", label = "API Security", display = isAdmin },
				{ id = "jira", label = "JIRA Integration", display = isAdmin },
				{ id = "listeners", label = "BugLog Listeners", display = true },
			]>
<cfset lstPanelIDs = "">
			
<h2 style="margin-bottom:3px;">BugLog Settings & Management</h2>
<cfinclude template="../includes/menu.cfm">

<br />

<cfoutput>
	<table style="margin:0px;padding:0px;width:100%;line-height:24px;" cellpadding="0" cellspacing="0">
		<tr valign="top">
			<td style="width:120px;padding-top:10px;border-right:1px solid silver;">
				<cfloop from="1" to="#arrayLen(aPanels)#" index="i">
					<cfif aPanels[i].display>
						<a href="index.cfm?event=ehAdmin.dspMain&panel=#aPanels[i].id#"
							<cfif panel eq aPanels[i].id>style="font-weight:bold;"</cfif>
							><cfif panel eq aPanels[i].id>&raquo;</cfif> #aPanels[i].label#</a><br />
						<cfset lstPanelIDs = listAppend(lstPanelIDs,aPanels[i].id)>
					<cfelse>
						<div style="color:##ccc;">#aPanels[i].label#</div>
					</cfif>
				</cfloop>
			</td>
			<td style="width:25px;">&nbsp;</td>
			<td>
				<table width="90%">
					<cfif listFind(lstPanelIDs,panel)>
						<cfinclude template="admin/#panel#.cfm">
					<cfelse>
						<br /><em>Select a panel from the left menu</em>
					</cfif>
				</table>
			</td>
		</tr>
	</table>
	<br /><br />
</cfoutput>
