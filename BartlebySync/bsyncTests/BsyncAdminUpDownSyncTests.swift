//
//  BsyncAdminUpDownSyncTests.swift
//  bsync
//
//  Created by Martin Delille on 05/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class BsyncAdminUpDownSyncTestsNoCrypto: BsyncAdminUpDownSyncTests {
    override static var _treeName: String {
        get {
            return "BsyncAdminUpDownSyncTestsNoCrypto"
        }
    }
    
    override class func setUp() {
        super.setUp()
        Bartleby.cryptoDelegate = NoCrypto()
    }
}

class BsyncAdminUpDownSyncTests: TestCase {
    private static var _user: User?
    
    // tree created on the alternative server are not touchable ???
    class var _treeName: String {
        get {
            return "BsyncAdminUpDownSyncTests"
        }
    }
    
    private var _upFolderPath = ""

    private var _distantTreeURL = NSURL()

    private var _downFolderPath = ""

    private let _fileName = "file.txt"
    private let _fileContent = "dummy content"

    override func setUp() {
        super.setUp()
        
        _upFolderPath = assetPath + "Up/"
        
        _distantTreeURL = TestsConfiguration.API_BASE_URL.URLByAppendingPathComponent("BartlebySync/tree/\(testName)")
        
        _downFolderPath = assetPath + "Down/"
    }
        
    // MARK: 1 - Create user
    func test101_CreateUser() {
        let expectation = expectationWithDescription("CreateUser should respond")
        
        let user = createUser(spaceUID, autologin: true, handlers: Handlers { (creation) in
            expectation.fulfill()
            XCTAssert(creation.success, creation.message)
            })
        BsyncAdminUpDownSyncTests._user = user
            
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    // MARK: 2 - Prepare folder and directives
    func test201_CreateFileInUpFolder() {
        do {
            // Create down folder
            try _fm.createDirectoryAtPath(_downFolderPath, withIntermediateDirectories: true, attributes: nil)
            // Create up folder
            try _fm.createDirectoryAtPath(_upFolderPath, withIntermediateDirectories: true, attributes: nil)
            // Create file
            try _fileContent.writeToFile(_upFolderPath + _fileName, atomically: true, encoding: Default.STRING_ENCODING)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    // MARK: 3 - Run local analyser
    
    func test301_RunLocalAnalyser_UpPath() {
        let expectation = expectationWithDescription("Local analyser should complete")
        var analyzer = BsyncLocalAnalyzer()
        
        analyzer.createHashMapFromLocalPath(_upFolderPath, handlers: Handlers { (analyze) in
            expectation.fulfill()
            XCTAssert(analyze.success, analyze.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test302_RunLocalAnalyser_DownPath() {
        let expectation = expectationWithDescription("Local analyser should complete")
        var analyzer = BsyncLocalAnalyzer()
        
        analyzer.createHashMapFromLocalPath(_downFolderPath, handlers: Handlers { (analyze) in
            expectation.fulfill()
            XCTAssert(analyze.success, analyze.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    // MARK: 4 - Run synchronization
    
    func test401_RunDirectives_UpToDistant() {
        let expectation = expectationWithDescription("Synchronization should complete")
        
        
        let context = BsyncContext(sourceURL: NSURL(fileURLWithPath: _upFolderPath, isDirectory: true),
                                   andDestinationUrl: _distantTreeURL,
                                   restrictedTo: nil,
                                   autoCreateTrees: true)
        context.credentials = BsyncCredentials()
        context.credentials?.user = BsyncAdminUpDownSyncTests._user
        context.credentials?.password = BsyncAdminUpDownSyncTests._user?.password
        context.credentials?.salt = TestsConfiguration.SHARED_SALT
        
        let admin = BsyncAdmin()
        
        admin.synchronizeWithprogressBlock(context, handlers: Handlers { (sync) in
            XCTAssertTrue(sync.success, sync.message)
            expectation.fulfill()
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test402_RunDirectives_DistantToDown() {
        let expectation = expectationWithDescription("Synchronization should complete")
        
        
        let context = BsyncContext(sourceURL: _distantTreeURL,
                                   andDestinationUrl: NSURL(fileURLWithPath: _downFolderPath, isDirectory: true),
                                   restrictedTo: nil,
                                   autoCreateTrees: true)
        context.credentials = BsyncCredentials()
        context.credentials?.user = BsyncAdminUpDownSyncTests._user
        context.credentials?.password = BsyncAdminUpDownSyncTests._user?.password
        context.credentials?.salt = TestsConfiguration.SHARED_SALT
        
        let admin = BsyncAdmin()
        
        admin.synchronizeWithprogressBlock(	context, handlers: Handlers(completionHandler: { (c) in
            XCTAssertTrue(c.success, c.message)
            expectation.fulfill()
        }))
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test403_CheckFileHasBeenDownloaded() {
        do {
            let files = try _fm.contentsOfDirectoryAtPath(_downFolderPath)
            XCTAssertEqual(files, [".bsync", "file.txt"])
            let content = try String(contentsOfFile: _downFolderPath + _fileName)
            
            XCTAssertEqual(content, _fileContent)
        } catch {
            XCTFail("\(error)")
        }
    }

    // MARK: 5 - Remove file
    func test501_CreateFileInUpFolder() {
        do {
            try _fm.removeItemAtPath(_upFolderPath + _fileName)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    // MARK: 6 - Run local analyser
    
    func test601_RunLocalAnalyser_UpPath() {
        let expectation = expectationWithDescription("Local analyser should complete")
        var analyzer = BsyncLocalAnalyzer()
        
        analyzer.createHashMapFromLocalPath(_upFolderPath, handlers: Handlers { (analyze) in
            expectation.fulfill()
            XCTAssert(analyze.success, analyze.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test602_RunLocalAnalyser_DownPath() {
        let expectation = expectationWithDescription("Local analyser should complete")
        var analyzer = BsyncLocalAnalyzer()
        
        analyzer.createHashMapFromLocalPath(_downFolderPath, handlers: Handlers { (analyze) in
            expectation.fulfill()
            XCTAssert(analyze.success, analyze.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    // MARK: 7 - Run synchronization
    
    func test701_RunDirectives_UpToDistant() {
        let expectation = expectationWithDescription("Synchronization should complete")
        
        
        let context = BsyncContext(sourceURL: NSURL(fileURLWithPath: _upFolderPath, isDirectory: true),
                                   andDestinationUrl: _distantTreeURL,
                                   restrictedTo: nil,
                                   autoCreateTrees: true)
        context.credentials = BsyncCredentials()
        context.credentials?.user = BsyncAdminUpDownSyncTests._user
        context.credentials?.password = BsyncAdminUpDownSyncTests._user?.password
        context.credentials?.salt = TestsConfiguration.SHARED_SALT
        
        let admin = BsyncAdmin()
        
        admin.synchronizeWithprogressBlock(context, handlers: Handlers { (sync) in
            XCTAssertTrue(sync.success, sync.message)
            expectation.fulfill()
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test702_RunDirectives_DistantToDown() {
        let expectation = expectationWithDescription("Synchronization should complete")
        
        
        let context = BsyncContext(sourceURL: _distantTreeURL,
                                   andDestinationUrl: NSURL(fileURLWithPath: _downFolderPath, isDirectory: true),
                                   restrictedTo: nil,
                                   autoCreateTrees: true)
        context.credentials = BsyncCredentials()
        context.credentials?.user = BsyncAdminUpDownSyncTests._user
        context.credentials?.password = BsyncAdminUpDownSyncTests._user?.password
        context.credentials?.salt = TestsConfiguration.SHARED_SALT
        
        let admin = BsyncAdmin()
        
        admin.synchronizeWithprogressBlock(	context, handlers: Handlers(completionHandler: { (c) in
            XCTAssertTrue(c.success, c.message)
            expectation.fulfill()
        }))
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test703_Check_file_has_been_delete() {
        do {
            let files = try _fm.contentsOfDirectoryAtPath(_downFolderPath)
            XCTAssertEqual(files, [".bsync"])
        } catch {
            XCTFail("\(error)")
        }
    }

    // MARk: 9 - Cleanup
    func test901_deleteUser() {
        let expectation = expectationWithDescription("Delete user")
        
        deleteCreatedUsers(Handlers { (deletion) in
            expectation.fulfill()
            XCTAssert(deletion.success, deletion.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
}
