component accessors="true" {

    property config;
    property extensionID;

    RuleTemplate function init(
        string severity = "",
        string application = "",
        string host = ""
    ) {
        // on buglog 1.8 rules were defined using severityCode instead of severity
        arguments.severity = structKeyExists(arguments,"severityCode") 
                            ? arguments.severityCode 
                            : arguments.severity;

        setConfig(duplicate(arguments));

        return this;
    }

}
