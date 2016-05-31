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
    private static var _fileContent = ""
    private static var _modifiedFileContent = ""
    private static var _upSubFolderPath = ""
    
    
    private static var _distantTreeURL = NSURL()
    
    private static var _downFolderPath = ""
    private static var _downFilePath = ""
    
    private static var _upDirectives = BsyncDirectives()
    private static var _downDirectives = BsyncDirectives()
    
    override class func setUp() {
        super.setUp()
        
        _spaceUID = Bartleby.createUID()
        _password = Bartleby.randomStringWithLength(6)
        
        _treeName = NSStringFromClass(self)
        _upFolderPath = assetPath + "Up/" + _treeName + "/"
        _upFilePath = _upFolderPath + "file.txt"
        _fileContent = "martin"
        _modifiedFileContent = Bartleby.randomStringWithLength(30)
        _upSubFolderPath = _upFolderPath + "sub/"
        
        _distantTreeURL = TestsConfiguration.API_BASE_URL.URLByAppendingPathComponent("BartlebySync/tree/\(_treeName)")
        
        _downFolderPath = assetPath + "Down/" + _treeName + "/"
        _downFilePath = _downFolderPath + "file.txt"
    }
    
    // MARK: 0 - Initialization
    
    func test000_purgeCookiesForTheDomainAndFiles() {
        if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL) {
            for cookie in cookies {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
            }
        }
        
        if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL) {
            XCTAssertTrue((cookies.count==0), "We should  have 0 cookie  #\(cookies.count)")
        }
    }
    
    // MARK: 1 - Create user
    func test101_CreateUser() {
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
    func test201_CreateFileInUpFolder() {
        do {
            // Create down folder
            try _fm.createDirectoryAtPath(UpDownDirectivesTests._downFolderPath, withIntermediateDirectories: true, attributes: nil)
            try _fm.createDirectoryAtPath(UpDownDirectivesTests._upFolderPath, withIntermediateDirectories: true, attributes: nil)
            try UpDownDirectivesTests._fileContent.writeToFile(UpDownDirectivesTests._upFilePath, atomically: true, encoding: Default.STRING_ENCODING)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    
    func test202_CreateDirectives_UpToDistant() {
        UpDownDirectivesTests._upDirectives = BsyncDirectives.upStreamDirectivesWithDistantURL(UpDownDirectivesTests._distantTreeURL, localPath: UpDownDirectivesTests._upFolderPath)
        UpDownDirectivesTests._upDirectives.automaticTreeCreation = true
        // Credentials:
        UpDownDirectivesTests._upDirectives.user = UpDownDirectivesTests._user
        UpDownDirectivesTests._upDirectives.password = UpDownDirectivesTests._password
        UpDownDirectivesTests._upDirectives.salt = TestsConfiguration.SHARED_SALT
    }
    
    func test203_CreateDirectives_DistantToDown() {
        UpDownDirectivesTests._downDirectives = BsyncDirectives.downStreamDirectivesWithDistantURL(UpDownDirectivesTests._distantTreeURL, localPath: UpDownDirectivesTests._downFolderPath)
        UpDownDirectivesTests._downDirectives.automaticTreeCreation = true
        
        // Credentials:
        UpDownDirectivesTests._downDirectives.user = UpDownDirectivesTests._user
        UpDownDirectivesTests._downDirectives.password = UpDownDirectivesTests._password
        UpDownDirectivesTests._downDirectives.salt = TestsConfiguration.SHARED_SALT
    }
    
    // MARK: 3 - Run synchronization
    func test301_RunDirectives_UpToDistant() {
        
        let admin = BsyncAdmin()
        
        let expectation = expectationWithDescription("Synchronization should complete")
        
        admin.runDirectives(UpDownDirectivesTests._upDirectives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: Handlers { (completion) in
            expectation.fulfill()
            XCTAssertTrue(completion.success, completion.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test302_RunDirectives_DistantToDown() {
        let admin = BsyncAdmin()
        
        let expectation = expectationWithDescription("Synchronization should complete")
        
        admin.runDirectives(UpDownDirectivesTests._downDirectives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: Handlers { (completion) in
            expectation.fulfill()
            XCTAssertTrue(completion.success, completion.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    // MARK: 4 - Check sync result
    func test404_CheckFileHasBeenDownloaded() {
        do {
            let files = try _fm.contentsOfDirectoryAtPath(UpDownDirectivesTests._downFolderPath)
            XCTAssertEqual(2, files.count)
            XCTAssertEqual(".bsync", files[0])
            XCTAssertEqual("file.txt", files[1])
            let content = try String(contentsOfFile: UpDownDirectivesTests._downFilePath)
            XCTAssertEqual(content, UpDownDirectivesTests._fileContent)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    // MARK: 5 - Edit upstream folder files
    func test501_Edit_existing_files() {
        do {
            try UpDownDirectivesTests._modifiedFileContent.writeToFile(UpDownDirectivesTests._upFilePath, atomically: true, encoding: Default.STRING_ENCODING)
            
        } catch {
            XCTFail("\(error)")
        }
    }
}
