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
    case Sequential
    case Concurrent
}

// !!! @bpds  Sequential MUST Work
let PseudoSequential=GraphTestMode.Concurrent


// You Must Implement ConcreteTask to be invocable
public class ShowSummary: ReactiveTask, ConcreteTask {

    public static var executionCounter=0
    public static var randomPause=false
    public static var randomPausePercentProbability: UInt32=1

    public static let smallGraphSize=10
    public static let largeGraphSize=1000



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
        _graph_exec_completion_routine(TasksGroup.Priority.Background, useRandomPause: false, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Concurrent)
    }

    func test_002_graph_exec_completion_Low() {
        _graph_exec_completion_routine(TasksGroup.Priority.Low, useRandomPause: false, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Concurrent)
    }

    func test_003_graph_exec_completion_Default() {
        _graph_exec_completion_routine(TasksGroup.Priority.Default, useRandomPause: false, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Concurrent)
    }


    func test_004_graph_exec_completion_High() {
        _graph_exec_completion_routine(TasksGroup.Priority.High, useRandomPause: false, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Concurrent)
    }

    func test_005_graph_exec_completion_pausable_Background() {
        _graph_exec_completion_routine(TasksGroup.Priority.Background, useRandomPause: true, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Concurrent)
    }

    func test_006_graph_exec_completion_pausable_Low() {
        _graph_exec_completion_routine(TasksGroup.Priority.Low, useRandomPause: true, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Concurrent)
    }
    func test_007_graph_exec_completion_pausable_Default() {
        _graph_exec_completion_routine(TasksGroup.Priority.Default, useRandomPause: true, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Concurrent)
    }

    func test_008_graph_exec_completion_pausable_High() {
        _graph_exec_completion_routine(TasksGroup.Priority.High, useRandomPause: true, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Concurrent)
    }

    // Quantity

    func test_009_graph_exec_completion_Background_large() {
        _graph_exec_completion_routine(TasksGroup.Priority.Background, useRandomPause: false, numberOfSequTask:ShowSummary.largeGraphSize, testMode:GraphTestMode.Concurrent)
    }

    func test_010_graph_exec_completion_Low_large() {
        _graph_exec_completion_routine(TasksGroup.Priority.Low, useRandomPause: false, numberOfSequTask:ShowSummary.largeGraphSize, testMode:GraphTestMode.Concurrent)
    }

    func test_011_graph_exec_completion_Default_large() {
        _graph_exec_completion_routine(TasksGroup.Priority.Default, useRandomPause: false, numberOfSequTask:ShowSummary.largeGraphSize, testMode:GraphTestMode.Concurrent)
    }
    func test_012_graph_exec_completion_High_large() {
        _graph_exec_completion_routine(TasksGroup.Priority.High, useRandomPause: false, numberOfSequTask:ShowSummary.largeGraphSize, testMode:GraphTestMode.Concurrent)
    }

    func test_013_graph_exec_completion_Background() {
        _graph_exec_completion_routine(TasksGroup.Priority.Background, useRandomPause: false, numberOfSequTask:ShowSummary.smallGraphSize, testMode:GraphTestMode.Concurrent)
    }

    func test_014_graph_exec_completion_Low() {
        _graph_exec_completion_routine(TasksGroup.Priority.Low, useRandomPause: false, numberOfSequTask:ShowSummary.smallGraphSize, testMode:PseudoSequential)
    }

    func test_015_graph_exec_completion_Default() {
        _graph_exec_completion_routine(TasksGroup.Priority.Default, useRandomPause: false, numberOfSequTask:ShowSummary.smallGraphSize, testMode:PseudoSequential)
    }

    func test_016_graph_exec_completion_High() {
        _graph_exec_completion_routine(TasksGroup.Priority.High, useRandomPause: false, numberOfSequTask:ShowSummary.smallGraphSize, testMode:PseudoSequential)
    }

    func test_017_graph_exec_completion_pausable_Background() {
        _graph_exec_completion_routine(TasksGroup.Priority.Background, useRandomPause: true, numberOfSequTask:ShowSummary.smallGraphSize, testMode:PseudoSequential)
    }

    func test_018_graph_exec_completion_pausable_Low() {
        _graph_exec_completion_routine(TasksGroup.Priority.Low, useRandomPause: true, numberOfSequTask:ShowSummary.smallGraphSize, testMode:PseudoSequential)
    }
    func test_019_graph_exec_completion_pausable_Default() {
        _graph_exec_completion_routine(TasksGroup.Priority.Default, useRandomPause: true, numberOfSequTask:ShowSummary.smallGraphSize, testMode:PseudoSequential)
    }

    func test_020_graph_exec_completion_pausable_High() {
        _graph_exec_completion_routine(TasksGroup.Priority.High, useRandomPause: true, numberOfSequTask:ShowSummary.smallGraphSize, testMode:PseudoSequential)
    }

    // Quantity

    func test_021_graph_exec_completion_Background_large() {
        _graph_exec_completion_routine(TasksGroup.Priority.Background, useRandomPause: false, numberOfSequTask:ShowSummary.largeGraphSize, testMode:PseudoSequential)
    }

    func test_022_graph_exec_completion_Low_large() {
        _graph_exec_completion_routine(TasksGroup.Priority.Low, useRandomPause: false, numberOfSequTask:ShowSummary.largeGraphSize, testMode:PseudoSequential)
    }

    func test_023_graph_exec_completion_Default_large() {
        _graph_exec_completion_routine(TasksGroup.Priority.Default, useRandomPause: false, numberOfSequTask:ShowSummary.largeGraphSize, testMode:PseudoSequential)
    }
    func test_024_graph_exec_completion_High_large() {
        _graph_exec_completion_routine(TasksGroup.Priority.High, useRandomPause: false, numberOfSequTask:ShowSummary.largeGraphSize, testMode:PseudoSequential)
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

        let expectation = expectationWithDescription("Post execution is clean \(priority) \(useRandomPause) \(numberOfSequTask) \(testMode)")

        Bartleby.sharedInstance.configureWith(BartlebyDefaultConfiguration.self)
        TasksScheduler.DEBUG_TASKS=false
        let document=BartlebyDocument()
        Bartleby.startBufferingBprint()

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
                XCTAssert(taskCount==0, "All the task have been executed and the totalTaskCount == 0 ")
                XCTAssert(ShowSummary.executionCounter==numberOfSequTask+1, "Execution counter should be consistent \(ShowSummary.executionCounter)")
                Bartleby.stopBufferingBprint()
                print("FULLFILLING \(group.UID)")
                let elapsed=ShowSummary.stopMeasuring()
                print ("Elapsed time : \(elapsed)")
                expectation.fulfill()
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

        waitForExpectationsWithTimeout(TestsConfiguration.LONG_TIME_OUT_DURATION) { error -> Void in
            if let error = error {
                bprint("Error: \(error.localizedDescription)")
            }
        }
    }





}
