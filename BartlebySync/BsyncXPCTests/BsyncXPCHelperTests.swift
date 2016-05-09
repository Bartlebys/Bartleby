//
//  BsyncXPCHelperTests.swift
//  BsyncXPCHelperTests
//
//  Created by Martin Delille on 06/05/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest


class TestContext: IdentifiableCardContext {
    let UID: String = Bartleby.createUID()
    var name: String = Bartleby.randomStringWithLength(6)
    
}
class BsyncXPCHelperTests: XCTestCase {
    let fm = BFileManager()
    
    func test101_master_detach() {
        let expectation = expectationWithDescription("detach")
        let user = User()
        user.creatorUID = user.UID
        let context = TestContext()
        print(context.name)
        let folderPath = TestsConfiguration.ASSET_PATH + "BsyncXPCHelperTests/" + context.name + "/"
        let helper = BsyncXPCHelper()
        let card = helper.cardFor(user, context: context, folderPath: folderPath, isMaster: true)
        let handlers = Handlers { (work) in
            XCTAssert(work.success, work.message)
            // Check volume has been detach
            self.fm.directoryExistsAtPath(card.volumePath, handlers: Handlers { (existence) in
                XCTAssertFalse(existence.success)
                expectation.fulfill()
                })
        }
        
        helper.createDMG(card, thenDo: { (whenDone) in
            // check volume path exists
            self.fm.directoryExistsAtPath(card.volumePath, handlers: Handlers { (existence) in
                XCTAssert(existence.success, existence.message)
                whenDone.on(existence)
                })
            }, detachImageOnCompletion: true, handlers: handlers)
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint(error?.localizedDescription)
        }
    }
    
    func test101_master_dont_detach() {
        let expectation = expectationWithDescription("detach")
        let user = User()
        user.creatorUID = user.UID
        let context = TestContext()
        print(context.name)
        let folderPath = TestsConfiguration.ASSET_PATH + "BsyncXPCHelperTests/" + context.name + "/"
        let helper = BsyncXPCHelper()
        let card = helper.cardFor(user, context: context, folderPath: folderPath, isMaster: true)
        let handlers = Handlers { (work) in
            XCTAssert(work.success, work.message)
            // Check volume isn't detached yet
            self.fm.directoryExistsAtPath(card.volumePath, handlers: Handlers { (existence) in
                XCTAssertTrue(existence.success)
                // Detach the volume for cleaning purpose
                helper.unMountDMG(card.volumeName, handlers: Handlers { (unmount) in
                    expectation.fulfill()
                    XCTAssert(unmount.success, unmount.message)
                    })
                })
        }
        
        helper.createDMG(card, thenDo: { (whenDone) in
            // Check volume path exists
            self.fm.directoryExistsAtPath(card.volumePath, handlers: Handlers { (existence) in
                XCTAssert(existence.success, existence.message)
                whenDone.on(existence)
                })
            }, detachImageOnCompletion: false, handlers: handlers)
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint(error?.localizedDescription)
        }
    }
    
    func test101_slave_detach() {
        let expectation = expectationWithDescription("detach")
        let user = User()
        user.creatorUID = user.UID
        let context = TestContext()
        print(context.name)
        let folderPath = TestsConfiguration.ASSET_PATH + "BsyncXPCHelperTests/" + context.name + "/"
        let helper = BsyncXPCHelper()
        let card = helper.cardFor(user, context: context, folderPath: folderPath, isMaster: false)
        let handlers = Handlers { (work) in
            XCTAssert(work.success, work.message)
            // Check volume has been detach
            self.fm.directoryExistsAtPath(card.volumePath, handlers: Handlers { (existence) in
                XCTAssertFalse(existence.success)
                expectation.fulfill()
                })
        }
        
        helper.createDMG(card, thenDo: { (whenDone) in
            // use remoteObjectProxy
            self.fm.directoryExistsAtPath(card.volumePath, handlers: Handlers { (existence) in
                XCTAssert(existence.success, existence.message)
                whenDone.on(existence)
                })
            }, detachImageOnCompletion: true, handlers: handlers)
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint(error?.localizedDescription)
        }
    }
    
    func test101_slave_dont_detach() {
        let expectation = expectationWithDescription("detach")
        let user = User()
        user.creatorUID = user.UID
        let context = TestContext()
        print(context.name)
        let folderPath = TestsConfiguration.ASSET_PATH + "BsyncXPCHelperTests/" + context.name + "/"
        let helper = BsyncXPCHelper()
        let card = helper.cardFor(user, context: context, folderPath: folderPath, isMaster: false)
        let handlers = Handlers { (work) in
            XCTAssert(work.success, work.message)
            // Check volume isn't detached yet
            self.fm.directoryExistsAtPath(card.volumePath, handlers: Handlers { (existence) in
                XCTAssertTrue(existence.success)
                // Detach the volume for cleaning purpose
                helper.unMountDMG(card.volumeName, handlers: Handlers { (detach) in
                    expectation.fulfill()
                    XCTAssert(detach.success, detach.message)
                    })
                })
        }
        
        helper.createDMG(card, thenDo: { (whenDone) in
            // use remoteObjectProxy
            self.fm.directoryExistsAtPath(card.volumePath, handlers: Handlers { (existence) in
                XCTAssert(existence.success, existence.message)
                whenDone.on(existence)
                })
            }, detachImageOnCompletion: false, handlers: handlers)
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint(error?.localizedDescription)
        }
    }
}
