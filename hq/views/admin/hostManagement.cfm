<cfparam name="rs.id" default="">
<cfset qryData = request.requestState.qryData>

<cfoutput>
	<h3>Host Management:</h3>
	
	<div style="margin-left:30px;">
		
		<cfif isNumeric(rs.id) and rs.id gte 0>
			<cfquery name="qryItem" dbtype="query">
				SELECT * FROM qryData WHERE hostID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#rs.id#">
			</cfquery>
			<form name="frm" method="post" action="index.cfm">
				<input type="hidden" name="event" value="admin.doSaveHost">
				<input type="hidden" name="id" value="#rs.id#">
				<table>
					<tr>
						<td><b>Name:</b></td>
						<td><input type="text" name="name" value="#qryItem.hostname#"></td>
					</tr>
				</table>
				<input type="submit" value="Apply Changes">
				&nbsp;&nbsp;
				<a href="index.cfm?event=admin.main&panel=hostManagement">Cancel</a>
				<cfif rs.id gt 0>
					&nbsp;&nbsp;|&nbsp;&nbsp;
					<a href="index.cfm?event=main&applicationID=0&hostID=#rs.id#&severityID=0&numdays=30">View Bug Reports (Last 30 days)</a>
				</cfif>
			</form>
			<br><br><br>
		<cfelseif listLen(rs.id,":") eq 2 and listFirst(rs.id,":") eq "DELETE" and listLast(rs.id,":") gt 0>
			<cfset theID = listLast(rs.id,":")>
			<cfquery name="qryItem" dbtype="query">
				SELECT * FROM qryData WHERE hostID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#theID#">
			</cfquery>
			<form name="frm" method="post" action="index.cfm">
				<input type="hidden" name="event" value="admin.doDeleteHost">
				<input type="hidden" name="id" value="#theID#">
				<table>
					<tr>
						<td><b>Name:</b></td>
						<td><input type="text" name="name" value="#qryItem.hostname#" disabled="true"></td>
					</tr>
					<tr valign="top">
						<td><b>Existing Bug Reports...</b></td>
						<td>
							<label><input type="radio" name="entryAction" value="delete"> Delete all reports for this Hostname</label>
							<label><input type="radio" name="entryAction" value="move"> Move all reports to a different Hostname:
							<select name="moveTohostID">
								<cfloop query="qryData">
									<cfif qryData.hostID neq theID>
										<option value="#qryData.hostID#">#qryData.hostname#</option>
									</cfif>
								</cfloop>
							</select>
							</label>
						</td>
					</tr>
				</table>
				<input type="submit" value="Delete">
				&nbsp;&nbsp;
				<a href="index.cfm?event=admin.main&panel=hostManagement">Cancel</a>
				<cfif theID gt 0>
					&nbsp;&nbsp;|&nbsp;&nbsp;
					<a href="index.cfm?event=main&hostID=#theID#&applicationID=0&severityID=0&numdays=30">View Bug Reports (Last 30 days)</a>
				</cfif>
			</form>
			<br><br><br>
		</cfif>
		
		<table class="table table-bordered table-condensed table-striped">
			<thead>
				<tr>
					<th width="15">&nbsp;</th>
					<th align="left">Name</th>
					<th>&nbsp;</th>
				</tr>
			</thead>
			<tbody>
				<cfloop query="qryData">
					<tr>
						<td width="15" align="right">#qryData.currentRow#.</td>
						<td><a href="index.cfm?event=admin.main&panel=hostManagement&id=#qryData.hostID#">#qryData.hostname#</a></td>
						<td align="center" style="width:110px;">
							<a href="index.cfm?event=admin.main&panel=hostManagement&id=#qryData.hostID#">[ Edit ]</a>
							&nbsp;
							<a href="index.cfm?event=admin.main&panel=hostManagement&id=DELETE:#qryData.hostID#">[ Delete ]</a> 
						</td>
					</tr>
				</cfloop>
			</tbody>
		</table>
		<a href="index.cfm?event=admin.main&panel=hostManagement&id=0">[ Create New Host ]</a>
		<br /><br />
	</div>
</cfoutput>
