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
    
    func test101_BasicTest() {
        let user = User()
        user.creatorUID = user.UID
        let context = TestContext()
        let folderPath = Bartleby.getSearchPath(.DesktopDirectory)! + "bsyncHelperTests/" + context.name + "/"
        let helper = BsyncXPCHelper()
        let card = helper.cardFor(user, context: context, folderPath: folderPath, isMaster: true)
        //helper.
    }
}
