//: [Previous](@previous)

import Foundation
import Alamofire
import ObjectMapper
import BartlebyKit

// THIS PLAYGROUND IS CURRENTLY FAILING.
// BUT THE SAME CODE PASTED IN Bsync's main works perfectly.
// INVESTIGATION NEEDED

Bartleby.sharedInstance.configureWith(BartlebyDefaultConfiguration)
BartlebyDocument.addUniversalTypesForAliases()
let document=BartlebyDocument()
TasksScheduler.DEBUG_TASKS=true
Registry.USE_UNIVERSAL_TYPES=true

let SEPARATOR="----------------------"
var message="Definition of the ShowSummary Task"

var counter=0

SEPARATOR
message="Creation of the root Object & Task"

// You Must Implement ConcreteTask to be invocable
public class ShowSummary: AbstractReactiveTask, ConcreteTask {
    
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
        var message=""
        do {
            if let object: JObject = try self.arguments() as JObject {
                
                if let summary = object.summary {
                    ShowSummary.counter += 1
                    message="\(ShowSummary.counter)# \(summary)"
                    print(message)
                } else {
                    message="NO SUMMARY \(object.UID)"
                    print(message)
                }
            }
            self.forward(Completion.successState())
        } catch let e {
            message="ERROR \(e)"
            print(message)
        }
    }
}



let rootObject=JObject()
rootObject.summary="ROOT OBJECT"
let firstTask=ShowSummary(arguments: rootObject)

do {
    message="Tasks create task Group"
    print(message)
    let group = try Bartleby.scheduler.createTaskGroupFor(firstTask, groupedBy:"MyPlayGroundTasks", inDataSpace: document.spaceUID)
    message="Adding Child tasks"
    print(message)
    for i in 1...10 {
        let o=JObject()
        o.summary="Object \(i)"
        let task=ShowSummary(arguments: o)
        try firstTask.appendSequentialTask(task)
    }
    
    let rootTaskCounter=group.tasks.count
    message="Number of first level tasks = \(rootTaskCounter)"
    print(message)
    print(SEPARATOR)
    Registry.USE_UNIVERSAL_TYPES=true
    let use=Registry.USE_UNIVERSAL_TYPES
    
    try group.start()
    SEPARATOR
    message="Check the console result"
    SEPARATOR
    print(SEPARATOR)
    message="Number of first level tasks = \(group.tasks.count)"
    print(message)
    
} catch {
    message="ERROR \(error)"
    print(message)
}
SEPARATOR
message="Check the console result"

//: [Next page](@next)
