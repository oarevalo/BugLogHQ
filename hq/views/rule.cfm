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

<script type="text/javascript">
	function toggleOther(fieldName, fieldValue) {
		if(fieldValue == "__OTHER__") {
			document.getElementById(fieldName+"_other").style.display = "inline";
		} else if(fieldValue == "") {
			document.getElementById(fieldName+"_other").style.display = "none";
		} else {
			document.getElementById(fieldName+"_other").style.display = "none";
		}
	}
</script>

<cfoutput>
	<cfinclude template="../includes/menu.cfm">

	<h3>#ruleLabel#</h3>
	<em>#rs.stRule.description#</em><br /><br /><br />

	<form name="frm" method="post" action="index.cfm">
		<input type="hidden" name="event" value="extensions.doSaveRule">
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
				<cfset tmpType = "text">
				<cfset tmpBugLogType = "">
				<cfif isDefined("rs.aActiveRule.config.#tmpName#")>
					<cfset tmpValue = rs.aActiveRule.config[tmpName]>
				<cfelseif structKeyExists(rs,tmpName)>
					<cfset tmpValue = rs[tmpName]>
				</cfif>
				<cfif structKeyExists(aProps[i],"displayName")>
					<cfset tmpLabel = aProps[i].displayName>
				</cfif>
				<cfif structKeyExists(aProps[i],"buglogType")>
					<cfset tmpBugLogType = aProps[i].buglogType>
				</cfif>
				<cfif structKeyExists(aProps[i],"type")>
					<cfset tmpType = aProps[i].type>
				</cfif>
				<tr valign="top">
					<td><b>#tmpLabel#:</b></td>
					<td>
						<cfswitch expression="#tmpBugLogType#">
							<cfcase value="application">
								<cfset valueFound = (tmpValue eq "")>
								<select name="#tmpName#" id="#tmpName#" onchange="toggleOther(this.name, this.value)" class="formField">
									<option value=""></option>
									<cfloop query="rs.qryApplications">
										<option value="#rs.qryApplications.code#"
												<cfif rs.qryApplications.code eq tmpValue>selected</cfif>
												>#rs.qryApplications.code#</option>
										<cfif rs.qryApplications.code eq tmpValue>
											<cfset valueFound = true>
										</cfif>
									</cfloop>
									<option value="__OTHER__" <cfif !valueFound>selected</cfif>>Other...</option>
								</select>
								<input type="text" name="#tmpName#_other" id="#tmpName#_other" value="#tmpValue#" <cfif valueFound>style="display:none;"</cfif>>
							</cfcase>
							<cfcase value="host">
								<cfset valueFound = (tmpValue eq "")>
								<select name="#tmpName#" id="#tmpName#" onchange="toggleOther(this.name, this.value)" class="formField">
									<option value=""></option>
									<cfloop query="rs.qryHosts">
										<option value="#rs.qryHosts.HostName#"
												<cfif rs.qryHosts.HostName eq tmpValue>selected</cfif>
												>#rs.qryHosts.HostName#</option>
										<cfif rs.qryHosts.HostName eq tmpValue>
											<cfset valueFound = true>
										</cfif>
									</cfloop>
									<option value="__OTHER__" <cfif !valueFound>selected</cfif>>Other...</option>
								</select>
								<input type="text" name="#tmpName#_other" id="#tmpName#_other" value="#tmpValue#" <cfif valueFound>style="display:none;"</cfif>>
							</cfcase>
							<cfcase value="severity">
								<cfset valueFound = (tmpValue eq "")>
								<select name="#tmpName#" id="#tmpName#" onchange="toggleOther(this.name, this.value)" class="formField">
									<option value=""></option>
									<cfloop query="rs.qrySeverities">
										<option value="#rs.qrySeverities.code#"
												<cfif rs.qrySeverities.code eq tmpValue>selected</cfif>
												>#rs.qrySeverities.code#</option>
										<cfif rs.qrySeverities.code eq tmpValue>
											<cfset valueFound = true>
										</cfif>
									</cfloop>
									<option value="__OTHER__" <cfif !valueFound>selected</cfif>>Other...</option>
								</select>
								<input type="text" name="#tmpName#_other" id="#tmpName#_other" value="#tmpValue#" <cfif valueFound>style="display:none;"</cfif>>
							</cfcase>
							<cfcase value="email">
								<cfif !isDefined("rs.aActiveRule.config.#tmpName#")>
									<input type="text" name="#tmpName#" value="#rs.defaultEmail#" class="formField">			
								<cfelse>
									<input type="text" name="#tmpName#" value="#tmpValue#" class="formField">			
								</cfif>
							</cfcase>
							<cfdefaultcase>
								<cfswitch expression="#tmpType#">
									<cfcase value="boolean">
										<input type="radio" name="#tmpName#" value="true" <cfif isBoolean(tmpValue) and tmpValue>checked</cfif>> True &nbsp;&nbsp;
										<input type="radio" name="#tmpName#" value="false" <cfif !isBoolean(tmpValue) or isBoolean(tmpValue) and !tmpValue>checked</cfif>> False &nbsp;&nbsp;
									</cfcase>
									<cfdefaultcase>
										<input type="text" name="#tmpName#" value="#tmpValue#" class="formField">			
									</cfdefaultcase>
								</cfswitch>
							</cfdefaultcase>
						</cfswitch>
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
		<input type="button" value="Cancel" name="btnCancel" onclick="document.location='index.cfm?event=extensions.main'">
	</form>

</cfoutput>
