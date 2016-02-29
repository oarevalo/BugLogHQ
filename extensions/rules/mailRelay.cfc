component extends="bugLog.components.baseRule" 
            hint="This rule sends an email everytime a bug is received" {

    property name="recipientEmail" buglogType="email" displayName="Recipient Email" type="string" hint="The email address to which to send the notifications";
    property name="includeHTMLReport" type="boolean" displayName="Include HTML Report?" hint="When enabled, the HTML Report section of the bug report is included in the email body";

    public bugLog.components.rules.Rule function init(
        required string recipientEmail,
        string includeHTMLReport = ""
    ) {
        arguments.includeHTMLReport = (isBoolean(arguments.includeHTMLReport) && arguments.includeHTMLReport);
        super.init(argumentCollection = arguments);
        return build();
    }

    public bugLog.components.rules.Rule function buildRule() {
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
    }

    public string function explain() {
        var rtn = "Sends an alert ";
        if(len(variables.config.recipientEmail)) {
            rtn &= " to <b>#variables.config.recipientEmail#</b>";
        }
        rtn &= " every time a bug report is received";
        return rtn;
    }

}   
