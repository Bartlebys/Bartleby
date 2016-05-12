//
//  TasksGroupBasicTests.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 12/05/2016.
//
//

import XCTest
import BartlebyKit

// You Must Implement ConcreteTask to be invocable
public class ShowSummary: ReactiveTask, ConcreteTask {

    public static var executionCounter=0
    public static var randomPause=false
    public static let ENABLE_RANDOM_PAUSE=false
    public static let smallGraphSize=5
    public static let largeGraphSize=100

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
            if ShowSummary.randomPause==true && ShowSummary.ENABLE_RANDOM_PAUSE {
                if Int(arc4random_uniform(2))==1 {
                    print("Pausing")
                    self.group?.toLocalInstance()?.pause()
                    Bartleby.executeAfter(1, closure: {
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



class TasksGroupCompletionPriorityAndPausesTests: XCTestCase {

    override static func setUp() {
        super.setUp()
        Registry.declareCollectibleType(ShowSummary)
        Registry.declareCollectibleType(Alias<ShowSummary>)
        Bartleby.sharedInstance.hardCoreCleanupForUnitTests()
    }

    override func tearDown() {
        super.tearDown()

        ShowSummary.randomPause=false
        ShowSummary.executionCounter=0

    }

    func test_001_graph_exec_completion_Background() {
        _graph_exec_completion_routine(TasksGroup.Priority.Background, useRandomPause: false, numberOfSequTask:ShowSummary.smallGraphSize)
    }

    func test_002_graph_exec_completion_Low() {
        _graph_exec_completion_routine(TasksGroup.Priority.Low, useRandomPause: false, numberOfSequTask:ShowSummary.smallGraphSize)
    }

    func test_003_graph_exec_completion_Default() {
        _graph_exec_completion_routine(TasksGroup.Priority.Default, useRandomPause: false, numberOfSequTask:ShowSummary.smallGraphSize)
    }


    func test_004_graph_exec_completion_High() {
        _graph_exec_completion_routine(TasksGroup.Priority.High, useRandomPause: false, numberOfSequTask:ShowSummary.smallGraphSize)
    }

    func test_005_graph_exec_completion_pausable_Background() {
        _graph_exec_completion_routine(TasksGroup.Priority.Background, useRandomPause: true, numberOfSequTask:ShowSummary.smallGraphSize)
    }

    func test_006_graph_exec_completion_pausable_Low() {
        _graph_exec_completion_routine(TasksGroup.Priority.Low, useRandomPause: true, numberOfSequTask:ShowSummary.smallGraphSize)
    }
    func test_007_graph_exec_completion_pausable_Default() {
        _graph_exec_completion_routine(TasksGroup.Priority.Default, useRandomPause: true, numberOfSequTask:ShowSummary.smallGraphSize)
    }

    func test_008_graph_exec_completion_pausable_High() {
        _graph_exec_completion_routine(TasksGroup.Priority.High, useRandomPause: true, numberOfSequTask:ShowSummary.smallGraphSize)
    }

    // Quantity

    func test_009_graph_exec_completion_Background_large() {
        _graph_exec_completion_routine(TasksGroup.Priority.Background, useRandomPause: false, numberOfSequTask:ShowSummary.largeGraphSize)
    }

    func test_010_graph_exec_completion_Low_large() {
        _graph_exec_completion_routine(TasksGroup.Priority.Low, useRandomPause: false, numberOfSequTask:ShowSummary.largeGraphSize)
    }

    func test_011_graph_exec_completion_Default_large() {
        _graph_exec_completion_routine(TasksGroup.Priority.Default, useRandomPause: false, numberOfSequTask:ShowSummary.largeGraphSize)
    }
    func test_012_graph_exec_completion_High_large() {
        _graph_exec_completion_routine(TasksGroup.Priority.High, useRandomPause: false, numberOfSequTask:ShowSummary.largeGraphSize)
    }



    /**
     Creates a graph of tasks
     Test the group completion and count the discreets task executions
     This method is generative of priority variant and can perform random graph pause and resume.

     - parameter priority:       the group priority
     - parameter useRandomPause: use random pauses or not
     - parameter numberOfSequTask: quantity of tasks.
     */
    private func _graph_exec_completion_routine(priority: TasksGroup.Priority, useRandomPause: Bool, numberOfSequTask: Int) {
        let expectation = expectationWithDescription("Post execution is clean \(priority) \(useRandomPause)")

        let rootObject=JObject()
        rootObject.summary="ROOT OBJECT"
        let firstTask=ShowSummary(arguments: rootObject)
        let document=BartlebyDocument()

        ShowSummary.randomPause=useRandomPause
        ShowSummary.executionCounter=0

        do {
            let group = try Bartleby.scheduler.getTaskGroupWithName(Bartleby.createUID(), inDataSpace: document.spaceUID)
            group.priority=priority

            // This is the unique root task
            // So concurrency will be limited as we append sub tasks via appendSequentialTask
            try group.addConcurrentTask(firstTask)
            group.handlers.appendCompletionHandler({ (completion) in
                    let taskCount=group.totalTaskCount()
                    XCTAssert(taskCount==0, "All the task have been executed and the totalTaskCount == 0 ")
                    XCTAssert(ShowSummary.executionCounter==numberOfSequTask+1, "Execution counter should be consistent \(ShowSummary.executionCounter)")
                    print("FULLFILLING \(group.UID)")
                    expectation.fulfill()
                })


            // Adding Child tasks
            for i in 1...numberOfSequTask {
                let o=JObject()
                o.summary="Object \(i)"
                let task=ShowSummary(arguments: o)
                try firstTask.appendSequentialTask(task)
            }
            try group.start()

        } catch {
            XCTFail("\(error)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.LONG_TIME_OUT_DURATION) { error -> Void in
            if let error = error {
                bprint("Error: \(error.localizedDescription)")
            }
        }
    }


}
