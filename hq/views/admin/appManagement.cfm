<cfparam name="rs.id" default="">
<cfset qryData = request.requestState.qryData>

<cfoutput>
	<h3>Application Management:</h3>
	
	<div style="margin-left:30px;">
		
		<cfif isNumeric(rs.id) and rs.id gte 0>
			<cfquery name="qryItem" dbtype="query">
				SELECT * FROM qryData WHERE applicationID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#rs.id#">
			</cfquery>
			<form name="frm" method="post" action="index.cfm">
				<input type="hidden" name="event" value="admin.doSaveApplication">
				<input type="hidden" name="id" value="#rs.id#">
				<table>
					<tr>
						<td><b>Code:</b></td>
						<td><input type="text" name="code" value="#qryItem.code#"></td>
					</tr>
					<tr>
						<td><b>Name:</b></td>
						<td><input type="text" name="name" value="#qryItem.name#"></td>
					</tr>
				</table>
				<input type="submit" value="Apply Changes">
				&nbsp;&nbsp;
				<a href="index.cfm?event=admin.main&panel=appManagement">Cancel</a>
				<cfif rs.id gt 0>
					&nbsp;&nbsp;|&nbsp;&nbsp;
					<a href="index.cfm?event=main&applicationID=#rs.id#&hostID=0&severityID=0&numdays=30">View Bug Reports (Last 30 days)</a>
				</cfif>
			</form>
			<br><br><br>
		<cfelseif listLen(rs.id,":") eq 2 and listFirst(rs.id,":") eq "DELETE" and listLast(rs.id,":") gt 0>
			<cfset theID = listLast(rs.id,":")>
			<cfquery name="qryItem" dbtype="query">
				SELECT * FROM qryData WHERE applicationID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#theID#">
			</cfquery>
			<form name="frm" method="post" action="index.cfm">
				<input type="hidden" name="event" value="admin.doDeleteApplication">
				<input type="hidden" name="id" value="#theID#">
				<table>
					<tr>
						<td><b>Code:</b></td>
						<td><input type="text" name="code" value="#qryItem.code#" disabled="true"></td>
					</tr>
					<tr>
						<td><b>Name:</b></td>
						<td><input type="text" name="name" value="#qryItem.name#" disabled="true"></td>
					</tr>
					<tr valign="top">
						<td><b>Existing Bug Reports...</b></td>
						<td>
							<label><input type="radio" name="entryAction" value="delete"> Delete all reports for this Application</label>
							<label><input type="radio" name="entryAction" value="move"> Move all reports to a different Application:
							<select name="moveToAppID">
								<cfloop query="qryData">
									<cfif qryData.applicationID neq theID>
										<option value="#qryData.applicationID#">#qryData.name#</option>
									</cfif>
								</cfloop>
							</select>
							</label>
						</td>
					</tr>
				</table>
				<input type="submit" value="Delete">
				&nbsp;&nbsp;
				<a href="index.cfm?event=admin.main&panel=appManagement">Cancel</a>
				<cfif theID gt 0>
					&nbsp;&nbsp;|&nbsp;&nbsp;	
					<a href="index.cfm?event=main&applicationID=#theid#&hostID=0&severityID=0&numdays=30">View Bug Reports (Last 30 days)</a>
				</cfif>
			</form>
			<br><br><br>
		</cfif>
		
		<table class="table table-bordered table-condensed table-striped">
			<thead>
				<tr>
					<th width="15">&nbsp;</th>
					<th align="left">Code</th>
					<th align="left">Name/Description</th>
					<th>&nbsp;</th>
				</tr>
			</thead>
			<tbody>
				<cfloop query="qryData">
					<tr>
						<td width="15" align="right">#qryData.currentRow#.</td>
						<td><a href="index.cfm?event=admin.main&panel=appManagement&id=#qryData.applicationID#">#qryData.code#</a></td>
						<td><a href="index.cfm?event=admin.main&panel=appManagement&id=#qryData.applicationID#">#qryData.name#</a></td>
						<td align="center" style="width:110px;">
							<a href="index.cfm?event=admin.main&panel=appManagement&id=#qryData.applicationID#">[ Edit ]</a>
							&nbsp;
							<a href="index.cfm?event=admin.main&panel=appManagement&id=DELETE:#qryData.applicationID#">[ Delete ]</a> 
						</td>
					</tr>
				</cfloop>
			</tbody>
		</table>
		<a href="index.cfm?event=admin.main&panel=appManagement&id=0">[ Create New Application ]</a>
		<br /><br />
	</div>
</cfoutput>
