component extends="bugLog.components.rules.Action" accessors=true {

    property senderEmail;
    property recipientEmail;
    property includeHTMLReport;
    property messageText;
    property mailerService;

    any function init(
        required string senderEmail,
        required string recipientEmail,
        required boolean includeHTMLReport,
        required string messageText
    ) {
        setSenderEmail(senderEmail);
        setRecipientEmail(recipientEmail);
        setIncludeHTMLReport(includeHTMLReport);
        setMessageText(messageText);
        return super.init();
    }

    boolean function do(
        required bugLog.components.entry entry
    ) {
        var subject = "BugLogHQ: " & entry.getMessage();
        mailerService.send(
                from = senderEmail, 
                to = recipientEmail,
                subject = subject,
                body = messageText,
                type = "html"
            );
        return true;
    }

}
