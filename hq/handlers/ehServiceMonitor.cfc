<cfcomponent name="ehGeneral" extends="eventHandler">

	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			try {
				oService = createObject("component","bugLog.components.service").init();
				aMsgLog = oService.getService().getMessageLog();
				aQueue = oService.getService().getEntryQueue();
				
				// set values
				setValue("aMsgLog", aMsgLog);
				setValue("aQueue", aQueue);
				
				setView("vwServiceMonitor");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehGeneral.dspMain");
			}
		</cfscript>	
	</cffunction>
	
</cfcomponent>