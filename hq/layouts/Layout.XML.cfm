<cfsetting enablecfoutputonly=true>
<cfsetting showdebugoutput=false>

<cfcontent type="text/xml"><?xml version="1.0" encoding="ISO-8859-1"?>
<cfif request.requestState.view neq "">
	<cfinclude template="../views/#request.requestState.view#.cfm">
</cfif>
								