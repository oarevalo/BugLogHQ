<cfcomponent>

    <cfset variables.debug_mode = false />
    <cfset variables.debug_path = "/bugLog/emails/" />
    <cfset variables.mail_server = "" />
    <cfset variables.mail_port = "" />
    <cfset variables.mail_username = "" />
    <cfset variables.mail_password = "" />
    <cfset variables.mail_useTLS = "" />
    <cfset variables.mail_useSSL = "" />

	<cffunction name="init" access="public" output="false">
        <cfargument name="configObj" type="config" required="true">
        <cfscript>
            variables.debug_mode = arguments.configObj.getSetting("debug.email", variables.debug_mode);
            variables.debug_path = arguments.configObj.getSetting("debug.emailPath", variables.debug_path);
            variables.mail_server = arguments.configObj.getSetting("mail.server", variables.mail_server);
            variables.mail_port = arguments.configObj.getSetting("mail.port", variables.mail_port);
            variables.mail_username = arguments.configObj.getSetting("mail.username", variables.mail_username);
            variables.mail_password = arguments.configObj.getSetting("mail.password", variables.mail_password);
            variables.mail_useTLS = arguments.configObj.getSetting("mail.useTLS", variables.mail_useTLS);
            variables.mail_useSSL = arguments.configObj.getSetting("mail.useSSL", variables.mail_useSSL);
            return this;
        </cfscript>
	</cffunction>

    <cffunction name="send" access="public" returntype="void" hint="Sends an email">
        <cfargument name="from" type="string" required="true">
        <cfargument name="to" type="string" required="true">
        <cfargument name="subject" type="string" required="true">
        <cfargument name="body" type="string" required="true">
        <cfargument name="type" type="string" required="false" default="html">
        <cfif isBoolean(variables.debug_mode) and variables.debug_mode>
            <cfset var txt = "From: #arguments.from#" & chr(10)
                            & "To: #arguments.to#" & chr(10)
                            & "Type: #arguments.type#" & chr(10)
                            & "Subject: #arguments.subject#" & chr(10)
                            & "-----------------------------------" & chr(10)
                            & arguments.body>
            <cfset var ext = arguments.type eq "html" ? "html" : "txt">
            <cfset fileWrite(expandPath(variables.debug_path & getTickCount() & "." & ext),txt,"UTF-8")>
        <cfelse>
            <cfif len(variables.mail_server)>
                <cfmail  
                        from = "#arguments.from#"
                        to = "#arguments.to#"
                        type = "#arguments.type#"
                        subject = "#arguments.subject#"
                        server = "#variables.mail_server#"
                        port = "#variables.mail_port#"
                        username = "#variables.mail_username#"
                        password = "#variables.mail_password#"
                        useTLS = "#variables.mail_useTLS#"
                        useSSL = "#variables.mail_useSSL#"
                        >#arguments.body#  
                </cfmail>
            <cfelse>
                <cfmail  
                        from = "#arguments.from#"
                        to = "#arguments.to#"
                        type = "#arguments.type#"
                        subject = "#arguments.subject#"
                        >#arguments.body#  
                </cfmail>
            </cfif>
        </cfif>
    </cffunction>

</cfcomponent>
