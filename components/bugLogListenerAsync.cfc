<cfcomponent extends="bugLogListener" hint="This listener modified the standard listener so that it processes all bug in an asynchronouse manner">
	
	<cfset variables.queue = arrayNew(1)>
	<cfset variables.msgLog = arrayNew(1)>
	<cfset variables.maxQueueSize = 1000>
	<cfset variables.maxLogSize = 20>
	<cfset variables.schedulerIntervalSecs = 120>
	<cfset variables.key = createUUID()>
	
	<cffunction name="init" access="public" returntype="bugLogListenerAsync" hint="This is the constructor">
		<cfscript>
			// reset queue
			variables.queue = arrayNew(1);
			variables.msgLog = arrayNew(1);

			// start scheduler
			startScheduler();
			
			// continue with normal initialization
			super.init();
			
			logMessage("BugLogListenerAsync Started");
			
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="logEntry" access="public" returntype="void" hint="This method adds a bug report entry into BugLog. Bug reports must be passed as RawEntryBeans">
		<cfargument name="entryBean" type="rawEntryBean" required="true">
		<cflock name="bugLogListenerAsync_logEntry" type="exclusive" timeout="10">
			<cfif arrayLen(variables.queue) lte variables.maxQueueSize>
				<cfset arrayAppend(variables.queue, arguments.entryBean)>
			<cfelse>
				<cfset logMessage("Queue full! Discarding entry.")>
			</cfif>
		</cflock>
	</cffunction>	
	
	<cffunction name="processQueue" access="public" returntype="numeric" hint="Processes all entries on the queue">
		<cfargument name="key" type="string" required="true">
		<cfset var myQueue = arrayNew(1)>
		<cfset var i = 0>
		<cfset var errorQueue = arrayNew(1)>
		
		<cfif arguments.key neq variables.key>
			<cfset logMessage("Invalid key received. Exiting.")>
			<cfreturn -1>
		</cfif>
		
		<cflock name="bugLogListenerAsync_processQueue" type="exclusive" timeout="10">
			<cfset myQueue = duplicate(variables.queue)> <!--- get a snapshot of the queue as of right now --->
			<cfset variables.queue = arrayNew(1)>	<!--- clear the queue now --->
			<cfif arrayLen(myQueue) gt 0>
				<cfset logMessage("Processing queue. Queue size: #arrayLen(myQueue)#")>
				<cfloop from="1" to="#arrayLen(myQueue)#" index="i">
					<cftry>
						<cfset super.logEntry(myQueue[i])>
						<cfcatch type="any">
							<!--- log error and save entry in another queue --->
							<cfset arrayAppend(errorQueue,myQueue[i])>
							<cfset logMessage("ERROR: #cfcatch.message# #cfcatch.detail#. Original message in entry: '#myQueue[i].getMessage()#'")>
						</cfcatch>
					</cftry>
				</cfloop>
			</cfif>
		</cflock>
			
		<!--- add back all entries on the error queue to the main queue --->
		<cfloop from="1" to="#arrayLen(errorQueue)#" index="i">
			<cfset logEntry(errorQueue[i])>
		</cfloop>
		<cfif arrayLen(errorQueue) gt 0>
			<cfset logMessage("Failed to add #arrayLen(errorQueue)# entries. Returned entries to main queue. To clear up queue and discard this entries reset the listener.")>
		</cfif>
		
		<cfreturn 0>
	</cffunction>

	<cffunction name="shutDown" access="public" returntype="void" hint="Performs any clean up action required">
		<cfset logMessage("Stopping BugLogListenerAsync service...")>
		<cfset logMessage("Stopping scheduled task...")>
		<cfschedule action="delete"	task="bugLogProcessQueue" />	
		<cfset logMessage("Processing remaining elements in queue...")>
		<cfset processQueue(variables.key)>
		<cfset logMessage("BugLogListenerAsync stopped.")>
	</cffunction>
	
	
	<!--- Private methods --->
	
	<cffunction name="logMessage" access="private" output="false" returntype="void">
		<cfargument name="msg" type="string" required="true" />
		<cfset var System = CreateObject('java','java.lang.System') />
		<cfset var txt = timeFormat(now(), 'HH:mm:ss') & ": " & msg>
		<cfset System.out.println("BugLogListenerAsync: " & txt) />
		<cflock name="bugLogListenerAsync_logMessage" type="exclusive" timeout="10">
			<cfif arrayLen(variables.msgLog) gt variables.maxLogSize>
				<cfset arrayDeleteAt(variables.msgLog, ArrayLen(variables.msgLog))>
			</cfif>
			<cfset arrayPrepend(variables.msgLog,txt)>
		</cflock>
	</cffunction>
	
	<cffunction name="startScheduler" access="private" output="false" returntype="void">
		<cfschedule action="update"
			task="bugLogProcessQueue"
			operation="HTTPRequest"
			startDate="#createDate(1990,1,1)#"
			startTime="00:00"
			endTime="23:59"
			url="http://#cgi.HTTP_HOST#/bugLog/listeners/processQueue.cfm?key=#variables.KEY#"
			interval="#variables.schedulerIntervalSecs#"
		/>		
	</cffunction>
	
	
	<!--- Getters --->
	
	<cffunction name="getMessageLog" access="public" returntype="array">
		<cfreturn variables.msgLog>
	</cffunction>

	<cffunction name="getEntryQueue" access="public" returntype="array">
		<cfreturn variables.queue>
	</cffunction>

	<cffunction name="getKey" access="public" returntype="string">
		<cfreturn variables.key>
	</cffunction>
	
</cfcomponent>