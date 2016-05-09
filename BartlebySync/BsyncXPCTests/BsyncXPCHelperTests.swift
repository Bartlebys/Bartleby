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
    var volumePath: String?
    var xpc: BsyncXPCProtocol?
    
    override func setUp() {
        self.volumePath = nil
        self.xpc = nil
    }
    func test101_master_detach() {
        let expectation = expectationWithDescription("detach")
        let user = User()
        user.creatorUID = user.UID
        let context = TestContext()
        print(context.name)
        let folderPath = TestsConfiguration.ASSET_PATH + "BsyncXPCHelperTests/" + context.name + "/"
        let helper = BsyncXPCHelper()
        let card = helper.cardFor(user, context: context, folderPath: folderPath, isMaster: true)
        let handler = BsyncXPCHelperDMGHandler(onCompletion: { (work) in
            XCTAssert(work.success, work.message)
            // Check volume has been detach
            if let volumePath = self.volumePath {
                self.fm.directoryExistsAtPath(volumePath, handlers: Handlers { (existence) in
                    XCTAssertFalse(existence.success)
                    expectation.fulfill()
                    })
            } else {
                XCTFail("Volume path has not been set")
            }
            }, detach: true)
        
        helper.createDMG(card, thenDo: { (remoteObjectProxy, volumePath, whenDone) in
            // use remoteObjectProxy
            self.fm.directoryExistsAtPath(volumePath, handlers: Handlers { (existence) in
                XCTAssert(existence.success, existence.message)
                self.volumePath = volumePath
                whenDone.callBlock(existence)
                })
            }, completion: handler)
        
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
        self.volumePath = nil
        self.xpc = nil
        let handler = BsyncXPCHelperDMGHandler(onCompletion: { (work) in
            XCTAssert(work.success, work.message)
            // Check volume isn't detached yet
            if let volumePath = self.volumePath, let xpc = self.xpc {
                self.fm.directoryExistsAtPath(volumePath, handlers: Handlers { (existence) in
                    XCTAssertTrue(existence.success)
                    // Detach the volume for cleaning purpose
                    xpc.detachVolume(card.volumeName, handler: Handlers { (detach) in
                        expectation.fulfill()
                        XCTAssert(detach.success, detach.message)
                        }.composedHandlers())
                    })
            } else {
                XCTFail("Volume path has not been set")
            }
            }, detach: false)
        
        helper.createDMG(card, thenDo: { (remoteObjectProxy, volumePath, whenDone) in
            // use remoteObjectProxy
            self.fm.directoryExistsAtPath(volumePath, handlers: Handlers { (existence) in
                XCTAssert(existence.success, existence.message)
                self.volumePath = volumePath
                self.xpc = remoteObjectProxy
                whenDone.callBlock(existence)
                })
            }, completion: handler)
        
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
        self.volumePath = nil
        let helper = BsyncXPCHelper()
        let card = helper.cardFor(user, context: context, folderPath: folderPath, isMaster: false)
        let handler = BsyncXPCHelperDMGHandler(onCompletion: { (work) in
            XCTAssert(work.success, work.message)
            // Check volume has been detach
            if let volumePath = self.volumePath {
                self.fm.directoryExistsAtPath(volumePath, handlers: Handlers { (existence) in
                    XCTAssertFalse(existence.success)
                    expectation.fulfill()
                    })
            } else {
                XCTFail("Volume path has not been set")
            }
            }, detach: true)
        
        helper.createDMG(card, thenDo: { (remoteObjectProxy, volumePath, whenDone) in
            // use remoteObjectProxy
            self.fm.directoryExistsAtPath(volumePath, handlers: Handlers { (existence) in
                XCTAssert(existence.success, existence.message)
                self.volumePath = volumePath
                whenDone.callBlock(existence)
                })
            }, completion: handler)
        
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
        self.volumePath = nil
        self.xpc = nil
        let helper = BsyncXPCHelper()
        let card = helper.cardFor(user, context: context, folderPath: folderPath, isMaster: false)
        let handler = BsyncXPCHelperDMGHandler(onCompletion: { (work) in
            XCTAssert(work.success, work.message)
            // Check volume isn't detached yet
            if let volumePath = self.volumePath, let xpc = self.xpc {
                self.fm.directoryExistsAtPath(volumePath, handlers: Handlers { (existence) in
                    XCTAssertTrue(existence.success)
                    // Detach the volume for cleaning purpose
                    xpc.detachVolume(card.volumeName, handler: Handlers { (detach) in
                        expectation.fulfill()
                        XCTAssert(detach.success, detach.message)
                        }.composedHandlers())
                    })
            } else {
                XCTFail("Volume path has not been set")
            }
            }, detach: false)
        
        helper.createDMG(card, thenDo: { (remoteObjectProxy, volumePath, whenDone) in
            // use remoteObjectProxy
            self.fm.directoryExistsAtPath(volumePath, handlers: Handlers { (existence) in
                XCTAssert(existence.success, existence.message)
                self.volumePath = volumePath
                self.xpc = remoteObjectProxy
                whenDone.callBlock(existence)
                })
            }, completion: handler)
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint(error?.localizedDescription)
        }
    }
}
