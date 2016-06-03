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
class BsyncXPCHelperTests: TestCase {
    let fm = BFileManager()
    
    func test_touch() {
        let expectation = expectationWithDescription("Should call back")
        
        let helper = BsyncXPCHelper()
        
        helper.touch(Handlers {(touch) in
            expectation.fulfill()
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test_UnMountDMG_unexistingPath() {
        let expectation = expectationWithDescription("Should failed")
        
        let helper = BsyncXPCHelper()
        let card = helper.cardFor(User(), context: TestContext(), folderPath: "/unexisting/path", isMaster: false)
        helper.unMountDMG(card, handlers: Handlers { (unmount) in
            XCTAssertFalse(unmount.success)
            expectation.fulfill()
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test_Create_then_UnMount() {
        let expectation1 = expectationWithDescription("should do")
        let expectation2 = expectationWithDescription("should unmount")
        
        
        let helper = BsyncXPCHelper()
        let context = TestContext()
        let folderPath = BsyncXPCHelperTests.assetPath + context.name + "/"
        let card = helper.cardFor(User(), context: context, folderPath: folderPath, isMaster: true)
        
        helper.createDMG(card, thenDo: { (whenDone) in
            expectation1.fulfill()
            whenDone.on(Completion.successState())
            }, detachImageOnCompletion: false, handlers: Handlers { ( completion) in
                XCTAssert(completion.success, completion.message)
                expectation2.fulfill()
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test101_master_detach() {
        let expectation = expectationWithDescription("detach")
        let user = User()
        user.creatorUID = user.UID
        let context = TestContext()
        print(context.name)
        let folderPath = BsyncXPCHelperTests.assetPath + context.name + "/"
        let helper = BsyncXPCHelper()
        let card = helper.cardFor(user, context: context, folderPath: folderPath, isMaster: true)
        
        helper.createDMG(card, thenDo: { (whenDone) in
            // check volume path exists
            self.fm.directoryExistsAtPath(card.volumePath, handlers: Handlers { (existence) in
                XCTAssert(existence.success, existence.message)
                whenDone.on(existence)
                })
            }, detachImageOnCompletion: true, handlers: Handlers { (work) in
                XCTAssert(work.success, work.message)
                // Check volume has been detach
                self.fm.directoryExistsAtPath(card.volumePath, handlers: Handlers { (existence) in
                    XCTAssertFalse(existence.success)
                    expectation.fulfill()
                    })
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test101_master_dont_detach() {
        let expectation = expectationWithDescription("detach")
        let user = User()
        user.creatorUID = user.UID
        let context = TestContext()
        print(context.name)
        let folderPath = BsyncXPCHelperTests.assetPath + context.name + "/"
        let helper = BsyncXPCHelper()
        let card = helper.cardFor(user, context: context, folderPath: folderPath, isMaster: true)
        
        helper.createDMG(card, thenDo: { (whenDone) in
            // Check volume path exists
            self.fm.directoryExistsAtPath(card.volumePath, handlers: Handlers { (existence) in
                XCTAssert(existence.success, existence.message)
                whenDone.on(existence)
                })
            }, detachImageOnCompletion: false, handlers: Handlers { (work) in
                print("work done")
                XCTAssert(work.success, work.message)
                // Check volume isn't detached yet
                self.fm.directoryExistsAtPath(card.volumePath, handlers: Handlers { (existence) in
                    print("check existence")
                    XCTAssertTrue(existence.success)
                    // Detach the volume for cleaning purpose
                    helper.unMountDMG(card, handlers: Handlers { (unmount) in
                        expectation.fulfill()
                        XCTAssert(unmount.success, unmount.message)
                        })
                    })
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test101_slave_detach() {
        let expectation = expectationWithDescription("detach")
        let user = User()
        user.creatorUID = user.UID
        let context = TestContext()
        print(context.name)
        let folderPath = BsyncXPCHelperTests.assetPath + context.name + "/"
        let helper = BsyncXPCHelper()
        let card = helper.cardFor(user, context: context, folderPath: folderPath, isMaster: false)
        
        helper.createDMG(card, thenDo: { (whenDone) in
            // use remoteObjectProxy
            self.fm.directoryExistsAtPath(card.volumePath, handlers: Handlers { (existence) in
                XCTAssert(existence.success, existence.message)
                whenDone.on(existence)
                })
            }, detachImageOnCompletion: true, handlers: Handlers { (work) in
                XCTAssert(work.success, work.message)
                // Check volume has been detach
                self.fm.directoryExistsAtPath(card.volumePath, handlers: Handlers { (existence) in
                    XCTAssertFalse(existence.success)
                    expectation.fulfill()
                    })
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test101_slave_dont_detach() {
        let expectation = expectationWithDescription("detach")
        let user = User()
        user.creatorUID = user.UID
        let context = TestContext()
        print(context.name)
        let folderPath = BsyncXPCHelperTests.assetPath + context.name + "/"
        let helper = BsyncXPCHelper()
        let card = helper.cardFor(user, context: context, folderPath: folderPath, isMaster: false)
        
        helper.createDMG(card, thenDo: { (whenDone) in
            // use remoteObjectProxy
            self.fm.directoryExistsAtPath(card.volumePath, handlers: Handlers { (existence) in
                XCTAssert(existence.success, existence.message)
                whenDone.on(existence)
                })
            }, detachImageOnCompletion: false, handlers: Handlers { (work) in
                XCTAssert(work.success, work.message)
                // Check volume isn't detached yet
                self.fm.directoryExistsAtPath(card.volumePath, handlers: Handlers { (existence) in
                    XCTAssertTrue(existence.success)
                    // Detach the volume for cleaning purpose
                    helper.unMountDMG(card, handlers: Handlers { (detach) in
                        expectation.fulfill()
                        XCTAssert(detach.success, detach.message)
                        })
                    })
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
}
