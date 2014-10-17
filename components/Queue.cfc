interface {
    // The Queue interface describes the behavior of a queue used to store all
    // incoming messages. The queue is read and processed periocally. 

    // initialize queue
    function init(
        required config config,
        required string instanceName
    );

    // adds an item to the queue
    void function add(
        required rawEntryBean entryBean
    );

    // retrieves all elements on the queue and leaves it empty
    array function flush();

    // retrieves all elements on the queue without affecting them
    array function getAll();

}
