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


class UpDownDirectivesTests: XCTestCase {
    private static let _spaceUID = Bartleby.createUID()
    private static let _password = Bartleby.randomStringWithLength(6)
    private static var _user: User?
    
    private static var _treeName = ""
    private static var _folderPath = ""
    private static var _upFolderPath = ""
    private static var _upFilePath = ""
    private static var _fileContent = ""
    
    private static var _distantTreeURL = NSURL()
    
    private static var _downFolderPath = ""
    private static var _downFilePath = ""
    
    private static var _upDirectivePath = ""
    private static var _downDirectivePath = ""
    private static let _fm = BFileManager()
    
    override class func setUp() {
        Bartleby.sharedInstance.configureWith(TestsConfiguration)

        _treeName = Bartleby.randomStringWithLength(6)
        _folderPath = TestsConfiguration.ASSET_PATH + self.className() + "/"
        _upFolderPath = _folderPath + "Up/" + _treeName + "/"
        _upFilePath = _upFolderPath + "file.txt"
        _fileContent = Bartleby.randomStringWithLength(20)
        
        _distantTreeURL = TestsConfiguration.API_BASE_URL.URLByAppendingPathComponent("BartlebySync/tree/\(_treeName)")
        
        _downFolderPath = _folderPath + "Down/" + _treeName + "/"
        _downFilePath = _downFolderPath + "file.txt"
        
        _upDirectivePath = _upFolderPath + BsyncDirectives.DEFAULT_FILE_NAME
        _downDirectivePath = _downFolderPath + BsyncDirectives.DEFAULT_FILE_NAME
    }
    
    // MARK: 0 - Initialization
    
    func test000_purgeCookiesForTheDomainAndFiles(){
        let expectation = expectationWithDescription("Cleaning")
        
        if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL){
            for cookie in cookies{
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
            }
        }
        
        if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL){
            XCTAssertTrue((cookies.count==0), "We should  have 0 cookie  #\(cookies.count)")
        }
        
        UpDownDirectivesTests._fm.removeItemAtPath(UpDownDirectivesTests._folderPath) { (success, message) in
            UpDownDirectivesTests._fm.fileExistsAtPath(UpDownDirectivesTests._folderPath, callBack: { (exists, isADirectory, success, message) in
                XCTAssertFalse(exists, "\(message)")
                expectation.fulfill()
            })
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint("\(error)", file: #file, function: #function, line: #line)
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
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint(error?.localizedDescription, file: #file, function: #function, line: #line)
        }
    }
    
    // MARK: 2 - Prepare folder and directives
    func test201_CreateFileInUpFolder() {
        let expectation = expectationWithDescription("All files should be created")
        // Create down folder
        UpDownDirectivesTests._fm.createDirectoryAtPath(UpDownDirectivesTests._downFolderPath, withIntermediateDirectories: true, attributes: nil, callBack: { (success, message) in
            // Create up folder
            UpDownDirectivesTests._fm.createDirectoryAtPath(UpDownDirectivesTests._upFolderPath, withIntermediateDirectories: true, attributes: nil, callBack: { (success, message) in
                XCTAssertTrue(success, "\(message)")
                if success {
                    // Create file
                    UpDownDirectivesTests._fm.writeString(UpDownDirectivesTests._fileContent, path: UpDownDirectivesTests._upFilePath, atomically: true, encoding: NSUTF8StringEncoding, callBack: { (success, message) in
                        XCTAssertTrue(success, "\(message)")
                        // Check file existence
                        UpDownDirectivesTests._fm.fileExistsAtPath(UpDownDirectivesTests._upFilePath, callBack: { (exists, isADirectory, success, message) in
                            XCTAssertTrue(exists, "\(message)")
                            XCTAssertFalse(isADirectory, "\(message)")
                            // Check file content
                            UpDownDirectivesTests._fm.readString(contentsOfFile: UpDownDirectivesTests._upFilePath, encoding: NSUTF8StringEncoding, callBack: { (string, success, message) in
                                XCTAssertTrue(success, "\(message)")
                                XCTAssertEqual(string, UpDownDirectivesTests._fileContent, "\(message)")
                                expectation.fulfill()
                            })
                        })
                    })
                }
            })
        })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint(error?.localizedDescription, file: #file, function: #function, line: #line)
        }
    }
    
    
    func test202_CreateDirectives_UpToDistant() {
        let directives = BsyncDirectives.upStreamDirectivesWithDistantURL(UpDownDirectivesTests._distantTreeURL, localPath: UpDownDirectivesTests._upFolderPath)
        directives.automaticTreeCreation = true
        // Credentials:
        directives.user = UpDownDirectivesTests._user
        directives.password = UpDownDirectivesTests._password
        directives.salt = TestsConfiguration.SHARED_SALT
        
        let directivesURL = NSURL(fileURLWithPath: UpDownDirectivesTests._upDirectivePath)
        let (success, message) = BsyncAdmin.createDirectives(directives, saveTo: directivesURL)
        
        if(!success) {
            if let message = message {
                XCTFail(message)
            } else {
                XCTFail("Unknown error")
            }
        } else {
            UpDownDirectivesTests._fm.fileExistsAtPath(UpDownDirectivesTests._upDirectivePath, callBack: { (exists, isADirectory, success, message) in
                XCTAssertTrue(exists, "\(message)")
                XCTAssertFalse(isADirectory, "\(message)")
            })
        }
    }
    
    func test203_CreateDirectives_DistantToDown() {
        let directives = BsyncDirectives.downStreamDirectivesWithDistantURL(UpDownDirectivesTests._distantTreeURL, localPath: UpDownDirectivesTests._downFolderPath)
        directives.automaticTreeCreation = true

        // Credentials:
        directives.user = UpDownDirectivesTests._user
        directives.password = UpDownDirectivesTests._password
        directives.salt = TestsConfiguration.SHARED_SALT
        
        let directivesURL = NSURL(fileURLWithPath: UpDownDirectivesTests._downDirectivePath)
        let (success, message) = BsyncAdmin.createDirectives(directives, saveTo: directivesURL)
        
        if(!success) {
            if let message = message {
                XCTFail(message)
            } else {
                XCTFail("Unknown error")
            }
        } else {
            UpDownDirectivesTests._fm.fileExistsAtPath(UpDownDirectivesTests._downDirectivePath, callBack: { (exists, isADirectory, success, message) in
                XCTAssertTrue(success, "\(message)")
                XCTAssertFalse(isADirectory)
                XCTAssertTrue(exists)
                XCTAssertFalse(isADirectory, "\(message)")
            })
        }
    }
    func test402_RunDirectives_UpToDistant() {
        let expectation = expectationWithDescription("Synchronization should complete")
        
        let runner = BsyncDirectivesRunner()
        let handlers = ProgressAndCompletionHandler { (completion) in
            expectation.fulfill()
            XCTAssertTrue(completion.success, completion.message)
        }
        handlers.addProgressBlock { (progression) in
            bprint("\(progression.currentTaskIndex)/\(progression.totalTaskCount)/\(progression.message)", file: #file, function: #function, line: #line)
        }
        runner.runDirectives(UpDownDirectivesTests._upDirectivePath, secretKey: TestsConfiguration.KEY, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: handlers)
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            if let error = error {
                bprint(error.localizedDescription)
            }
        }
    }
    
    func test403_RunDirectives_DistantToDown() {
        let expectation = expectationWithDescription("Synchronization should complete")
        
        let runner = BsyncDirectivesRunner()
        let handlers = ProgressAndCompletionHandler { (completion) in
            expectation.fulfill()
            XCTAssertTrue(completion.success, completion.message)
        }
        handlers.addProgressBlock { (progression) in
            bprint("\(progression.currentTaskIndex)/\(progression.totalTaskCount)/\(progression.message)", file: #file, function: #function, line: #line)
        }
        runner.runDirectives(UpDownDirectivesTests._downDirectivePath, secretKey: TestsConfiguration.KEY, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: handlers)
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            if let error = error {
                bprint(error.localizedDescription)
            }
        }
    }
    
    func test404_CheckFileHasBeenDownloaded() {
        let expectation = expectationWithDescription("File has been checked")
        
        UpDownDirectivesTests._fm.fileExistsAtPath(UpDownDirectivesTests._downFilePath) { (exists, isADirectory, success, message) in
            XCTAssertTrue(success, "\(message)")
            XCTAssertTrue(exists)
            UpDownDirectivesTests._fm.readString(contentsOfFile: UpDownDirectivesTests._downFilePath, encoding: NSUTF8StringEncoding, callBack: { (string, success, message) in
                XCTAssertTrue(success, "\(message)")
                XCTAssertEqual(string, UpDownDirectivesTests._fileContent)
                expectation.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint("\(error?.localizedDescription)", file: #file, function: #function, line: #line)
        }
    }
}
