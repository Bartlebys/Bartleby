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
    
    private var _distantTreeURL = NSURL()
    
    private static var _upDirectives = BsyncDirectives()
    private static var _downDirectives = BsyncDirectives()
    
    override func setUp() {
        super.setUp()
        
        sourceFolderPath = assetPath + "Up/"
        destinationFolderPath = assetPath + "Down/"
        
        _distantTreeURL = TestsConfiguration.API_BASE_URL.URLByAppendingPathComponent("BartlebySync/tree/\(testName)")
    }
    
    static private let _admin = BsyncAdmin()
    
    override func prepareSync(handlers: Handlers) {
        // Create user
        let user = createUser(spaceUID, handlers: Handlers { (creation) in
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
    
    override func sync(handlers: Handlers) {
        UpDownDirectivesTests._admin.runDirectives(UpDownDirectivesTests._upDirectives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: Handlers { (upSync) in
            if upSync.success {
                UpDownDirectivesTests._admin.runDirectives(UpDownDirectivesTests._downDirectives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: handlers)
            } else {
                handlers.on(upSync)
            }
            })
    }
    
    override func disposeSync(handlers: Handlers) {
        deleteCreatedUsers(Handlers { (deletion) in
            if deletion.success {
                super.disposeSync(handlers)
            } else {
                handlers.on(deletion)
            }
            })
    }
}
