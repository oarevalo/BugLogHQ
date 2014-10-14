component {
    
    variables.queue = 0;
    variables.maxQueueSize = 0;
    variables.instanceName = "";

    // initialize queue
    function init(
        required config config,
        required string instanceName
    ) {
        variables.queue = CreateObject("java","java.util.ArrayList").init();
        variables.maxQueueSize = arguments.config.getSetting("service.maxQueueSize");
        variables.instanceName = arguments.instanceName;
        return this;
    }

    // adds an item to the queue
    void function add(
        required rawEntryBean entryBean
    ) {
        lock name="#lockName()#" type="exclusive" timeout="10" {
            if(arrayLen(variables.queue) lte variables.maxQueueSize) {
                arrayAppend(variables.queue, arguments.entryBean);
            } else {
                throw(message="Queue full", type="buglog.queueFull");
            }
        }
    }

    // retrieves all elements on the queue and leaves it empty
    array function flush() {
        var items = [];
        lock name="#lockName()#" type="exclusive" timeout="10" {
            items = duplicate(variables.queue);
            variables.queue = CreateObject("java","java.util.ArrayList").Init()
        }
        return items;
    }

    // retrieves all elements on the queue without affecting them
    array function getAll() {
        return duplicate(variables.queue);
    }

    // generate a name for the exclusive lock used for reading and flushing a queue
    private string function lockName() {
        return "buglog_queue_#variables.instanceName#";
    }

}
