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
            ShowSummary.executionCounter += 1
            self.forward(Completion.successState())
        } catch let e {
            print("ERROR \(e)")
        }
    }
}



class TasksGroupBasicTests: XCTestCase {

    override static func setUp() {
        super.setUp()
        Registry.declareCollectibleType(ShowSummary)
        Registry.declareCollectibleType(Alias<ShowSummary>)
    }

    override func tearDown() {
        super.tearDown()
        ShowSummary.executionCounter=0
    }

    func test_001_PlayGroundTransposition() {

        let rootObject=JObject()
        rootObject.summary="ROOT OBJECT"
        let firstTask=ShowSummary(arguments: rootObject)
        let document=BartlebyDocument()
        let numberOfSequTask=5

        do {

            let expectation = expectationWithDescription("Post execution is clean")

            let group = try Bartleby.scheduler.getTaskGroupWithName(Bartleby.createUID(), inDataSpace: document.spaceUID)
            // This is the unique root task
            // So concurrency will be limited as we append sub tasks via appendSequentialTask
            try group.addConcurrentTask(firstTask)
            group.handlers.appendCompletionHandler({ (completion) in
               let taskCount=group.totalTaskCount()
                XCTAssert(taskCount==0,"All the task have been executed and the totalTaskCount == 0 ")
                
                XCTAssert(ShowSummary.executionCounter==numberOfSequTask+1, "Execution counter should be consistent")
                
                expectation.fulfill()
            })

            print("Adding Child tasks")
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

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { error -> Void in
            if let error = error {
                bprint("Error: \(error.localizedDescription)")
            }
        }

    }


}
