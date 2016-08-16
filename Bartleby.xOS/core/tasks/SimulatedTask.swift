//
//  SimulatedTask.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 16/08/2016.
//
//

import Foundation

#if os(OSX)
#elseif os(iOS)
#elseif os(watchOS)
#elseif os(tvOS)
#endif

/// This task produc
public class  SimulatedTask:Task, ConcreteTask {

    public typealias ArgumentType=JString

    // Universal type support
    override public class func typeName() -> String {
        return "SimulatedTask"
    }

    /**
     This initializer **MUST:** call configureWithArguments
     - parameter arguments: the arguments

     - returns: a well initialized task.
     */
    convenience required public init (arguments: ArgumentType) {
        self.init()
        self.configureWithArguments(arguments)
    }

    /**
     Proceed to a simulated action extraction.
     */
    override public func invoke() {
        super.invoke()
        if let name: ArgumentType = try? self.arguments() {

            // "Internal" Progressions of the task 1 to 20 steps
            let steps = arc4random_uniform(100)+1
            var d:UInt64 = 0 // 1 s / 1000
            var counter = 0
            for _ in 1 ... steps {
                // Add from 0 to 100 milliseconds delay between two progress
                d = d + UInt64(arc4random_uniform(100))
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(d * NSEC_PER_SEC / 1000 )), dispatch_get_main_queue(), {
                    counter += 1
                    let p =  Double(100) * Double(counter) / Double(steps)
                    let progression=Progression(currentTaskIndex:0, totalTaskCount:0, currentPercentProgress:p, message:"\(counter)", data:nil)
                    bprint(progression, file: #file, function: #function, line: #line, category: bprintCategoryFor(self))
                    self.transmit(progression)
                })
            }

            // Completion 1000 ms seconds after
            d = d + UInt64(1000)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(d * NSEC_PER_SEC / 1000 )), dispatch_get_main_queue(), {
                let completion=Completion.successState("\(name) completed", statusCode: StatusOfCompletion.OK, data: nil)
                bprint(completion, file: #file, function: #function, line: #line, category: bprintCategoryFor(self))
                self.complete(completion)
            })


        } else {

            let completion=Completion.failureState(NSLocalizedString( "Simulated Task Invocation argument type missmatch", tableName:"operations", comment:"Simulated Task Invocation argument type missmatch"), statusCode: StatusOfCompletion.Precondition_Failed)
            bprint(completion, file: #file, function: #function, line: #line, category: bprintCategoryFor(self))
            self.complete(completion)
        }
    }

}



