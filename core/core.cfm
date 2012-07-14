<cfif request.requestState.layoutTemplatePath neq "">
	<cfinclude template="#request.requestState.layoutTemplatePath#">
<cfelseif request.requestState.viewTemplatePath neq "">
	<cfif request.requestState.messageTemplatePath neq "">
		<cfinclude template="#request.requestState.messageTemplatePath#">
	</cfif>
	<cfinclude template="#request.requestState.viewTemplatePath#">
</cfif>