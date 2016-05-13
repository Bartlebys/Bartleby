//
//  Temp_main_test.swift
//  bartleby
//
//  Created by Benoit Pereira da silva on 12/05/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation



public enum GraphTestMode {
    case Sequential
    case Concurrent
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

    TasksScheduler.DEBUG_TASKS=true
    let document=BartlebyDocument()

    ShowSummary.randomPause=useRandomPause
    ShowSummary.executionCounter=0
    ShowSummary.startMeasuring()

    let rootObject=JObject()
    rootObject.summary="ROOT OBJECT"
    let firstTask=ShowSummary(arguments: rootObject)

    do {
        let group = try Bartleby.scheduler.getTaskGroupWithName(Bartleby.createUID(), inDataSpace: document.spaceUID)
        group.priority=priority

        // This is the unique root task
        // So concurrency will be limited as we append sub tasks via appendSequentialTask
        try group.addConcurrentTask(firstTask)
        group.handlers.appendCompletionHandler({ (completion) in
            let taskCount=group.totalTaskCount()
            assert(taskCount==0, "All the task have been executed and the totalTaskCount == 0 ")
            assert(ShowSummary.executionCounter==numberOfSequTask+1, "Execution counter should be consistent \(ShowSummary.executionCounter)")
            Bartleby.stopBufferingBprint()
            print("FULLFILLING \(group.UID)")
            let elapsed=ShowSummary.stopMeasuring()
            print ("Elapsed time : \(elapsed)")

            exit(EX_OK)
        })


        // Adding Child tasks
        for i in 1...numberOfSequTask {
            let o=JObject()
            o.summary="Object \(i)"
            let task=ShowSummary(arguments: o)
            switch testMode {
                case .Sequential:
                    try firstTask.appendSequentialTask(task)
                case .Concurrent:
                    try group.addConcurrentTask(task)
            }

        }
        try group.start()

    } catch {
        print("\(error)")
    }
}





// You Must Implement ConcreteTask to be invocable
public class ShowSummary: ReactiveTask, ConcreteTask {

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

            // TEST random pauses and resumes
            if ShowSummary.randomPause==true {

                if ShowSummary.randomPausePercentProbability<0 {
                    ShowSummary.randomPausePercentProbability=1
                }

                let max: UInt32 = 100/ShowSummary.randomPausePercentProbability
                if Int(arc4random_uniform(max)) == 1 {
                    print("Pausing")
                    self.group?.toLocalInstance()?.pause()
                    // Pause for 1 or 2 seconds
                    Bartleby.executeAfter(Double(arc4random_uniform(1)+1), closure: {
                        do {
                            print("Resuming")
                            try self.group?.toLocalInstance()?.start()

                        } catch {
                            print("ERROR\(error)")
                        }
                    })
                }
            }


            ShowSummary.executionCounter += 1
            self.forward(Completion.successState())

        } catch {
            print("\(error)")
        }
    }
}
