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
    var name: String = Default.NO_NAME
}



class BsyncXPCHelperTests: TestCase {
    let fm = BFileManager()
    
    func test_touch() {
        let expected = expectation(description: "Should call back")
        
        let helper = BsyncXPCHelper()
        
        helper.touch(Handlers {(touch) in
            expected.fulfill()
            })
        
        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test_UnMountDMG_unexistingPath() {
        let expected = expectation(description: "Should failed")
        
        let helper = BsyncXPCHelper()
        let card = helper.cardFor(User(), context: TestContext() as! IdentifiableCardContext, folderPath: "/unexisting/path", isMaster: false)
        helper.unMountDMG(card, handlers: Handlers { (unmount) in
            XCTAssertFalse(unmount.success)
            expected.fulfill()
            })
        
        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test_Create_then_UnMount() {
        let expectation1 = expectation(description: "should do")
        let expectation2 = expectation(description: "should unmount")
        
        
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
        
        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test101_master_detach() {
        let expected = expectation(description: "detach")
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
                    expected.fulfill()
                    })
            })
        
        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test101_master_dont_detach() {
        let expected = expectation(description: "detach")
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
                        expected.fulfill()
                        XCTAssert(unmount.success, unmount.message)
                        })
                    })
            })
        
        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test101_slave_detach() {
        let expected = expectation(description: "detach")
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
                    expected.fulfill()
                    })
            })
        
        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test101_slave_dont_detach() {
        let expected = expectation(description: "detach")
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
                        expected.fulfill()
                        XCTAssert(detach.success, detach.message)
                        })
                    })
            })

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
}
