<cfset rs = request.requestState />

<cfinclude template="../includes/udf.cfm">

<cfset maxPreviewEntries = 10>
<cfset oApp = rs.oEntry.getApplication()>

<cfquery name="qryEntriesOthers" dbtype="query">
    SELECT *
        FROM rs.qryEntriesAll
        WHERE entryID < <cfqueryparam cfsqltype="cf_sql_numeric" value="#entryID#">
        ORDER BY createdOn DESC
</cfquery>

<cfquery name="qryHosts" dbtype="query">
    SELECT hostID, hostName, count(hostID) as numEntries
        FROM rs.qryEntriesAll
        GROUP BY hostID, hostName
</cfquery>

<cfif rs.qryEntriesUA.recordCount gt 0>
    <cfquery name="qryUAEntries" dbtype="query">
        SELECT *
            FROM rs.qryEntriesUA
            WHERE entryID <> <cfqueryparam cfsqltype="cf_sql_numeric" value="#entryID#">
            ORDER BY createdOn DESC
    </cfquery>
<cfelse>
    <cfset qryUAEntries = queryNew("")>
</cfif>

<cfoutput>
    <div class="well">
        <h3>Stats</h3>
        <ul>
        <cfif rs.qryEntriesLast24.recordCount gt 1>
            <li>
                <b>#rs.qryEntriesLast24.recordCount#</b> reports with the 
                <a href="##" onclick="$('##last24hentries').slideToggle()" title="click to expand"><b>same message</b> <i class="icon-circle-arrow-down"></i></a>
                in the last 24 hours.
                <ul id="last24hentries" style="display:none;margin-top:5px;">
                    <cfloop query="rs.qryEntriesLast24" startrow="1" endrow="#min(maxPreviewEntries,rs.qryEntriesLast24.recordCount)#">
                        <li>
                            <cfif rs.qryEntriesLast24.entryID eq rs.oEntry.getEntryID()><span class="label label-info">This</span> </cfif>
                            <a href="index.cfm?event=entry&entryID=#rs.qryEntriesLast24.entryID#">#showDateTime(rs.qryEntriesLast24.createdOn,"m/d","hh:mm tt")#</a> 
                             on
                            <b>#rs.qryEntriesLast24.hostName#</b>
                        </li>
                    </cfloop>
                    <cfif rs.qryEntriesLast24.recordCount gt maxPreviewEntries>
                        <li>... #rs.qryEntriesLast24.recordCount-maxPreviewEntries# more (<a href="index.cfm?event=log&numDays=1&msgFromEntryID=#entryID#&applicationID=#oApp.getApplicationID()#&hostID=0&severityID=0">See all</a>)</li>
                    </cfif>
                </ul>
            </li>
        <cfelse>
            <li>This is the <b>first time</b> this message has ocurred in the last 24 hours.</li>
        </cfif>
        <cfif qryUAEntries.recordCount gt 0>
            <li>
                <b>#rs.qryEntriesUA.recordCount#</b> reports with the
                <a href="##" onclick="$('##uaentries').slideToggle()" title="click to expand"><b>same user agent</b> <i class="icon-circle-arrow-down"></i></a>
                in the last 24 hrs.
                <ul id="uaentries" style="display:none;margin-top:5px;">
                    <cfloop query="qryUAEntries" startrow="1" endrow="#min(maxPreviewEntries,qryUAEntries.recordCount)#">
                        <li>
                            <cfif qryUAEntries.entryID eq rs.oEntry.getEntryID()><span class="label label-info">This</span> </cfif>
                            #showDateTime(qryUAEntries.createdOn,"m/d","hh:mm tt")#: 
                            <b>#qryUAEntries.applicationCode#</b> on
                            <b>#qryUAEntries.hostName#</b> :
                            <a href="index.cfm?event=entry&entryID=#qryUAEntries.entryID#">#htmlEditFormat(qryUAEntries.message)#</a></li>
                    </cfloop>
                    <cfif qryUAEntries.recordCount gt maxPreviewEntries>
                        <li>... #qryUAEntries.recordCount-maxPreviewEntries# more (not shown)</li>
                    </cfif>
                </ul>
            </li>
        </cfif>        
        <cfif rs.qryEntriesAll.recordCount gt 0>
            <li style="margin-top:4px;">
                <cfset firstOccurrence = rs.qryEntriesAll.createdOn[rs.qryEntriesAll.recordCount]>
                <cfset firstOccurrenceID = rs.qryEntriesAll.entryID[rs.qryEntriesAll.recordCount]>
                This bug has ocurred 
                <a href="##" onclick="$('##allentries').slideToggle()" title="click to expand"><b>#rs.qryEntriesAll.recordCount#</b> time<cfif rs.qryEntriesAll.recordCount gt 1>s</cfif> <i class="icon-circle-arrow-down"></i></a>
                since 
                <a href="index.cfm?event=entry&entryID=#firstOccurrenceID#"><b>#showDateTime(firstOccurrence)#</b></a>
                <ul id="allentries" style="display:none;margin-top:5px;">
                    <cfloop query="rs.qryEntriesAll" startrow="1" endrow="#min(maxPreviewEntries,rs.qryEntriesAll.recordCount)#">
                        <li>
                            <cfif rs.qryEntriesAll.entryID eq rs.oEntry.getEntryID()><span class="label label-info">This</span> </cfif>
                            <a href="index.cfm?event=entry&entryID=#rs.qryEntriesAll.entryID#">#showDateTime(rs.qryEntriesAll.createdOn,"m/d","hh:mm tt")#</a>
                             on
                            <b>#rs.qryEntriesAll.hostName#</b>
                        </li>
                    </cfloop>
                    <cfif rs.qryEntriesAll.recordCount gt maxPreviewEntries>
                        <li>... #rs.qryEntriesAll.recordCount-maxPreviewEntries# more (<a href="index.cfm?event=log&numDays=360&msgFromEntryID=#entryID#&applicationID=#oApp.getApplicationID()#&hostID=0&severityID=0">See all</a>)</li>
                    </cfif>
                </ul>
            </li>
        </cfif>
        <cfif qryEntriesOthers.recordCount gt 0>
            <li style="margin-top:4px;">
                The previous time this bug was reported was on 
                <a href="index.cfm?event=entry&entryID=#qryEntriesOthers.entryID#"><b>#showDateTime(qryEntriesOthers.createdOn)#</b></a>
            </li>
        </cfif>
        </ul>
        <cfif qryHosts.recordCount gt 0>
            <div style="margin-top:12px;">
                <b>Host Distribution:</b><br />
                <table class="table table-condensed">
                    <cfset totalEntries = arraySum(listToArray(valueList(qryHosts.numEntries)))>
                    <cfloop query="qryHosts">
                        <tr>
                            <td><a href="index.cfm?event=log&numDays=1&msgFromEntryID=#entryID#&applicationID=0&hostID=#hostID#">#hostName#</a></td>
                            <td>#numEntries# (#round(numEntries/totalEntries*100)#%)</td>
                        </tr>
                    </cfloop>
                </table>
            </div>
        </cfif>
    </div>  
</cfoutput>

