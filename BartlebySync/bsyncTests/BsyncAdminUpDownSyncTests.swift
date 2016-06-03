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
    private static var _spaceUID = ""
    private static var _password = ""
    private static var _user: User?
    
    // tree created on the alternative server are not touchable ???
    class var _treeName: String {
        get {
            return "BsyncAdminUpDownSyncTests"
        }
    }
    
    private static var _folderPath = ""
    private static var _upFolderPath = ""
    private static var _upFilePath = ""
    private static var _fileContent = ""
    
    private static var _distantTreeURL = NSURL()
    
    private static var _downFolderPath = ""
    private static var _downFilePath = ""
    
    override class func setUp() {
        super.setUp()
        
        _spaceUID = Bartleby.createUID()
        _password = Bartleby.randomStringWithLength(6)
        
        _folderPath = assetPath + _treeName + "/"
        _upFolderPath = _folderPath + "Up/" + _treeName + "/"
        _upFilePath = _upFolderPath + "file.txt"
        _fileContent = Bartleby.randomStringWithLength(20)
        
        _distantTreeURL = TestsConfiguration.API_BASE_URL.URLByAppendingPathComponent("BartlebySync/tree/\(_treeName)")
        
        _downFolderPath = _folderPath + "Down/" + _treeName + "/"
        _downFilePath = _downFolderPath + "file.txt"
        
    }
        
    // MARK: 1 - Create user
    func test101_CreateUser() {
        let expectation = expectationWithDescription("CreateUser should respond")
        
        let user=User()
        user.creatorUID=user.UID // (!) Auto creation in this context (Check ACL)
        user.password = BsyncAdminUpDownSyncTests._password
        user.spaceUID = BsyncAdminUpDownSyncTests._spaceUID
        BsyncAdminUpDownSyncTests._user = user
        
        CreateUser.execute(user, inDataSpace: BsyncAdminUpDownSyncTests._spaceUID, sucessHandler: { (context) in
            expectation.fulfill()
        }) { (context) in
            expectation.fulfill()
            XCTFail("\(context)")
        }
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    // MARK: 2 - Prepare folder and directives
    func test201_CreateFileInUpFolder() {
        do {
            // Create down folder
            try _fm.createDirectoryAtPath(BsyncAdminUpDownSyncTests._downFolderPath, withIntermediateDirectories: true, attributes: nil)
            // Create up folder
            try _fm.createDirectoryAtPath(BsyncAdminUpDownSyncTests._upFolderPath, withIntermediateDirectories: true, attributes: nil)
            // Create file
            try BsyncAdminUpDownSyncTests._fileContent.writeToFile(BsyncAdminUpDownSyncTests._upFilePath, atomically: true, encoding: Default.STRING_ENCODING)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    // MARK: 3 - Run local analyser
    
    func test301_RunLocalAnalyser_UpPath() {
        let expectation = expectationWithDescription("Local analyser should complete")
        var analyzer = BsyncLocalAnalyzer()
        
        analyzer.createHashMapFromLocalPath(BsyncAdminUpDownSyncTests._upFolderPath, handlers: Handlers { (analyze) in
            expectation.fulfill()
            XCTAssert(analyze.success, analyze.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test302_RunLocalAnalyser_DownPath() {
        let expectation = expectationWithDescription("Local analyser should complete")
        var analyzer = BsyncLocalAnalyzer()
        
        analyzer.createHashMapFromLocalPath(BsyncAdminUpDownSyncTests._downFolderPath, handlers: Handlers { (analyze) in
            expectation.fulfill()
            XCTAssert(analyze.success, analyze.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    // MARK: 4 - Run synchronization
    func test401_LoginUser() {
        let expectation = expectationWithDescription("LoginUser should respond")
        if let user = BsyncAdminUpDownSyncTests._user {
            user.login(withPassword: BsyncAdminUpDownSyncTests._password,
                       sucessHandler: { () -> () in
                        expectation.fulfill()
            }) { (context) ->() in
                expectation.fulfill()
                XCTFail("\(context)")
            }
            
            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }
    
    func test402_RunDirectives_UpToDistant() {
        let expectation = expectationWithDescription("Synchronization should complete")
        
        
        let context = BsyncContext(sourceURL: NSURL(fileURLWithPath: BsyncAdminUpDownSyncTests._upFolderPath, isDirectory: true),
                                   andDestinationUrl: BsyncAdminUpDownSyncTests._distantTreeURL,
                                   restrictedTo: nil,
                                   autoCreateTrees: true)
        context.credentials = BsyncCredentials()
        context.credentials?.user = BsyncAdminUpDownSyncTests._user
        context.credentials?.password = BsyncAdminUpDownSyncTests._password
        context.credentials?.salt = TestsConfiguration.SHARED_SALT
        
        let admin = BsyncAdmin()
        
        admin.synchronizeWithprogressBlock(context, handlers: Handlers { (sync) in
            XCTAssertTrue(sync.success, sync.message)
            expectation.fulfill()
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test403_RunDirectives_DistantToDown() {
        let expectation = expectationWithDescription("Synchronization should complete")
        
        
        let context = BsyncContext(sourceURL: BsyncAdminUpDownSyncTests._distantTreeURL,
                                   andDestinationUrl: NSURL(fileURLWithPath: BsyncAdminUpDownSyncTests._downFolderPath, isDirectory: true),
                                   restrictedTo: nil,
                                   autoCreateTrees: true)
        context.credentials = BsyncCredentials()
        context.credentials?.user = BsyncAdminUpDownSyncTests._user
        context.credentials?.password = BsyncAdminUpDownSyncTests._password
        context.credentials?.salt = TestsConfiguration.SHARED_SALT
        
        let admin = BsyncAdmin()
        
        admin.synchronizeWithprogressBlock(	context, handlers: Handlers(completionHandler: { (c) in
            XCTAssertTrue(c.success, c.message)
            expectation.fulfill()
        }))
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test404_CheckFileHasBeenDownloaded() {
        do {
            let content = try String(contentsOfFile: BsyncAdminUpDownSyncTests._downFilePath)
            
            XCTAssertEqual(content, BsyncAdminUpDownSyncTests._fileContent)
        } catch {
            XCTFail("\(error)")
        }
    }
}
