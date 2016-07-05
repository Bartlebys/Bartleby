//
//  Temp_main_test.swift
//  bartleby
//
//  Created by Benoit Pereira da silva on 12/05/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation



public enum GraphTestMode {
    case Chained
    case Flat
}



/**
 Creates a graph of tasks
 Test the group completion and count the discreets task executions
 This method is generative of priority variant and can perform random graph pause and resume.

 - parameter priority:       the group priority
 - parameter useRandomPause: use random pauses or not
 - parameter numberOfSequTask: quantity of tasks.
 */

public func graph_exec_completion_routine(priority: TasksGroup.Priority, useRandomPause: Bool, numberOfSequTask: Int, testMode: GraphTestMode) {


        Bartleby.sharedInstance.configureWith(BartlebyDefaultConfiguration.self)
        //Bartleby.startBufferingBprint()
        let document=BartlebyDocument()

        ShowSummary.randomPause=useRandomPause
        ShowSummary.executionCounter=0
        ShowSummary.startMeasuring()

        let rootObject=JObject()
        rootObject.summary="ROOT OBJECT"
        let firstTask=ShowSummary(arguments: rootObject)

        do {
            let group = try Bartleby.scheduler.getTaskGroupWithName(Bartleby.createUID(), inDocument:document)
            group.priority=priority
            try group.addTask(firstTask)
            print("Appending Completion Handler \(group.UID)")
            group.handlers.appendCompletionHandler({ (completion) in
                let runnableTaskCount=group.countTasks{ (task) -> Bool in
                    return task.status == Task.Status.Runnable
                }
                let completedTaskCount=group.countTasks{ (task) -> Bool in
                    return task.status == Task.Status.Completed
                }

                assert(runnableTaskCount==0, "All the task have been completed and the runnableTaskCount == 0 ")
                assert(completedTaskCount==numberOfSequTask+1, "Completed task completedTaskCount == \(numberOfSequTask+1) ")
                assert(ShowSummary.executionCounter==numberOfSequTask+1, "Execution counter should be consistent \(ShowSummary.executionCounter)")
                //Bartleby.stopBufferingBprint()
                bprint("FULLFILLING \(group.UID)", file:#file, function: #function, line: #line)
                let elapsed=ShowSummary.stopMeasuring()
                bprint("Elapsed time : \(elapsed)", file:#file, function: #function, line: #line)
                dispatch_async(GlobalQueue.Main.get(), {
                    exit(EX_OK)
                })

            })


            // Adding Child tasks
            for i in 1...numberOfSequTask {
                let o=JObject()
                o.summary="Object \(i)"
                let task=ShowSummary(arguments: o)
                switch testMode {
                case .Chained:
                    try group.appendChainedTask(task)
                case .Flat:
                    try group.addTask(task)
                }

            }
            try group.start()

        } catch {
            bprint("Error: \(error)", file:#file, function:#function, line:#line)
        }


}





// You Must Implement ConcreteTask to be invocable
public class ShowSummary: Task, ConcreteTask {

    public typealias ArgumentType=JObject

    public static var executionCounter=0
    public static var randomPause=false
    public static var randomPausePercentProbability: UInt32=1

    private static var _startTimer: CFAbsoluteTime=CFAbsoluteTimeGetCurrent()


    public static func startMeasuring() {
        _startTimer=CFAbsoluteTimeGetCurrent()
    }

    public static func stopMeasuring() -> CFAbsoluteTime {
        return CFAbsoluteTimeGetCurrent()-_startTimer
    }

    /**
     This initializer **MUST:** call configureWithArguments
     - parameter arguments: the arguments

     - returns: a well initialized task.
     */
    convenience required public init (arguments: ArgumentType) {
        self.init()
        self.configureWithArguments(arguments)
        if let s=arguments.summary {
            self.summary="ShowSummary \(s)" // For test purposes
        }
    }

    public static var counter: Int=0

    public override func invoke() {
            super.invoke()
            if let object: ArgumentType = try? self.arguments() {
                if let summary = object.summary {
                    ShowSummary.counter += 1
                    print("\(ShowSummary.counter)# \(summary)")
                } else {
                    print("NO SUMMARY \(object.UID)")
                }
            }

            // TEST random pauses and resumes
            if ShowSummary.randomPause==true {

                if ShowSummary.randomPausePercentProbability<0 {
                    ShowSummary.randomPausePercentProbability=1
                }

                let max: UInt32 = 100/ShowSummary.randomPausePercentProbability
                if Int(arc4random_uniform(max)) == 1 {
                    print("Pausing")
                    if let group: TasksGroup=self.group!.toLocalInstance() {
                        group.pause()
                    }
                    // Pause for 1 or 2 seconds
                    Bartleby.executeAfter(Double(arc4random_uniform(1)+1), closure: {
                        do {
                            print("Resuming")
                            if let group: TasksGroup=self.group!.toLocalInstance() {
                                try group.start()
                            }
                        } catch {
                            print("ERROR\(error)")
                        }
                    })
                }
            }
            ShowSummary.executionCounter += 1
            self.complete(Completion.successState())

    }
}
