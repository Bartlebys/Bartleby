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
    
    private static var _distantTreeURL = NSURL()
    
    private static var _downFolderPath = ""
    private static var _downFilePath = ""
    
    private static var _upDirectivesPath = ""
    private static var _downDirectivePath = ""
    private static let _fm = BFileManager()
    
    override class func setUp() {
        super.setUp()
        
        _spaceUID = Bartleby.createUID()
        _password = Bartleby.randomStringWithLength(6)
        
        _treeName = NSStringFromClass(self)
        _upFolderPath = assetPath + "Up/" + _treeName + "/"
        _upFilePath = _upFolderPath + "file.txt"
        _fileContent = "martin" //Bartleby.randomStringWithLength(20)
        
        _distantTreeURL = TestsConfiguration.API_BASE_URL.URLByAppendingPathComponent("BartlebySync/tree/\(_treeName)")
        
        _downFolderPath = assetPath + "Down/" + _treeName + "/"
        _downFilePath = _downFolderPath + "file.txt"
        
        _upDirectivesPath = _upFolderPath + BsyncDirectives.DEFAULT_FILE_NAME
        _downDirectivePath = _downFolderPath + BsyncDirectives.DEFAULT_FILE_NAME
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
        
        let fm = NSFileManager.defaultManager()
        do {
            try fm.removeItemAtPath(UpDownDirectivesTests.assetPath)
        } catch {
            // Silent catch
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
        let expectation = expectationWithDescription("All files should be created")
        // Create down folder
        Bartleby.fileManager.createDirectoryAtPath(UpDownDirectivesTests._downFolderPath, handlers: Handlers { (downFolderCreation) in
            XCTAssert(downFolderCreation.success, downFolderCreation.message)
            // Create up folder
            Bartleby.fileManager.createDirectoryAtPath(UpDownDirectivesTests._upFolderPath, handlers: Handlers { (upFolderCreation) in
                XCTAssertTrue(upFolderCreation.success, upFolderCreation.message)
                // Create file
                Bartleby.fileManager.writeString(UpDownDirectivesTests._fileContent, path: UpDownDirectivesTests._upFilePath, handlers: Handlers { (fileCreation) in
                    XCTAssertTrue(fileCreation.success, fileCreation.message)
                    expectation.fulfill()
                    })
                })
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    
    func test202_CreateDirectives_UpToDistant() {
        let directives = BsyncDirectives.upStreamDirectivesWithDistantURL(UpDownDirectivesTests._distantTreeURL, localPath: UpDownDirectivesTests._upFolderPath)
        directives.automaticTreeCreation = true
        // Credentials:
        directives.user = UpDownDirectivesTests._user
        directives.password = UpDownDirectivesTests._password
        directives.salt = TestsConfiguration.SHARED_SALT
        
        let admin = BsyncAdmin()
        do {
            try admin.saveDirectives(directives, path:UpDownDirectivesTests._upDirectivesPath)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test203_CreateDirectives_DistantToDown() {
        let directives = BsyncDirectives.downStreamDirectivesWithDistantURL(UpDownDirectivesTests._distantTreeURL, localPath: UpDownDirectivesTests._downFolderPath)
        directives.automaticTreeCreation = true
        
        // Credentials:
        directives.user = UpDownDirectivesTests._user
        directives.password = UpDownDirectivesTests._password
        directives.salt = TestsConfiguration.SHARED_SALT
        
        let admin = BsyncAdmin()
        do {
            try admin.saveDirectives(directives, path:UpDownDirectivesTests._downDirectivePath)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test402_RunDirectives_UpToDistant() {
        
        do {
            let admin = BsyncAdmin()
            let directives = try admin.loadDirectives(UpDownDirectivesTests._upDirectivesPath)
            
            let expectation = expectationWithDescription("Synchronization should complete")
            
            admin.runDirectives(directives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: Handlers { (completion) in
                expectation.fulfill()
                XCTAssertTrue(completion.success, completion.message)
                })
            
            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } catch {
            XCTFail("\(error)")
        }
        
    }
    
    func test403_RunDirectives_DistantToDown() {
        do {
            let admin = BsyncAdmin()
            let directives = try admin.loadDirectives(UpDownDirectivesTests._downDirectivePath)
            
            let expectation = expectationWithDescription("Synchronization should complete")
            
            admin.runDirectives(directives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: Handlers { (completion) in
                expectation.fulfill()
                XCTAssertTrue(completion.success, completion.message)
                })
            
            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test404_CheckFileHasBeenDownloaded() {
        let expectation = expectationWithDescription("File has been checked")
        
        Bartleby.fileManager.readString(contentsOfFile: UpDownDirectivesTests._downFilePath, handlers: Handlers { (read) in
            XCTAssertEqual(read.getStringResult(), UpDownDirectivesTests._fileContent, read.message)
            expectation.fulfill()
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
}
