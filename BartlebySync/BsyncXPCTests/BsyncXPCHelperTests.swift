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
    
    func test101_master() {
        let expectation = expectationWithDescription("DMG creation")
        let user = User()
        user.creatorUID = user.UID
        let context = TestContext()
        print(context.name)
        let folderPath = Bartleby.getSearchPath(.DesktopDirectory)! + "bsyncHelperTests/" + context.name + "/"
        let helper = BsyncXPCHelper()
        let card = helper.cardFor(user, context: context, folderPath: folderPath, isMaster: true)
        let handler = BsyncXPCHelperDMGHandler(onCompletion: { (work) in
            expectation.fulfill()
            XCTAssert(work.success, work.message)
            }, detach: true)
        
        helper.createDMG(card, thenDo: { (remoteObjectProxy, volumePath, whenDone) in
            // use remoteObjectProxy
            self.fm.directoryExistsAtPath(volumePath, handlers: Handlers { (existence) in
                XCTAssert(existence.success, existence.message)
                whenDone.callBlock(existence)
            })
            }, completion: handler)
        
        waitForExpectationsWithTimeout(200) { (error) in
            bprint(error?.localizedDescription)
        }
    }

    func test101_slave() {
        let expectation = expectationWithDescription("DMG creation")
        let user = User()
        user.creatorUID = user.UID
        let context = TestContext()
        print(context.name)
        let folderPath = Bartleby.getSearchPath(.DesktopDirectory)! + "bsyncHelperTests/" + context.name + "/"
        let helper = BsyncXPCHelper()
        let card = helper.cardFor(user, context: context, folderPath: folderPath, isMaster: false)
        let handler = BsyncXPCHelperDMGHandler(onCompletion: { (work) in
            expectation.fulfill()
            XCTAssert(work.success, work.message)
            }, detach: true)
        
        helper.createDMG(card, thenDo: { (remoteObjectProxy, volumePath, whenDone) in
            // use remoteObjectProxy
            self.fm.directoryExistsAtPath(volumePath, handlers: Handlers { (existence) in
                XCTAssert(existence.success, existence.message)
                whenDone.callBlock(existence)
                })
            }, completion: handler)
        
        waitForExpectationsWithTimeout(200) { (error) in
            bprint(error?.localizedDescription)
        }
    }
}
