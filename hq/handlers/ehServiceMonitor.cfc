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

	<cffunction name="doProcessQueue" access="public" returntype="void">
		<cfscript>
			var oListener = 0;
			var oService = 0;
			var rtn = 0;

			try {
				oService = createObject("component","bugLog.components.service").init();
				oListener = oService.getService();
				rtn = oListener.processQueue( oListener.getKey() );
				setMessage("info","Queue processed (#rtn#)");
				setNextEvent("ehServiceMonitor.dspMain");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehServiceMonitor.dspMain");
			}
		</cfscript>	
	</cffunction>
		
</cfcomponent>