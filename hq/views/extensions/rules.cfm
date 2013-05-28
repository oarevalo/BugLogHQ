<cfparam name="rs.aRules" default="#arrayNew(1)#">
<cfparam name="rs.aActiveRules" default="#arrayNew(1)#">
<cfset isAdmin = rs.currentUser.getIsAdmin()>
<cfset userID = rs.currentUser.getUserID()>
<cfset rulesShown = 0>
<cfset allowViewOtherUsersRules = false>

<cfset myRules = []>
<cfset otherRules = []>

<cfloop from="1" to="#arrayLen(rs.aActiveRules)#" index="i">
	<cfset item = rs.aActiveRules[i]>
	<cfif item.createdBy eq userID>
		<cfset arrayAppend(myRules, item)>
	<cfelseif isAdmin or val(item.createdBy) eq 0 or allowViewOtherUsersRules>
		<cfset arrayAppend(otherRules, item)>
	</cfif>
</cfloop>


<cfoutput>
<table class="table" style="width:100%;">
	<tbody>
	<tr><td colspan="2"><h3>Created By Me (#arrayLen(myRules)#)</h3></td></tr>
	<cfloop from="1" to="#arrayLen(myRules)#" index="i">
		<cfset item = myRules[i]>
		<cfset msg = item.instance.explain()>
		<cfset isOwner = (item.createdBy eq userID)>
		<tr>
			<td>
				<h4>
					#item.name#
					<cfif isAdmin or isOwner>
						&nbsp;&nbsp;
						<a href="index.cfm?event=extensions.rule&id=#item.id#&ruleName=#item.name#" style="font-size:10px;">Modify</a>
						&nbsp;
						<a href="##" onclick="confirmDeleteRule(#item.id#)" style="font-size:10px;">Remove</a>
						&nbsp;
						<cfif item.enabled>
							<a href="index.cfm?event=extensions.doDisableRule&id=#item.id#" style="font-size:10px;">Disable</a>
						<cfelse>
							<a href="index.cfm?event=extensions.doEnableRule&id=#item.id#" style="font-size:10px;">Enable</a>
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
	</cfloop>
	</tbody>
</table>
<br>	

<table class="table" style="width:100%;">
	<tbody>
	<tr><td colspan="2"><h3>Created By Others (#arrayLen(otherRules)#)</h3></td></tr>
	<cfloop from="1" to="#arrayLen(otherRules)#" index="i">
		<cfset item = otherRules[i]>
		<cfset msg = item.instance.explain()>
		<tr>
			<td>
				<h4>
					#item.name#
					<cfif isAdmin>
						&nbsp;&nbsp;
						<a href="index.cfm?event=extensions.rule&id=#item.id#&ruleName=#item.name#" style="font-size:10px;">Modify</a>
						&nbsp;
						<a href="##" onclick="confirmDeleteRule(#i#)" style="font-size:10px;">Remove</a>
						&nbsp;
						<cfif item.enabled>
							<a href="index.cfm?event=extensions.doDisableRule&id=#item.id#" style="font-size:10px;">Disable</a>
						<cfelse>
							<a href="index.cfm?event=extensions.doEnableRule&id=#item.id#" style="font-size:10px;">Enable</a>
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
	</cfloop>
	</tbody>
</table>

</cfoutput>
