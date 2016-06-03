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


class UpDownDirectivesTests: TestCase {
    
    private static var _spaceUID = ""
    private static var _password = ""
    private static var _user: User?
    
    private static var _treeName = ""
    private static var _upFolderPath = ""
    private static var _upFilePath = ""
    private static var _fileContent1 = ""
    private static var _fileContent2 = ""
    private static var _upSubFolderPath = ""
    
    private static var _distantTreeURL = NSURL()
    
    private static var _downFolderPath = ""
    private static var _downFilePath = ""
    
    private static let _admin = BsyncAdmin()
    private static var _upDirectives = BsyncDirectives()
    private static var _downDirectives = BsyncDirectives()
    
    override class func setUp() {
        super.setUp()
        
        _spaceUID = Bartleby.createUID()
        _password = Bartleby.randomStringWithLength(6)
        
        _treeName = NSStringFromClass(self)
        _upFolderPath = assetPath + "Up/" + _treeName + "/"
        _upFilePath = _upFolderPath + "file.txt"
        _fileContent1 = "first synchronization content"
        _fileContent2 = "second synchronization content"
        _upSubFolderPath = _upFolderPath + "sub/"
        
        _distantTreeURL = TestsConfiguration.API_BASE_URL.URLByAppendingPathComponent("BartlebySync/tree/\(_treeName)")
        
        _downFolderPath = assetPath + "Down/" + _treeName + "/"
        _downFilePath = _downFolderPath + "file.txt"
    }
    
    // MARK: 1 - Create user
    func test101_Create_user() {
        let expectation = expectationWithDescription("CreateUser should respond")
        
        let user=User()
        user.creatorUID=user.UID // (!) Auto creation in this context (Check ACL)
        user.password = UpDownDirectivesTests._password
        user.spaceUID = UpDownDirectivesTests._spaceUID
        UpDownDirectivesTests._user = user
        
        CreateUser.execute(user, inDataSpace: UpDownDirectivesTests._spaceUID, sucessHandler: { (context) in
            expectation.fulfill()
        }) { (context) in
            expectation.fulfill()
            XCTFail("\(context)")
        }
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    // MARK: 2 - Prepare folder and directives
    func test201_Create_file_in_up_folder() {
        do {
            // Create down folder
            try _fm.createDirectoryAtPath(UpDownDirectivesTests._downFolderPath, withIntermediateDirectories: true, attributes: nil)
            try _fm.createDirectoryAtPath(UpDownDirectivesTests._upFolderPath, withIntermediateDirectories: true, attributes: nil)
            try UpDownDirectivesTests._fileContent1.writeToFile(UpDownDirectivesTests._upFilePath, atomically: true, encoding: Default.STRING_ENCODING)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    
    func test202_Create_upstream_directives() {
        UpDownDirectivesTests._upDirectives = BsyncDirectives.upStreamDirectivesWithDistantURL(UpDownDirectivesTests._distantTreeURL, localPath: UpDownDirectivesTests._upFolderPath)
        UpDownDirectivesTests._upDirectives.automaticTreeCreation = true
        // Credentials:
        UpDownDirectivesTests._upDirectives.user = UpDownDirectivesTests._user
        UpDownDirectivesTests._upDirectives.password = UpDownDirectivesTests._password
        UpDownDirectivesTests._upDirectives.salt = TestsConfiguration.SHARED_SALT
    }
    
    func test203_Create_downstream_directives() {
        UpDownDirectivesTests._downDirectives = BsyncDirectives.downStreamDirectivesWithDistantURL(UpDownDirectivesTests._distantTreeURL, localPath: UpDownDirectivesTests._downFolderPath)
        UpDownDirectivesTests._downDirectives.automaticTreeCreation = true
        
        // Credentials:
        UpDownDirectivesTests._downDirectives.user = UpDownDirectivesTests._user
        UpDownDirectivesTests._downDirectives.password = UpDownDirectivesTests._password
        UpDownDirectivesTests._downDirectives.salt = TestsConfiguration.SHARED_SALT
    }
    
    // MARK: 3 - Run synchronization
    func test301_RunDirectives_UpToDistant() {
        let expectation = expectationWithDescription("Synchronization should complete")
        
        UpDownDirectivesTests._admin.runDirectives(UpDownDirectivesTests._upDirectives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: Handlers { (sync) in
            expectation.fulfill()
            XCTAssertTrue(sync.success, sync.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test302_RunDirectives_DistantToDown() {
        let expectation = expectationWithDescription("Synchronization should complete")
        
        UpDownDirectivesTests._admin.runDirectives(UpDownDirectivesTests._downDirectives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: Handlers { (sync) in
            expectation.fulfill()
            XCTAssertTrue(sync.success, sync.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    // MARK: 4 - Check sync result
    func test404_CheckFileHasBeenDownloaded() {
        do {
            let files = try _fm.contentsOfDirectoryAtPath(UpDownDirectivesTests._downFolderPath)
            XCTAssertEqual(files, [".bsync", "file.txt"])
            let content = try String(contentsOfFile: UpDownDirectivesTests._downFilePath)
            XCTAssertEqual(content, UpDownDirectivesTests._fileContent1)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    // MARK: 5 - Edit and synchronize
    func test501_Edit_existing_files() {
        do {
            try UpDownDirectivesTests._fileContent2.writeToFile(UpDownDirectivesTests._upFilePath, atomically: true, encoding: Default.STRING_ENCODING)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test502_Run_upstream_directives() {
        let expectation = expectationWithDescription("Synchronization should complete")
        
        let handlers = Handlers { (sync) in
            expectation.fulfill()
            XCTAssertTrue(sync.success, sync.message)
        }
        handlers.appendProgressHandler { (progress) in
            print(progress.message)
        }
        UpDownDirectivesTests._admin.runDirectives(UpDownDirectivesTests._upDirectives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: handlers)
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test503_Run_downstream_directives() {
        let expectation = expectationWithDescription("Synchronization should complete")
        
        let handlers = Handlers { (sync) in
            expectation.fulfill()
            XCTAssertTrue(sync.success, sync.message)
        }
        handlers.appendProgressHandler { (progress) in
            print(progress.message)
        }
        
        UpDownDirectivesTests._admin.runDirectives(UpDownDirectivesTests._downDirectives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: handlers)
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test504_Check_file_has_been_modified() {
        do {
            let files = try _fm.contentsOfDirectoryAtPath(UpDownDirectivesTests._downFolderPath)
            XCTAssertEqual(files, [".bsync", "file.txt"])
            let content = try String(contentsOfFile: UpDownDirectivesTests._downFilePath)
            XCTAssertEqual(content, UpDownDirectivesTests._fileContent2)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    // MARK 9 - Cleaning
    func test901_Remove_all_files() {
        do {
            try _fm.removeItemAtPath(UpDownDirectivesTests._upFilePath)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test902_Run_upstream_directives() {
        let expectation = expectationWithDescription("Synchronization should complete")
        
        let handlers = Handlers { (sync) in
            expectation.fulfill()
            XCTAssertTrue(sync.success, sync.message)
        }
        handlers.appendProgressHandler { (progress) in
            print(progress.message)
        }
        UpDownDirectivesTests._admin.runDirectives(UpDownDirectivesTests._upDirectives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: handlers)
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test903_Run_downstream_directives() {
        let expectation = expectationWithDescription("Synchronization should complete")
        
        let handlers = Handlers { (sync) in
            expectation.fulfill()
            XCTAssertTrue(sync.success, sync.message)
        }
        handlers.appendProgressHandler { (progress) in
            print(progress.message)
        }
        
        UpDownDirectivesTests._admin.runDirectives(UpDownDirectivesTests._downDirectives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: handlers)
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test904_Check_file_has_been_modified() {
        do {
            let files = try _fm.contentsOfDirectoryAtPath(UpDownDirectivesTests._downFolderPath)
            XCTAssertEqual(files, [".bsync"])
        } catch {
            XCTFail("\(error)")
        }
    }

}
