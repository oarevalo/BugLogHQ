<cfparam name="request.requestState.stInfo" default="#structNew()#">
<cfparam name="request.requestState.aRules" default="#arrayNew(1)#">
<cfparam name="request.requestState.aReports" default="#arrayNew(1)#">
<cfparam name="request.requestState.aActiveRules" default="#arrayNew(1)#">
<cfparam name="request.requestState.aActiveReports" default="#arrayNew(1)#">

<cfset currentUser = request.requestState.currentUser>
<cfset rs = request.requestState>

<style type="text/css">
.extensionItem {
	background-color:#ebebeb;
	border-bottom:1px solid #666;
	border-right:1px solid #666;
	border-top:1px solid silver;
	border-left:1px solid silver;
	font-size:14px;
	margin-bottom:15px;
	padding:5px;
}
.extensionItem:hover {
	background-color:#f5f5f5;
}
.extensionItem table {
	margin-top:10px;
	border-collapse:collapse;
}
.extensionItem td {
	padding:5px;
	font-size:11px;
	border:1px solid silver;
}
.migrationNotice {
	margin:20px;
	padding:10px;
	font-size:14px;
	border:1px dashed silver;
	background-color:#FFFFE0;
}
</style>
<script type="text/javascript"> 
	function confirmDeleteRule(index) {
		if(confirm("Are you sure you wish to remove the rule")) {
			document.location='index.cfm?event=extensions.doDeleteRule&index='+index;
		}
	}
</script>


<cfoutput>
<cfinclude template="../includes/menu.cfm">

<p>
	Rules are processes that are executed as each bug report is processed. Use rules to perform tasks such
	as monitoring for specific error messages, or messages coming from specific applications.<br />
	
	<div style="color:red;margin-top:8px;font-weight:bold;">
		<cfif currentUser.getIsAdmin()>
			NOTE: Any changes to extensions will only become effective after restarting the bugLog service.
		<cfelse>
			NOTE: Only an administrator can create or modify rules
		</cfif>
	</div>
</p>

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
</cfif>

<hr />

<cfif currentUser.getIsAdmin()>
	<form name="frm" method="get" action="index.cfm" style="margin:15px;margin-left:0px;margin-bottom:25px;">
		<input type="hidden" name="event" value="extensions.rule">

		<strong style="font-size:12px;">&raquo; Create a new rule of type: </strong>
		<select name="ruleName">
			<cfloop from="1" to="#arrayLen(rs.aRules)#" index="i">
				<cfset ruleName = listLast(rs.aRules[i].name,".")>
				<option value="#ruleName#">#ruleName#</option>
			</cfloop>
		</select>
		<input type="submit" value="GO">
		
		&nbsp;|&nbsp;
		<a href="index.cfm?event=extensions.rulesLog"><b>View Rule Processor Log</b></a>
	</form>
</cfif>	

<cfloop from="1" to="#arrayLen(rs.aActiveRules)#" index="i">
	<cfset item = rs.aActiveRules[i]>
	<cfset ruleName = listLast(item.component,".")>
	<cfset lstProps = listSort(structKeyList(item.config),"textnocase")>
	
	<div class="extensionItem">
		<div style="width:120px;font-weight:bold;float:right;">
			<cfif not item.enabled>
				<span style="color:red;">Disabled</span>
			<cfelse>
				<span style="color:green;">Enabled</span>
			</cfif>
		</div>
	
		<b>#ruleName#</b>
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
		
		<div style="margin-top:5px;">
			#item.description#
		</div>
		
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
	</div>
</cfloop>
<cfif arrayLen(rs.aActiveRules) eq 0>
	<em>There are no active rules</em>
</cfif>


</cfoutput>
