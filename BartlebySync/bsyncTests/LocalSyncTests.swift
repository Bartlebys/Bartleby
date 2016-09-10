//
//  LocalSyncTests.swift
//  bsync
//
//  Created by Martin Delille on 28/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class LocalSyncTests: SyncTestCase {

    fileprivate static var _directives = BsyncDirectives()

    override class func setUp() {
        super.setUp()
    }

    override func setUp() {
        super.setUp()
        self.sourceFolderPath = self.assetPath + "Src/tree/"
        self.destinationFolderPath = self.assetPath + "Dst/tree/"
    }

    static fileprivate let _admin = BsyncAdmin()

    override func prepareSync(_ handlers: Handlers) {
        LocalSyncTests._directives = BsyncDirectives.localDirectivesWithPath(sourceFolderPath, destinationPath: destinationFolderPath)
        super.prepareSync(handlers)
    }

    override func sync(_ handlers: Handlers) {
        LocalSyncTests._admin.runDirectives(LocalSyncTests._directives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: Handlers { (localSync) in
            if localSync.success {
                super.sync(handlers)
            } else {
                handlers.on(localSync)
            }
            })
    }
}
