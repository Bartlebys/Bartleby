//
//  LocalSyncTests.swift
//  bsync
//
//  Created by Martin Delille on 28/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class LocalSyncTests: SyncTestCase {
    
    private static var _directives = BsyncDirectives()
    
    override func setUp() {
        super.setUp()
        
        sourceFolderPath = assetPath + "Src/tree/"
        destinationFolderPath = assetPath + "Dst/tree/"
    }
    
    static private let _admin = BsyncAdmin()
    
    override func prepareSync(handlers: Handlers) {
        LocalSyncTests._directives = BsyncDirectives.localDirectivesWithPath(sourceFolderPath, destinationPath: destinationFolderPath)
        super.prepareSync(handlers)
    }
    
    override func sync(handlers: Handlers) {
        LocalSyncTests._admin.runDirectives(LocalSyncTests._directives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: handlers)
    }
}
