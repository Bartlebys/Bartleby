//
//  UpDownDirectivesTests
//  bsync
//
//  Created by Benoit Pereira da silva on 01/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest


class UpDownDirectivesTestsNoCrypto: UpDownDirectivesTests {
    override static func setUp() {
        super.setUp()
        Bartleby.cryptoDelegate = NoCrypto()
    }
}


class UpDownDirectivesTests: SyncTestCase {

    fileprivate var _distantTreeURL = TestsConfiguration.API_BASE_URL

    fileprivate static var _upDirectives = BsyncDirectives()
    fileprivate static var _downDirectives = BsyncDirectives()
    fileprivate static var _treeId = ""

    override class func setUp() {
        super.setUp()

        _treeId = testName + Bartleby.createUID()
    }

    override func setUp() {
        super.setUp()

        self.sourceFolderPath = self.assetPath + "Src/"
        self.destinationFolderPath = self.assetPath + "Dst/"

        _distantTreeURL = TestsConfiguration.API_BASE_URL.appendingPathComponent("BartlebySync/tree/\(UpDownDirectivesTests._treeId)")
    }

    static fileprivate let _admin = BsyncAdmin()

    override func prepareSync(_ handlers: Handlers) {
        // Create user
        let user = createUser(TestCase.document.spaceUID, handlers: Handlers { (creation) in
            if creation.success {
                super.prepareSync(handlers)
            } else {
                handlers.on(creation)
            }
            })

        // Create upstream directives
        let upDirectives = BsyncDirectives.upStreamDirectivesWithDistantURL(_distantTreeURL, localPath: sourceFolderPath)
        upDirectives.automaticTreeCreation = true
        // Credentials:
        upDirectives.user = user
        upDirectives.password = user.password
        upDirectives.salt = TestsConfiguration.SHARED_SALT

        UpDownDirectivesTests._upDirectives = upDirectives

        // Create downstream directives
        let downDirectives = BsyncDirectives.downStreamDirectivesWithDistantURL(_distantTreeURL, localPath: destinationFolderPath)
        downDirectives.automaticTreeCreation = true

        // Credentials:
        downDirectives.user = user
        downDirectives.password = user.password
        downDirectives.salt = TestsConfiguration.SHARED_SALT

        UpDownDirectivesTests._downDirectives = downDirectives
    }

    override func sync(_ handlers: Handlers) {
        UpDownDirectivesTests._admin.runDirectives(UpDownDirectivesTests._upDirectives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: Handlers { (upSync) in
            if upSync.success {
                UpDownDirectivesTests._admin.runDirectives(UpDownDirectivesTests._downDirectives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: Handlers { (downSync) in
                    if downSync.success {
                        super.sync(handlers)
                    } else {
                        handlers.on(downSync)
                    }
                    })
            } else {
                handlers.on(upSync)
            }
            })
    }

    override func disposeSync(_ handlers: Handlers) {
        deleteCreatedUsers(Handlers { (deletion) in
            if deletion.success {
                super.disposeSync(handlers)
            } else {
                handlers.on(deletion)
            }
            })
    }
}
