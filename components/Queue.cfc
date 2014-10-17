interface {
    // The Queue interface describes the behavior of a queue used to store all
    // incoming messages. The queue is read and processed periocally. 

    // initialize queue
    function init(
        required config config,
        required string instanceName
    );

    // Adds an item to the queue
    // may throw "buglog.queueFull" exception if no item can be added
    // to the queue.
    void function add(
        required rawEntryBean entryBean
    );

    // Retrieves all elements on the queue and leaves it empty
    // Returns an array of rawEntryBean objects
    array function flush();

    // Retrieves all elements on the queue without affecting them
    // Returns an array of rawEntryBean objects
    array function getAll();

}
