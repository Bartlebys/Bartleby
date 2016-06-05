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

class DocumentTests: TestCase {


    private static var _document=BartlebyDocument()

    func test_001_Create_A_Document_With_10_users() {

        let expectation=expectationWithDescription("createDocument")
        DocumentTests._document=BartlebyDocument()
        DocumentTests._document.configureSchema()
        Bartleby.sharedInstance.configureWith(TestsConfiguration.self)
        let path=Bartleby.getSearchPath(NSSearchPathDirectory.DesktopDirectory)!.stringByAppendingString("bartleby.document")
        let url=NSURL(fileURLWithPath: path)

        for i in 1...10 {
            let user=User()
            user.email="user\(i)@bartlebys.org"
             DocumentTests._document.users.add(user)
        }

        do {
            let operations: OperationsCollectionController = try  DocumentTests._document.getCollection()
            // We taskGroupFor the task
            let group=try Bartleby.scheduler.getTaskGroupWithName("Push_Operations\( DocumentTests._document.spaceUID)", inDocument: DocumentTests._document)
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


         DocumentTests._document.saveToURL(url, ofType:"bartleby", forSaveOperation: NSSaveOperationType.SaveToOperation) { (error) in
            if let error = error {
                XCTFail("\(error)")
            } else {
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler:nil)

        // Delete Document file
        Bartleby.executeAfter(1, closure: {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(url)
            } catch {

            }
        })
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

     waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
     }
*/

    /***
     This test destroys all the ephemeral instance and is consequently non neutral.
     */
    func test_999_Purge_Ephemeral_Members() {

        let expectation=expectationWithDescription("ephemeralMembersArePurged")
        XCTAssert((DocumentTests._document.users.items.count > 0), "Users count > 0")

        for user in DocumentTests._document.users.items {
            XCTAssert(user.ephemeral, "User instance is ephemeral")
        }

        Bartleby.sharedInstance.destroyLocalEphemeralInstances()
        XCTAssert((DocumentTests._document.users.items.count == 0), "Ephemeral users  have been destroyed nb of users = \(DocumentTests._document.users.items.count)")

        expectation.fulfill()
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }


 


}
