<cfcomponent hint="this component provides caching functionality to clients">
	
	<!--- number of max items to store in the cache --->
	<cfset variables.cacheSize = 10>
	<!--- time to live in minutes for items in the cached --->
	<cfset variables.cacheTTL = 30>
	<!--- structure where data will be stored --->
	<cfset variables.stData = structNew()>
	<!--- this struct will be used for keeping track of cache performance for tuning --->
	<cfset variables.stInfo = structNew()>
	<!--- flag to collect stats --->
    <cfset variables.collectStats = true>
	<!--- max limit for the hits/miss counters --->
    <cfset variables.counterLimit = 9999999>

	<!-------------------------------------->
	<!--- init                         	  --->
	<!-------------------------------------->	
	<cffunction name="init" access="public" returnType="cacheService">
		<cfargument name="cacheSize" type="numeric" required="false" default="#variables.cacheSize#">
		<cfargument name="cacheTTL" type="numeric" required="false" default="#variables.cacheTTL#">
		<cfargument name="collectStats" type="boolean" required="false" default="#variables.collectStats#">
			
        <cfset var Collections = createObject("java", "java.util.Collections")>
        <cfset var Map = CreateObject("java","java.util.HashMap").init()>    
            
		<!--- set instance variables --->
		<cfset variables.cacheSize = arguments.cacheSize>
		<cfset variables.cacheTTL = arguments.cacheTTL>
		<cfset variables.collectStats = arguments.collectStats>
		
		<!--- structure where data will be stored --->
        <!--- use a thread-safe java hash map to store the data --->
		<cfset variables.stData = Collections.synchronizedMap( Map )>

		<!--- create the structure to keep track of cache stats --->	
        <cfif variables.collectStats>
			<cfset variables.stInfo = structNew()>
            <cfset variables.stInfo.maxSize = variables.cacheSize>
            <cfset variables.stInfo.currentSize = 0>
            <cfset variables.stInfo.hitCount = 0>
            <cfset variables.stInfo.missCount = 0>
            <cfset variables.stInfo.lastReap = 0>
		</cfif>
		
		<cfreturn this>
	</cffunction>

	<!-------------------------------------->
	<!--- getStats                         	  --->
	<!-------------------------------------->	
	<cffunction name="getStats" access="public" returnType="struct" hint="returns information about the cache">
    	<cfif variables.collectStats>
			<cfset variables.stInfo.currentSize = structCount(variables.stData)>
        </cfif>
		<cfreturn variables.stInfo>
	</cffunction>

	<!-------------------------------------->
	<!--- list                        	  --->
	<!-------------------------------------->	
	<cffunction name="list" access="public" returnType="array" hint="returns the list of items on the cache">
    	<cfset var aItems = arrayNew(1)>
        <cfset var st = structNew()>
        <cfset var key = "">
        
        <cfloop collection="#variables.stData#" item="key">
        	<cfset st = structNew()>
            <cfset st.key = key>
            <cfset st.timestamp = variables.stData[key].timestamp>
            <cfset arrayAppend(aItems, st)>
        </cfloop>
        
		<cfreturn aItems>
	</cffunction>


	<!-------------------------------------->
	<!--- retrieve                         	  --->
	<!-------------------------------------->	
	<cffunction name="retrieve" access="public" returntype="any" hint="retrieves an item on the cache. If item is not on cache or is not valid, then throws an error">
		<cfargument name="key" type="string" required="true">

		<!---check if the item exists in the cache and if it is still valid --->
		<cfif structKeyExists(variables.stData, arguments.key)>
			<cfif DateDiff("n", variables.stData[arguments.key].timestamp, now()) lt variables.cacheTTL>
			
				<!--- update hit count --->
                <cfif variables.collectStats>
                	<cfif variables.stInfo.hitCount lt variables.counterLimit>
						<cfset variables.stInfo.hitCount = variables.stInfo.hitCount + 1>
                    <cfelse>
						<cfset variables.stInfo.hitCount = 1>
                    </cfif>
                </cfif>
				
				<!--- return data --->
				<cfreturn variables.stData[arguments.key].data>
			</cfif>
		</cfif>
		
		<!--- item not in cache, or not valid. Update miss count --->
        <cfif variables.collectStats>
           	<cfif variables.stInfo.missCount lt variables.counterLimit>
				<cfset variables.stInfo.missCount = variables.stInfo.missCount + 1>
			<cfelse>
                <cfset variables.stInfo.missCount = 1>
            </cfif>
        </cfif>
		<cfthrow type="cacheService.itemNotFound" message="Item not found in cache or item no longer valid">
		
	</cffunction>
	
	<!-------------------------------------->
	<!--- store                         	  --->
	<!-------------------------------------->	
	<cffunction name="store" access="public" returntype="void" hint="stores an item on the cache">
		<cfargument name="key" type="string" required="true">
		<cfargument name="data" type="any" required="true">

		<cfset var memCacheKey = "">
		<cfset var tmpOldestCacheKey = "">
		<cfset var tmpOldestTS = now()>
		
		<cfset tmpOldestTS = createDate(2050,1,1)>
		
		<!---  check the size of the mem cache struct --->
		<cfif structCount(variables.stData) gte variables.cacheSize>
			
			<!--- cache size is too big, so get rid of old entries --->
			<cfset tmpOldestCacheKey = cleanup()>
			
			<!--- if cache is still too big, then get rid of the oldest --->
			<cfif structCount(variables.stData) gte variables.cacheSize>
				<cfset structDelete(variables.stData, tmpOldestCacheKey)>
			</cfif>
		</cfif>
		
		<!--- store data on cache --->
		<cfset variables.stData[arguments.key] = structNew()>
		<cfset variables.stData[arguments.key].data = arguments.data>
		<cfset variables.stData[arguments.key].timestamp = now()>
		
	</cffunction>


	<!-------------------------------------->
	<!--- cleanup                      	  --->
	<!-------------------------------------->	
	<cffunction name="cleanup" access="public" returntype="string" hint="cleans up the cache for old entries. Returns the key of the oldest entry">
		<cfset var memCacheKey = "">
		<cfset var tmpOldestCacheKey = "">
		<cfset var tmpOldestTS = now()>
		<cfset var lstKeys = "">
        
		<cfset tmpOldestTS = createDate(2050,1,1)>
        <cfset lstKeys = structKeyList(variables.stData)>
		
		<!--- cache size is too big, so get rid of old entries --->
        <cfloop list="#lstKeys#" index="memCacheKey">
            <cfif DateDiff("n", variables.stData[memCacheKey].timestamp, now()) gt variables.cacheTTL>
                <cfset structDelete(variables.stData, memCacheKey)>
            <cfelse>
                <cfif DateCompare(variables.stData[memCacheKey].timestamp, tmpOldestTS) lt 0>
                    <cfset tmpOldestCacheKey = memCacheKey>
                    <cfset tmpOldestTS = variables.stData[memCacheKey].timestamp>
                </cfif>
            </cfif>
        </cfloop>
		
        <!--- record time of last reap --->
        <cfif variables.collectStats>
	        <cfset variables.stInfo.lastReap = Now()>
        </cfif>
        
        <cfreturn tmpOldestCacheKey>
	</cffunction>

			
	<!-------------------------------------->
	<!--- flush                        	  --->
	<!-------------------------------------->	
	<cffunction name="flush" access="public" returntype="any" hint="Removes an item from the cache">
		<cfargument name="key" type="string" required="true">
		<cfif structKeyExists(variables.stData, arguments.key)>
			<cfset structDelete(variables.stData, arguments.key)>
		</cfif>
	</cffunction>	
		
	
</cfcomponent>