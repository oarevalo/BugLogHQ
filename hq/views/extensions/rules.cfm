<cfparam name="rs.aRules" default="#arrayNew(1)#">
<cfparam name="rs.aActiveRules" default="#arrayNew(1)#">
<cfset isAdmin = rs.currentUser.getIsAdmin()>
<cfset userID = rs.currentUser.getUserID()>
<cfset rulesShown = 0>

<cfoutput>
<table class="table" style="width:100%;">
	<tbody>
	<cfloop from="1" to="#arrayLen(rs.aActiveRules)#" index="i">
		<cfset item = rs.aActiveRules[i]>
		<cfset ruleName = listLast(item.component,".")>
		<cfset lstProps = listSort(structKeyList(item.config),"textnocase")>
		<cfset msg = item.instance.explain()>
		<cfset show = isAdmin or (item.createdBy eq userID) or (val(item.createdBy) eq 0)>
		
		<cfif show>
		<tr>
			<td>
				<h4>
					#ruleName#
					<cfif isAdmin>
						&nbsp;&nbsp;
						<a href="index.cfm?event=extensions.rule&index=#i#&ruleName=#ruleName#" style="font-size:10px;">Modify</a>
						&nbsp;
						<a href="##" onclick="confirmDeleteRule(#i#)" style="font-size:10px;">Remove</a>
						&nbsp;
						<cfif item.enabled>
							<a href="index.cfm?event=extensions.doDisableRule&index=#i#&ruleName=#ruleName#" style="font-size:10px;">Disable</a>
						<cfelse>
							<a href="index.cfm?event=extensions.doEnableRule&index=#i#&ruleName=#ruleName#" style="font-size:10px;">Enable</a>
						</cfif>
					</cfif>
				</h4>
				<cfif msg neq "">
					<p>
						<em>#item.instance.explain()#</em>
					</p>
				</cfif>
				
				<blockquote>
					#item.description#
				</blockquote>
			
			</td>
			<td style="width:120px;font-weight:bold;">
				<cfif not item.enabled>
					<span class="label label-important">Disabled</span>
				<cfelse>
					<span class="label label-success">Enabled</span>
				</cfif>
			</td>
		</tr>
		<cfset rulesShown++>
		</cfif>
	</cfloop>
	</tbody>
</table>

<cfif rulesShown eq 0>
	<em>There are no rules to display</em>
</cfif>
</cfoutput>
