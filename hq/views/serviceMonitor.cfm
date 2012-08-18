<cfparam name="request.requestState.interval" default="15">
<cfset aMsgLog = request.requestState.aMsgLog>
<cfset aQueue = request.requestState.aQueue>
<cfset stInfo = request.requestState.stInfo>
<cfset interval = request.requestState.interval>
<cfset dateFormatMask = request.requestState.dateFormatMask>

<cfsavecontent variable="tmpHead">
	<!-- refresh every X seconds -->
	<cfoutput>
		<meta http-equiv="refresh" content="#interval#">
	</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#tmpHead#">


<cfoutput>
	<!--- Page headers --->			
	<cfinclude template="../includes/menu.cfm">
	<br />
	
	<table width="100%" cellspacing="1">
		<tr valign="top">
			<td style="width:400px;">
				<table class="browseTable" style="width:100%padding:1px;">
					<tr><th>Message Log</th></tr>
					<cfloop from="1" to="#arrayLen(aMsgLog)#" index="i">
						<tr <cfif i mod 2>class="altRow"</cfif>>
							<td>#HtmlEditFormat(aMsgLog[i])#</td>
						</tr>
					</cfloop>
				</table>
			</td>
			<td>
				<table class="browseTable" style="width:100%">
					<tr>
						<th colspan="5">
							Entries in Queue (#arrayLen(aQueue)#)
							&nbsp;
							<span style="font-size:10px;color:##43505a;">
								( <a href="index.cfm?event=serviceMonitor.doProcessQueue" style="color:##43505a;">Process</a> )
							</span>
						</th>
					</tr>
					<tr>
						<th width="15">&nbsp;</th>
						<th>Date/Time</th>
						<th>Application</th>
						<th>Host</th>
						<th>Message</th>
					</tr>
					<cfloop from="1" to="#arrayLen(aQueue)#" index="i">
						<cfset st = aQueue[i].getMemento()>
						<tr <cfif i mod 2>class="altRow"</cfif>>
							<td width="15" align="center" style="padding:0px;">
								<cfset tmpImgName = "images/severity/default.png">
								<cfif st.SeverityCode neq "">
									<cfif fileExists(expandPath("images/severity/#lcase(st.SeverityCode)#.png"))>
										<cfset tmpImgName = "images/severity/#lcase(st.SeverityCode)#.png">
									</cfif>
								</cfif>
								<img src="#rs.assetsPath##tmpImgName#" 
										align="absmiddle"
										alt="#lcase(st.SeverityCode)#" 
										title="#lcase(st.SeverityCode)#"
										border="0">
							</td>
							<td align="center" style="width:100px;">#dateFormat(st.receivedOn,dateFormatMask)# #timeFormat(st.receivedOn, 'HH:mm:ss')#</td>
							<td align="center" style="width:120px;">#st.applicationCode#</td>
							<td align="center" style="width:100px;">#st.hostName#</td>
							<td>#HtmlEditFormat(st.message)#</td>
						</tr>
					</cfloop>
					<cfif arrayLen(aQueue) eq 0>
						<tr><td colspan="5"><em>Queue is empty</em></td></tr>
					</cfif>
				</table>
			</td>
		</tr>
	</table>
	<br /><br />
</cfoutput>