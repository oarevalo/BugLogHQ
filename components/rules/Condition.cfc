component accessors=true {

    property type;

    Condition function init() {
        return this;
    }

    // checks if this rule is of the given type
    boolean function isType(
        required string conditionType
    ) {
        return !isNull(type) && type == conditionType;
    }

    /*
        Implement the logic for the condition. Should return true
        if the condition criteria is matched.

        When type is "messageCheck"...
            Condition based on checks made on a per-message basis. The match function
            takes an a single Entry bean. The match should be based on the contents of the
            given bean.

        When type is "intervalCheck"...
            Condition based on checks made on a periodic basis. The match function
            takes an array of Entry beans instead of a single bean.
    */
    boolean function match() {
        throw(message="NotImplemented (Condition.match)");
    }

}
