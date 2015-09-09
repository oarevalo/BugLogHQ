component {

    // the scope identifies the major properties for which a rule applies (application/host/severity)
    variables.scope = {};
    variables.scope_text = {};

    variables.ID_NOT_SET = -9999999;
    variables.ID_NOT_FOUND = -9999990;
    variables.SCOPE_KEYS = ["application","host","severity"];
    variables.SCOPE_TEXT_KEYS = ["message","searchTerm","userAgent","templatePath"];
    variables.EVAL_TYPE = "message";

    Scope function init() {
        for(var key in variables.SCOPE_KEYS) {
            if(structKeyExists(arguments, key)) { 
                var cfg = trim(arguments[key]);
                if(!len(cfg))
                    continue;
                scope[key] = {
                    not_in = false,
                    items = {}
                };
                if( left(cfg,1) == "-" ) {
                    cfg = trim(removechars(cfg,1,1));
                    scope[key]["not_in"] = true;
                }
                for(var item in listToArray(cfg)) {
                    scope[key]["items"][trim(item)] = variables.ID_NOT_SET;
                }
            }
        }

        for(var key in variables.SCOPE_TEXT_KEYS) {
            if(structKeyExists(arguments, key)) { 
                var cfg = trim(arguments[key]);
                if(!len(cfg))
                    continue;
                scope_text[key] = {
                    not_in = false,
                    text = ""
                };
                if( left(cfg,1) == "-" ) {
                    cfg = trim(removechars(cfg,1,1));
                    scope_text[key]["not_in"] = true;
                }
                scope_text[key]["text"] = cfg;
            }            
        }

        return this;        
    }

    // Returns true if this scope is of the given evaluation type 
    boolean function matchEvalType(
        required string type
    ) {
        return (variables.EVAL_TYPE == type);
    }

    // Returns true if the entry bean matches the defined scope
    boolean function match(
        required any entry
    ) {
        var matches = true;
        var memento = entry.getMemento();

        // ensure that all values in the scope are parsed into IDs
        update();

        // match against ID-based fields
        for(var key in structKeyArray(scope)) {
            var matchesLine = scope[key]["not_in"];
            for(var item in scope[key]["items"]) {
                var id = scope[key]["items"][item];
                if(scope[key]["not_in"]) {
                    matchesLine = matchesLine && memento[key & "ID"] != id;
                } else {
                    matchesLine = matchesLine || memento[key & "ID"] == id;
                }
            }
            matches = matches && matchesLine;
        }

        // match against text properties
        for(var key in structKeyArray(scope_text)) {
            var matchesLine = scope_text[key]["not_in"];
            var txt = scope_text[key]["text"];
            var in_text = (key == "searchTerm") 
                        ?  (memento.message & ":" & memento.exceptionMessage & ":" 
                            & memento.exceptionDetails & ":" & memento.templatePath & ":" 
                            & memento.userAgent & ":" & memento.htmlReport)
                        : memento[key];
            if(scope_text[key]["not_in"]) {
                matchesLine = matchesLine && !findNoCase(txt, in_text);
            } else {
                matchesLine = matchesLine || findNoCase(txt, in_text);
            }
            matches = matches && matchesLine;
        }

        return matches;
    }

    // convert to search args
    struct function toSearchArgs() {
        var args = {};
        for(var key in structKeyArray(scope)) {
            var ids = [];
            for(var item in scope[key]["items"]) {
                ids.add( scope[key]["items"][item] );
            }
            if(arrayLen(ids)) {
                args[key & "id"] = (scope[key]["not_in"] ? "-" : "") & listToArray(ids);
            }
        }
        for(var key in structKeyArray(scope_text)) {
            var txt = scope_text[key]["text"];
            if(len(txt)) {
                args[key] = (scope_text[key]["not_in"] ? "-" : "") & txt;
            }
        }        
        return args;
    }

    // update the scope with the correct object id's if available
    // call this before trying to match the scope
    public void function update() {
        for(var key in structKeyArray(scope)) {
            var items = scope[key]["items"];
            for(var item in items) {
                if(items[item] == ID_NOT_SET || items[item] == ID_NOT_FOUND) {
                    switch(key) {
                        case "application":
                            items[item] = getApplicationID();
                            break;
                        case "severity":
                            items[item] = getHostID();
                            break;
                        case "host":
                            items[item] = getSeverityID();
                            break;
                    }
                }
            }
        }        
    }    


    /*** Private Methods ***/

    private numeric function getApplicationID(
        required string name
    ) {
        var oDAO = getDAOFactory().getDAO("application");
        var oFinder = createObject("component","bugLog.components.appFinder").init(oDAO);
        try {
            return oFinder.findByCode(name).getApplicationID();
        } catch(appFinderException.ApplicationCodeNotFound e) {
            return variables.ID_NOT_FOUND;
        }
    }

    private numeric function getHostID(
        required string name
    ) {
        var oDAO = getDAOFactory().getDAO("host");
        var oFinder = createObject("component","bugLog.components.hostFinder").init(oDAO);
        try {
            return oFinder.findByName(name).getHostID();
        } catch(hostFinderException.HostNameNotFound e) {
            return variables.ID_NOT_FOUND;
        }
    }

    private numeric function getSeverityID(
        required string name
    ) {
        var oDAO = getDAOFactory().getDAO("severity");
        var oFinder = createObject("component","bugLog.components.severityFinder").init(oDAO);
        try {
            return oFinder.findByCode(name).getSeverityID();
        } catch(severityFinderException.codeNotFound e) {
            return variables.ID_NOT_FOUND;
        }
    }

}
