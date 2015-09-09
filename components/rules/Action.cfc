component accessors="true" {

    Action function init() {
        return this;
    }
    
    boolean function do(
        required bugLog.components.entry entry
    ) {
        throw(message="NotImplemented (Action.do)");
    }

    boolean function doBatch(
        required array entries
    ) {
        throw(message="NotImplemented (Action.doBatch)");
    }
}
