
import XCPlayground

//: [Previous](@previous)

import Foundation
import Alamofire
import ObjectMapper
import BartlebyKit

Bartleby.sharedInstance.configureWith(BartlebyDefaultConfiguration)
let document=BartlebyDocument() // We need a DataSpace
TasksScheduler.DEBUG_TASKS=true

let SEPARATOR="----------------------"
print(SEPARATOR)
print("Definition of the ShowSummary Task")

var counter=0

print(SEPARATOR)
print("Creation of the root Object & Task")

// You Must Implement ConcreteTask to be invocable
public class ShowSummary: ReactiveTask, ConcreteTask {

    /**
     This initializer **MUST:** call configureWithArguments
     - parameter arguments: the arguments

     - returns: a well initialized task.
     */
    convenience required public init (arguments: Collectible) {
        self.init()
        self.configureWithArguments(arguments)
        if let s=arguments.summary {
            self.summary="ShowSummary \(s)" // For test purposes
        }
    }

    public static var counter: Int=0

    public func invoke() {
        do {
            if let object: JObject = try self.arguments() as JObject {
                if let summary = object.summary {
                    ShowSummary.counter += 1
                    print("\(ShowSummary.counter)# \(summary)")
                } else {
                    print("NO SUMMARY \(object.UID)")
                }
            }
            self.forward(Completion.successState())
        } catch let e {
            print("ERROR \(e)")
        }
    }
}

Registry.declareCollectibleType(ShowSummary)
Registry.declareCollectibleType(Alias<ShowSummary>)


let rootObject=JObject()
rootObject.summary="ROOT OBJECT"
let firstTask=ShowSummary(arguments: rootObject)


do {
    print("Tasks create task Group")

    let group = try Bartleby.scheduler.getTaskGroupWithName("MyPlayGroundTasks", inDataSpace: document.spaceUID)
    // This is the unique root task
    // So concurrency will be limited as we append sub tasks via appendSequentialTask
    try group.addConcurrentTask(firstTask)
    group.handlers.appendCompletionHandler({ (completion) in
        print("*****")
    })
    
    print("Adding Child tasks")
    for i in 1...5 {
        let o=JObject()
        o.summary="Object \(i)"
        let task=ShowSummary(arguments: o)
        try firstTask.appendSequentialTask(task)
    }

    let rootTaskCounter=group.tasks.count
    print("Number of first level tasks = \(rootTaskCounter)")
    print(SEPARATOR)
    try group.start()
    print("Number of first level tasks = \(group.tasks.count)")

} catch {
    print("ERROR \(error)")
}
print(SEPARATOR)


print("Check the console result")


XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
Bartleby.executeAfter(10) {
    XCPlaygroundPage.currentPage.finishExecution()
}

//: [Next page](@next)
