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
        
        _sourceFolderPath = assetPath + "Up/"
        _destinationFolderPath = assetPath + "Down/"
        
        _distantTreeURL = TestsConfiguration.API_BASE_URL.URLByAppendingPathComponent("BartlebySync/tree/\(testName)")
    }
    
    static private let _admin = BsyncAdmin()
    
    override func prepareSync() {
        super.prepareSync()
        
        let expectation = expectationWithDescription("Create user")
        
        let user = createUser(spaceUID, handlers: Handlers { (creation) in
            XCTAssert(creation.success, creation.message)
            expectation.fulfill()
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        
        // Create upstream directives
        let upDirectives = BsyncDirectives.upStreamDirectivesWithDistantURL(_distantTreeURL, localPath: _sourceFolderPath)
        upDirectives.automaticTreeCreation = true
        // Credentials:
        upDirectives.user = user
        upDirectives.password = user.password
        upDirectives.salt = TestsConfiguration.SHARED_SALT
        
        UpDownDirectivesTests._upDirectives = upDirectives
        
        // Create downstream directives
        let downDirectives = BsyncDirectives.downStreamDirectivesWithDistantURL(_distantTreeURL, localPath: _destinationFolderPath)
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
    
    override func disposeSync() {
        let expectation = expectationWithDescription("Delete user")
        
        deleteCreatedUsers(Handlers { (deletion) in
            expectation.fulfill()
            XCTAssert(deletion.success, deletion.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
}
