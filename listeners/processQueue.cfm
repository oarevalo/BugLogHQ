<cfparam name="key" type="string" default="">

<!--- Handle service initialization if necessary --->
<cfset oService = createObject("component", "bugLog.components.service").init()>

<!--- check that the directory service has been started, if not then start it --->
<cfif Not oService.isRunning() and oService.getSetting("autoStart")>
	<cflock name="bugLogListener_start" timeout="5">
		<!--- use double-checked locking to make sure there is only one initialization --->
		<cfif Not oService.isRunning()>
			<cfset oService.start( )>
		</cfif>
	</cflock>
</cfif>

<!--- process queue --->
<cfset oBugLogListener = oService.getService()>
<cfset rtn = oBugLogListener.processQueue(key)>

<!--- check return code --->
<cfif rtn lt 0>
	<cfset oBugLogListener.shutDown()>
</cfif>
