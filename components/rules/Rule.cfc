component accessors=true {

    property scope;
    property actions;
    property id;

    Rule function init(
        required numeric id
    ) {
        setID( id );
        return this;
    }

    struct function process(
        any payload = 0
    ) {
        var rtn = {
            matched = false,
            next = true
        };

        // evaluate scope
        var rtn.matched = scope.match(payload);

        // if scope matches, then execute actions
        if(rtn.matched) {
            for(var action in actions) {
                rtn.next = rtn.next && action.do(payload);
            }
        }

        return rtn;
    }

    // checks that the rule is completely defined
    boolean function isValid() {
        return !isNull(scope) && !isNull(actions);
    }

    // adds an action to be processed if the rule fires
    void function addAction(
        required Action action
    ) {
        if(isNull(actions)) actions = [];
        arrayAppend(actions, action);
    }

    // checks the evaluation type of the scope
    boolean function appliesTo(
        required string type
    ) {
        return scope.matchEvalType(arguments.type);
    }

}
