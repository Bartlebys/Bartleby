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
        
        _sourceFolderPath = assetPath + "Up/tree/"
        _destinationFolderPath = assetPath + "Down/tree/"
    }
    
    static private let _admin = BsyncAdmin()
    
    override func prepareSync() {
        super.prepareSync()
        LocalSyncTests._directives = BsyncDirectives.localDirectivesWithPath(_sourceFolderPath, destinationPath: _destinationFolderPath)
    }
    
    override func sync(handlers: Handlers) {
        LocalSyncTests._admin.runDirectives(LocalSyncTests._directives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: handlers)
    }
}
