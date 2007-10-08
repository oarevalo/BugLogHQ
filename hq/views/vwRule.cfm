<cfparam name="request.requestState.stInfo" default="#structNew()#">
<cfparam name="request.requestState.stRule" default="#structNew()#">
<cfparam name="request.requestState.aActiveRule" default="#structNew()#">

<cfset rs = request.requestState>

<cfset ruleName = listLast(rs.stRule.name,".")>

<cfoutput>
	<h2 style="margin-bottom:3px;">BugLog Add/Edit Rule</h2>
	<cfinclude template="../includes/menu.cfm">

	<h3>#ruleName#</h3>
	<em>#rs.stRule.description#</em><br /><br /><br />

	<form name="frm" method="post" action="index.cfm">
		<input type="hidden" name="event" value="ehExtensions.doSaveRule">
		<input type="hidden" name="ruleName" value="#ruleName#">
		<input type="hidden" name="index" value="#rs.index#">
	
		<table>
			<cfset aProps = rs.stRule.properties>
			<cfloop from="1" to="#arrayLen(aProps)#" index="i">
				<cfif isDefined("rs.aActiveRule.config.#aProps[i].name#")>
					<cfset tmpValue = rs.aActiveRule.config[aProps[i].name]>
				<cfelse>
					<cfset tmpValue = "">
				</cfif>
				<tr valign="top">
					<td><b>#aProps[i].name#:</b></td>
					<td>
						<input type="text" name="#aProps[i].name#" value="#tmpValue#" class="formField">			
						<cfif structKeyExists(aProps[i],"hint")>
							<div style="margin-top:3px;font-size:11px;">
								<em>#aProps[i].hint#</em>
							</div>
						</cfif>
						<br><br>
					</td>
				</tr>
			</cfloop>
		</table>
		<br />
		<input type="submit" value="Save" name="btnSave">&nbsp;&nbsp;
		<input type="button" value="Cancel" name="btnCancel" onclick="document.location='index.cfm?event=ehExtensions.dspMain'">
	</form>

</cfoutput>
