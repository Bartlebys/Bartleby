//
//  TasksGroupBasicTests.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 12/05/2016.
//
//

import XCTest
import BartlebyKit



public enum GraphTestMode {
    case Chained
    case Flat
}


// You Must Implement ConcreteTask to be invocable
public class ShowSummary: Task, ConcreteTask {


    public typealias ArgumentType=JObject

    public static var executionCounter=0
    public static var randomPause=false
    public static var randomPausePercentProbability: UInt32=1

    public static let smallGraphSize=9
    public static let largeGraphSize=99


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
            if let object: JObject = try? self.arguments() as JObject {
                if let summary = object.summary {
                    ShowSummary.counter += 1
                    bprint("\(ShowSummary.counter)# \(summary)", file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                } else {
                    bprint("NO SUMMARY \(object.UID)", file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                }
            }

            // TEST random pauses and resumes
            if ShowSummary.randomPause==true {

                if ShowSummary.randomPausePercentProbability<0 {
                    ShowSummary.randomPausePercentProbability=1
                }

                let max: UInt32 = 100/ShowSummary.randomPausePercentProbability
                if Int(arc4random_uniform(max)) == 1 {
                    bprint("Pausing", file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                    if let groupRef: ExternalReference=self.group {
                        if let realGroup: TasksGroup = groupRef.toLocalInstance() {
                            realGroup.pause()
                        }
                    }

                    // Pause for 1 or 2 seconds
                    Bartleby.executeAfter(Double(arc4random_uniform(1)+1), closure: {
                        do {
                            bprint("Resuming", file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                            if let group: TasksGroup=self.group!.toLocalInstance() {
                                try group.start()
                            }
                        } catch {
                            bprint("ERROR\(error)", file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                        }
                    })

                }

            }


            ShowSummary.executionCounter += 1
            self.complete(Completion.successState())
    }
}

class TasksGroupCompletionPriorityAndPausesTests: XCTestCase {


    override static func setUp() {
        super.setUp()
       // Bartleby.sharedInstance.hardCoreCleanupForUnitTests()
    }

    override static func tearDown() {
        super.tearDown()
        /*
        Bartleby.dumpBprintEntries({ (entry) -> Bool in
             return entry.category==TasksScheduler.BPRINT_CATEGORY
            }, fileName: "TaskScheduler entries")
 */
    }




    func test_001_graph_exec_completion_Background() {
        _graph_exec_completion_routine(TasksGroup.Priority.Background, useRandomPause: false, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Flat)
    }

    func test_002_graph_exec_completion_Low() {
        _graph_exec_completion_routine(TasksGroup.Priority.Low, useRandomPause: false, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Flat)
    }

    func test_003_graph_exec_completion_Default() {
        _graph_exec_completion_routine(TasksGroup.Priority.Default, useRandomPause: false, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Flat)
    }


    func test_004_graph_exec_completion_High() {
        _graph_exec_completion_routine(TasksGroup.Priority.High, useRandomPause: false, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Flat)
    }

    func test_005_graph_exec_completion_pausable_Background() {
        _graph_exec_completion_routine(TasksGroup.Priority.Background, useRandomPause: true, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Flat)
    }

    func test_006_graph_exec_completion_pausable_Low() {
        _graph_exec_completion_routine(TasksGroup.Priority.Low, useRandomPause: true, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Flat)
    }
    func test_007_graph_exec_completion_pausable_Default() {
        _graph_exec_completion_routine(TasksGroup.Priority.Default, useRandomPause: true, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Flat)
    }

    func test_008_graph_exec_completion_pausable_High() {
        _graph_exec_completion_routine(TasksGroup.Priority.High, useRandomPause: true, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Flat)
    }

    // Quantity

    func test_009_graph_exec_completion_Background_large() {
        _graph_exec_completion_routine(TasksGroup.Priority.Background, useRandomPause: false, numberOfSequTask:ShowSummary.largeGraphSize, testMode:GraphTestMode.Flat)
    }

    func test_010_graph_exec_completion_Low_large() {
        _graph_exec_completion_routine(TasksGroup.Priority.Low, useRandomPause: false, numberOfSequTask:ShowSummary.largeGraphSize, testMode:GraphTestMode.Flat)
    }

    func test_011_graph_exec_completion_Default_large() {
        _graph_exec_completion_routine(TasksGroup.Priority.Default, useRandomPause: false, numberOfSequTask:ShowSummary.largeGraphSize, testMode:GraphTestMode.Flat)
    }
    func test_012_graph_exec_completion_High_large() {
        _graph_exec_completion_routine(TasksGroup.Priority.High, useRandomPause: false, numberOfSequTask:ShowSummary.largeGraphSize, testMode:GraphTestMode.Flat)
    }

    func test_013_graph_exec_completion_Background() {
        _graph_exec_completion_routine(TasksGroup.Priority.Background, useRandomPause: false, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Flat)
    }

    func test_014_graph_exec_completion_Chained_Low() {
        _graph_exec_completion_routine(TasksGroup.Priority.Low, useRandomPause: false, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Chained)
    }

    func test_015_graph_exec_completion_Chained_Default() {
        _graph_exec_completion_routine(TasksGroup.Priority.Default, useRandomPause: false, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Chained)
    }

    func test_016_graph_exec_completion_Chained_High() {
        _graph_exec_completion_routine(TasksGroup.Priority.High, useRandomPause: false, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Chained)
    }

    func test_017_graph_exec_completion_pausable_Chained_Background() {
        _graph_exec_completion_routine(TasksGroup.Priority.Background, useRandomPause: true, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Chained)
    }

    func test_018_graph_exec_completion_pausable_Chained_Low() {
        _graph_exec_completion_routine(TasksGroup.Priority.Low, useRandomPause: true, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Chained)
    }
    func test_019_graph_exec_completion_pausable_Chained_Default() {
        _graph_exec_completion_routine(TasksGroup.Priority.Default, useRandomPause: true, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Chained)
    }

    func test_020_graph_exec_completion_pausable_Chained_High() {
        _graph_exec_completion_routine(TasksGroup.Priority.High, useRandomPause: true, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Chained)
    }

    // Quantity

    func test_021_graph_exec_completion_Background_Chained_large() {
        _graph_exec_completion_routine(TasksGroup.Priority.Background, useRandomPause: false, numberOfSequTask:ShowSummary.largeGraphSize, testMode:GraphTestMode.Chained)
    }

    func test_022_graph_exec_completion_Low__Chained_large() {
        _graph_exec_completion_routine(TasksGroup.Priority.Low, useRandomPause: false, numberOfSequTask:ShowSummary.largeGraphSize, testMode:GraphTestMode.Chained)
    }

    func test_023_graph_exec_completion_Default_Chained_large() {
        _graph_exec_completion_routine(TasksGroup.Priority.Default, useRandomPause: false, numberOfSequTask:ShowSummary.largeGraphSize, testMode:GraphTestMode.Chained)
    }
    func test_024_graph_exec_completion_High_Chained_large() {
        _graph_exec_completion_routine(TasksGroup.Priority.High, useRandomPause: false, numberOfSequTask:ShowSummary.largeGraphSize, testMode:GraphTestMode.Chained)
    }




    /**
     Creates a graph of tasks
     Test the group completion and count the discreets task executions
     This method is generative of priority variant and can perform random graph pause and resume.

     - parameter priority:       the group priority
     - parameter useRandomPause: use random pauses or not
     - parameter numberOfSequTask: quantity of tasks.
     */

    private func _graph_exec_completion_routine(priority: TasksGroup.Priority, useRandomPause: Bool, numberOfSequTask: Int, testMode: GraphTestMode) {


            let expectation: XCTestExpectation = self.expectationWithDescription("Post execution is clean \(priority) \(useRandomPause) \(numberOfSequTask) \(testMode)")
            Bartleby.sharedInstance.configureWith(BartlebyDefaultConfiguration.self)

            let document=BartlebyDocument()

            ShowSummary.randomPause=useRandomPause
            ShowSummary.executionCounter=0
            ShowSummary.startMeasuring()

            let rootObject=JObject()
            rootObject.summary="ROOT OBJECT"
            let firstTask=ShowSummary(arguments: rootObject)

            do {
                let group = try Bartleby.scheduler.getTaskGroupWithName(Bartleby.createUID(), inDocument: document)
                group.priority=priority

                // This is the unique root task
                // So concurrency will be limited as we append sub tasks via appendChainedTask
                try group.addTask(firstTask)
                group.handlers.appendCompletionHandler({ (completion) in
                    let taskCount=group.totalTaskCount()
                        XCTAssert(taskCount==0, "All the task have been executed and the totalTaskCount == 0 ")
                        XCTAssert(ShowSummary.executionCounter==numberOfSequTask, "Execution counter should be consistent \(ShowSummary.executionCounter)")

                        bprint("\n\nFULLFILLING \(group.UID)", file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                        let elapsed=ShowSummary.stopMeasuring()
                        bprint("Elapsed time : \(elapsed)", file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                        expectation.fulfill()
                        bprint("-------------------------\n", file: #file, function: #function, line: #line, category: TasksScheduler.BPRINT_CATEGORY)
                })


                // Adding Child tasks
                for i in 1...numberOfSequTask-1 {
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
                print("\(error)")
            }



        waitForExpectationsWithTimeout(3600, handler: nil)
    }
}
