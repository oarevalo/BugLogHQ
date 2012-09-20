<cfset currentUser = request.requestState.currentUser>

<cfset aPanels = [
				{ id = "rules", label = "Current Rules"},
				{ id = "history", label = "History"}
				]>
<cfset lstPanelIDs = "">

<cfinclude template="../includes/udf.cfm">

<cfoutput>
<cfinclude template="../includes/menu.cfm">

<br />

<div id="extensions-content">
	<div id="extensions-side">
		<div class="well well-small">
			<span class="label label-important">Important:</span>
			<span style="color:##990000;">
			<cfif currentUser.getIsAdmin()>
				Any changes to extensions will only become effective after restarting the bugLog service.
			<cfelse>
				Only an administrator can create or modify rules
			</cfif>
			</span>
		</div>

		<cfif currentUser.getIsAdmin()>
			<div class="well well-small">
				<h3>Create a Rule</h3>
				<form name="frm" method="get" action="index.cfm" style="margin-top:5px;">
					<input type="hidden" name="event" value="extensions.rule">
			
					<select name="ruleName" style="width:180px;" id="newRuleSelector">
						<option value="">-- Select rule type --</option>
						<cfloop from="1" to="#arrayLen(rs.aRules)#" index="i">
							<cfset ruleName = listLast(rs.aRules[i].name,".")>
							<option value="#ruleName#">#ruleName#</option>
						</cfloop>
					</select>
					<input type="submit" value="GO">
					<cfloop from="1" to="#arrayLen(rs.aRules)#" index="i">
						<cfset ruleName = listLast(rs.aRules[i].name,".")>
						<div id="rule_#ruleName#" class="ruleDescription" style="display:none;">
							<img src="#rs.assetsPath#images/icons/information.png">
							#rs.aRules[i].description#
						</div>
					</cfloop>
				</form>
			</div>
		</cfif>	

		<div class="well well-small">
			<h3>What Are Rules?</h3>
			<p>Rules are processes that are executed as each bug report is processed. Use rules to perform tasks such
			as monitoring for specific error messages, or messages coming from specific applications.</p>
		</div>
	</div>
	
	<div id="extensions-main">
		<cfif rs.hasExtensionsXMLFile and currentUser.getIsAdmin()>
			<div class="migrationNotice">
				<b style="color:##990000">UPGRADE REQUIRED:</b>
				BugLog has detected that you have rules defined using the <b>extensions-config.xml.cfm</b> file. This file is no longer
				supported and rules are now stored on the database. BugLog can migrate these rules automatically if you want, 
				or alternatively it can delete this file and you can
				the rules manually.<br /><br />
				<input type="button" name="btn" value="Yes, migrate my rules" onclick="document.location='?event=extensions.doMigrateExtensionsXML'">
				&nbsp;
				<input type="button" name="btn" value="No, just delete the file" onclick="if(confirm('Are you sure?')) document.location='?event=extensions.doDeleteExtensionsXML'">
			</div>
			<br />
		</cfif>
		
		<div class="span4" style="margin-left:0px;">
		<ul class="nav nav-pills">
			<cfloop from="1" to="#arrayLen(aPanels)#" index="i">
				<li <cfif rs.panel eq aPanels[i].id>class="active"</cfif>>
					<a href="index.cfm?event=extensions.main&panel=#aPanels[i].id#" style="text-decoration:none;">#aPanels[i].label#</a>
				</li>
				<cfset lstPanelIDs = listAppend(lstPanelIDs,aPanels[i].id)>
			</cfloop>
		</ul>
		</div>

		<br />
		<cfif listFind(lstPanelIDs,rs.panel)>
			<cfinclude template="extensions/#rs.panel#.cfm">
		<cfelse>
			<em>Select an option from the menu</em>
		</cfif>
	</div>	
</div>
<hr />
</cfoutput>
