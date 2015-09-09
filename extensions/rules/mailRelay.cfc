<cfcomponent extends="bugLog.components.baseRule" 
            hint="This rule sends an email everytime a bug is received">

    <cfproperty name="recipientEmail" buglogType="email" displayName="Recipient Email" type="string" hint="The email address to which to send the notifications">
    <cfproperty name="includeHTMLReport" type="boolean" displayName="Include HTML Report?" hint="When enabled, the HTML Report section of the bug report is included in the email body">

    <cffunction name="init" access="public" returntype="bugLog.components.rules.Rule">
        <cfargument name="recipientEmail" type="string" required="true">
        <cfargument name="includeHTMLReport" type="string" required="false" default="">
        <cfscript>
            arguments.includeHTMLReport = (isBoolean(arguments.includeHTMLReport) && arguments.includeHTMLReport);
            super.init(argumentCollection = arguments);
            return build();
        </cfscript>
    </cffunction>

    <cffunction name="buildRule" access="public" returntype="bugLog.components.rules.Rule">
        <cfscript>
            var r = new bugLog.components.rules.Rule( getExtensionID() );

            var s = new bugLog.components.rules.Scope( 
                    application = config.application,
                    host = config.host,
                    severity = config.severity
                );
            r.setScope(s);

            var a = new bugLog.components.rules.actions.SendEmail(
                    senderEmail = getListener().getConfig().getSetting("general.adminEmail"),
                    recipientEmail = config.recipientEmail,
                    includeHTMLReport = config.includeHTMLReport,
                    messageText = getAlertMessage()
                );
            a.setMailerService( mailerService );
            r.addAction(a);

            return r;
        </cfscript> 
    </cffunction>

    <cffunction name="explain" access="public" returntype="string">
        <cfset var rtn = "Sends an alert ">
        <cfif variables.config.recipientEmail  neq "">
            <cfset rtn &= " to <b>#variables.config.recipientEmail#</b>">
        </cfif>
        <cfset rtn &= " every time a bug report is received">
        <cfreturn rtn>
    </cffunction>
</cfcomponent>    
