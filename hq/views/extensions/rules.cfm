<cfparam name="rs.aRules" default="#arrayNew(1)#">
<cfparam name="rs.aActiveRules" default="#arrayNew(1)#">

<cfoutput>
<table class="table" style="width:100%;">
	<tbody>
	<cfloop from="1" to="#arrayLen(rs.aActiveRules)#" index="i">
		<cfset item = rs.aActiveRules[i]>
		<cfset ruleName = listLast(item.component,".")>
		<cfset lstProps = listSort(structKeyList(item.config),"textnocase")>
		<cfset msg = item.instance.explain()>
		
		<tr>
			<td>
				<h4>
					#ruleName#
					<cfif currentUser.getIsAdmin()>
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
		
			<!---
			<table cellpadding="0" cellspacing="0">
				<tr>
					<cfloop list="#lstProps#" index="fld">
						<td><b>#fld#</b></td>
					</cfloop>
				</tr>
				<tr>
					<cfloop list="#lstProps#" index="fld">
						<td>#item.config[fld]#</td>
					</cfloop>
				</tr>
			</table>
			--->
		</tr>
	</cfloop>
	</tbody>
</table>

<cfif arrayLen(rs.aActiveRules) eq 0>
	<em>There are no active rules</em>
</cfif>
</cfoutput>
