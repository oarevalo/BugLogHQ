component extends="bugLog.components.rules.Condition" accessors=true {

    property keywords;

    any function init(
        required string keywords
    ) {
        setType("messageCheck");
        setKeywords(keywords);
        return super.init();
    }

    boolean function match(
        required any Entry,
        required any Scope
    ) {
        var stEntry = entry.getMemento();
        var matches = !(arrayLen(listToArray(keywords)) > 0);

        for(var keyword in listToArray(keywords)) {
            matches = matches || findNoCase(keyword, stEntry.message);
        }

        return matches;
    }

}
