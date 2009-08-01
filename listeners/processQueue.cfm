<cfparam name="key" type="string" default="">

<!--- Handle service initialization if necessary --->
<cfset oService = createObject("component", "bugLog.components.service").init()>

<!--- check that the directory service has been started, if not then start it --->
<cfif Not oService.isRunning()>
	<cflock name="bugLogListener_start" timeout="5">
		<!--- use double-checked locking to make sure there is only one initialization --->
		<cfif Not oService.isRunning()>
			<cfset oService.start( )>
		</cfif>
	</cflock>
</cfif>

<!--- process queue --->
<cfset oBugLogListener = oService.getService()>
<cfset oBugLogListener.processQueue(key)>