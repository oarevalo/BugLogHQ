component accessors=true {

    property dao;

    // constructor
    Logger function init() {
        return this;
    }

    // logs a firing of a rule
    void function matched(
        required any rule,
        required any arg
    ) {
        var entryID = isArray(arg) ? 0 : arg.getID();
        dao.save(
            extensionID = rule.getID(), 
            entryID = entryID,
            createdOn = now()
        );
    }

    // return an array of ruleIDs that have matched a given entry
    array function getMatchedRuleIDs(
        required any entry
    ) {
        var qryTriggers = getMatchedRules( entry );
        return listToArray( valueList( qryTriggers.extensionID ) );
    }

    // return a query with rules that have matched a given entry
    query function getMatchedRules(
        required any entry
    ) {
        return dao.getTriggers( entry.getID() );
    }

}
