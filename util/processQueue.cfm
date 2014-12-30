<cfsetting requesttimeout="999999"> 

<cfparam name="url.key" type="string" default="">
<cfparam name="url.instance" type="string" default="">

<cfscript>
    try {
        // Handle service initialization if necessary
        oService = createObject("component", "bugLog.components.service").init( instanceName = url.instance );

        // process pending queue
        if(oService.isRunning()) {
            oBugLogListener = oService.getService();
            oBugLogListener.processQueue( url.key );
        }
    
    } catch(any e) {
        // report the error
        bugLogClient = createObject("component", "bugLog.client.bugLogService").init("bugLog.listeners.bugLogListenerWS");
        bugLogClient.notifyService(e.message, e);
    }
</cfscript>
