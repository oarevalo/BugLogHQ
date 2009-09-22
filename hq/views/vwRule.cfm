<cfparam name="request.requestState.stInfo" default="#structNew()#">
<cfparam name="request.requestState.stRule" default="#structNew()#">
<cfparam name="request.requestState.aActiveRule" default="#structNew()#">

<cfset rs = request.requestState>
<cfset ruleName = listLast(rs.stRule.name,".")>
<cfset ruleLabel = ruleName>
<cfparam name="rs.aActiveRule.description" default="">

<cfif structKeyExists(rs.stRule,"displayName")>
	<cfset ruleLabel = rs.stRule.displayName>
</cfif>

<cfoutput>
	<h2 style="margin-bottom:3px;">BugLog Add/Edit Rule</h2>
	<cfinclude template="../includes/menu.cfm">

	<h3>#ruleLabel#</h3>
	<em>#rs.stRule.description#</em><br /><br /><br />

	<form name="frm" method="post" action="index.cfm">
		<input type="hidden" name="event" value="ehExtensions.doSaveRule">
		<input type="hidden" name="ruleName" value="#ruleName#">
		<input type="hidden" name="index" value="#rs.index#">
	
		<table>
			<tr valign="top">
				<td><b>Description:</b></td>
				<td><textarea name="description" rows="3" class="formField">#trim(rs.aActiveRule.description)#</textarea></td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>

			<cfset aProps = rs.stRule.properties>
			<cfloop from="1" to="#arrayLen(aProps)#" index="i">
				<cfset tmpName = aProps[i].name>
				<cfset tmpValue = "">
				<cfset tmpLabel = tmpName>
				<cfif isDefined("rs.aActiveRule.config.#tmpName#")>
					<cfset tmpValue = rs.aActiveRule.config[tmpName]>
				</cfif>
				<cfif structKeyExists(aProps[i],"displayName")>
					<cfset tmpLabel = aProps[i].displayName>
				</cfif>
				<tr valign="top">
					<td><b>#tmpLabel#:</b></td>
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
