///Users/bpds/Desktop/bartleby-document/groups.data
//  DocumentTests.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 20/05/2016.
//
//

import Foundation
import XCTest
import BartlebyKit

class DocumentTests: XCTestCase {

    func test_001_Create_A_Document_With_10_users() {

        let expectation=expectationWithDescription("createDocument")
        let document=BartlebyDocument()
        document.configureSchema()
        Bartleby.sharedInstance.configureWith(TestsConfiguration.self)
        let path=Bartleby.getSearchPath(NSSearchPathDirectory.DesktopDirectory)!.stringByAppendingString("bartleby.document")
        let url=NSURL(fileURLWithPath: path)

        for i in 1...10 {
            let user=User()
            user.email="user\(i)@bartlebys.org"
            document.users.add(user)
        }

        do {
            let operations: OperationsCollectionController = try document.getCollection()
            // We taskGroupFor the task
            let group=try Bartleby.scheduler.getTaskGroupWithName("Push_Operations\(document.spaceUID)", inDocument:document)
            group.priority=TasksGroup.Priority.High
            // We add the calling handlers
            //group.handlers.appendChainedHandlers(handlers)

            for operation in operations.items {
                let task=PushOperationTask(arguments:operation)
                try group.appendChainedTask(task)
            }

        } catch {
            XCTFail("\(error)")
        }


        document.saveToURL(url, ofType:"bartleby", forSaveOperation: NSSaveOperationType.SaveToOperation) { (error) in
            if let error = error {
                XCTFail("\(error)")
            } else {
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }

    }

/*
    func test_002_Read_Document_With_10_users() {

        let expectation=expectationWithDescription("loadDocument")
        let document=BartlebyDocument()
        document.configureSchema()
        Bartleby.sharedInstance.configureWith(BartlebyDefaultConfiguration.self)
        let path=Bartleby.getSearchPath(NSSearchPathDirectory.DesktopDirectory)!.stringByAppendingString("bartleby.document")
        let url=NSURL(fileURLWithPath: path)
        do {
            let fileWrapper = try NSFileWrapper(URL: url, options: [.Immediate])
            try document.readFromFileWrapper(fileWrapper, ofType:"bartleby")
        } catch {
            XCTFail("\(error)")

        }


        expectation.fulfill()

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }

    }

*/


}
