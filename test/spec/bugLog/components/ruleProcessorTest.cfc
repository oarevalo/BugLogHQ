component extends="testbox.system.BaseSpec" {

    function testCreateObject() {
        var o = new bugLog.components.ruleProcessor();
    }

    function testAddRule() {
        var o = new bugLog.components.ruleProcessor();
        $assert.isEmpty(o.getRules(), "should have 0 rules");

        // add a complete rule
        var o = new bugLog.components.ruleProcessor();
        var r = new bugLog.components.rules.Rule(1);       
        o.addRule(r);
        $assert.isEqual(1, arrayLen(o.getRules()), "should have 1 rule");
    }

    function testProcessRules() {
        var o = new bugLog.components.ruleProcessor();

        // create a mock logger
        var l = createMock("bugLog.components.rules.Logger")
                    .$("matched")
                    .$("getMatchedRuleIDs",[]);
        o.setLogger(l);

        // create a rule
        var r = new bugLog.components.rules.Rule(1);
        r.setScope( new bugLog.components.rules.Scope() );
        r.setActions( [] );

        // add a rule and verify it was added
        o.addRule( r );
        $assert.isEqual(1, arrayLen(o.getRules()), "should have 1 rule");

        // process no entries
        var entries = [];
        o.processRules(entries);

        // process multiple entries
        var num = 5;
        var entries = [];
        for(var i=1; i <= num; i++) {
            entries.add(
                createMock("bugLog.components.entry")
                    .$("save")
                    .$("setIsProcessed")
            );
        }
        o.processRules(entries);
        for(var i=1; i <= num; i++) {
            $assert.isTrue( 
                entries[1].$once("setIsProcessed"), 
                "setIsProcessed not called in entry #i#"
            );
        }
    }

    function testFlushRules() {
        var o = new bugLog.components.ruleProcessor();
        $assert.isEmpty(o.getRules(), "should have 0 rules");
        o.addRule( new bugLog.components.rules.Rule(1) );
        o.addRule( new bugLog.components.rules.Rule(2) );
        o.addRule( new bugLog.components.rules.Rule(3) );
        $assert.isEqual(3, arrayLen(o.getRules()), "should have 3 rules");
        o.flushRules();
        $assert.isEmpty(o.getRules(), "should have 0 rules");
    }

}
