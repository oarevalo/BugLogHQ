component extends="bugLog.components.rules.Condition" accessors=true {

    // Condition based on checks made on a periodic basis. The match function
    // takes an array of Entry beans instead of a single bean.

    IntervalCondition function init() {
        setType("intervalCheck");
        return super.init();
    }

    boolean function match(
        required array Entries,
        required any Scope
    ) {
        return false;
    }

}
