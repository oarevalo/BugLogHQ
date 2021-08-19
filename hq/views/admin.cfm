<cfparam name="request.requestState.panel" default="">
<cfset panel = request.requestState.panel>
<cfset currentUser = request.requestState.currentUser>
<cfset isAdmin = currentUser.getIsAdmin()>
<cfset allowConfigEditing = request.requestState.allowConfigEditing>

<cfset editingSettingsNotAllowedMsg = "Editing of settings is currently not allowed. All configuration changes must be done directly in the config file.">

<cfset aPanels = [
				{ id = "general", label = "General Settings", display = isAdmin, href="admin/general.cfm" },
				{ id = "changePassword", label = "Change Password", display = true, href="admin/changePassword.cfm" },
				{ id = "purgeHistory", label = "Purge History", display = isAdmin, href="admin/purgeHistory.cfm" },
				{ id = "APISecurity", label = "API Security", display = isAdmin, href="admin/APISecurity.cfm" },
				{ id = "jira", label = "JIRA Integration", display = isAdmin, href="admin/jira.cfm" },
				{ id = "slack", label = "Slack Integration", display = isAdmin, href="admin/slack.cfm" },
				{ id = "digest", label = "Digest", display = isAdmin, href="admin/digest.cfm" },
				{ id = "listeners", label = "BugLog Listeners", display = true, href="admin/listeners.cfm" }
			]>
<cfset aDataPanels = [
				{ id = "userManagement", label = "Users", display = isAdmin, href="admin/userManagement.cfm" },
				{ id = "appManagement", label = "Applications", display = isAdmin, href="admin/appManagement.cfm" },
				{ id = "hostManagement", label = "Hosts", display = isAdmin, href="admin/hostManagement.cfm" },
				{ id = "severityManagement", label = "Severities", display = isAdmin, href="admin/severityManagement.cfm" }
			]>

<cfset currentPanelHREF = "">
			
<cfinclude template="../includes/menu.cfm">

<br />

<cfoutput>
	<table style="margin:0px;padding:0px;width:100%;line-height:24px;" cellpadding="0" cellspacing="0">
		<tr valign="top">
			<td style="width:120px;padding-top:10px;border-right:1px solid silver;">
				<b>Settings</b><br>
				<cfloop from="1" to="#arrayLen(aPanels)#" index="i">
					<cfif aPanels[i].display>
						<a href="index.cfm?event=admin.main&panel=#aPanels[i].id#"
							<cfif panel eq aPanels[i].id>style="font-weight:bold;"</cfif>
							><cfif panel eq aPanels[i].id>&raquo;</cfif> #aPanels[i].label#</a><br />
						<cfif panel eq aPanels[i].id>
							<cfset currentPanelHREF = aPanels[i].href>
						</cfif>
					<cfelse>
						<div style="color:##ccc;">#aPanels[i].label#</div>
					</cfif>
				</cfloop>
				<br>
				<b>Data Management</b><br>
				<cfloop from="1" to="#arrayLen(aDataPanels)#" index="i">
					<cfif aDataPanels[i].display>
						<a href="index.cfm?event=admin.main&panel=#aDataPanels[i].id#"
							<cfif panel eq aDataPanels[i].id>style="font-weight:bold;"</cfif>
							><cfif panel eq aDataPanels[i].id>&raquo;</cfif> #aDataPanels[i].label#</a><br />
						<cfif panel eq aDataPanels[i].id>
							<cfset currentPanelHREF = aDataPanels[i].href>
						</cfif>
					<cfelse>
						<div style="color:##ccc;">#aPanels[i].label#</div>
					</cfif>
				</cfloop>
			</td>
			<td style="width:25px;">&nbsp;</td>
			<td>
				<table width="90%">
					<cfif currentPanelHREF neq "">
						<cfinclude template="#currentPanelHREF#">
					<cfelse>
						<br /><em>Select a panel from the left menu</em>
					</cfif>
				</table>
			</td>
		</tr>
	</table>
	<br /><br />
</cfoutput>
