//
//  BsyncAdminUpDownSyncTests.swift
//  bsync
//
//  Created by Martin Delille on 05/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class BsyncAdminUpDownSyncTestsNoCrypto: BsyncAdminUpDownSyncTests {
    override class func setUp() {
        super.setUp()
        Bartleby.cryptoDelegate = NoCrypto()
    }
}

class BsyncAdminUpDownSyncTests: XCTestCase {
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
    
    private static var _fm = BFileManager()
    
    override class func setUp() {
        Bartleby.sharedInstance.configureWith(TestsConfiguration)
        
       _treeName = Bartleby.randomStringWithLength(6)
       _folderPath = TestsConfiguration.ASSET_PATH + "BsyncAdminUpDownSyncTests/"
       _upFolderPath = _folderPath + "Up/" + _treeName + "/"
       _upFilePath = _upFolderPath + "file.txt"
       _fileContent = Bartleby.randomStringWithLength(20)
       
       _distantTreeURL = TestsConfiguration.API_BASE_URL.URLByAppendingPathComponent("BartlebySync/tree/\(_treeName)")
       
       _downFolderPath = _folderPath + "Down/" + _treeName + "/"
       _downFilePath = _downFolderPath + "file.txt"
    }
    
    // MARK: 0 - Initialization
    
    func test000_purgeCookiesForTheDomainAndFiles(){
        print(BsyncAdminUpDownSyncTests._treeName)
        let expectation = expectationWithDescription("Cleaning")
        
        if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL){
            for cookie in cookies{
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
            }
        }
        
        if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL){
            XCTAssertTrue((cookies.count==0), "We should  have 0 cookie  #\(cookies.count)")
        }
        
        BsyncAdminUpDownSyncTests._fm.removeItemAtPath(BsyncAdminUpDownSyncTests._folderPath) { (success, message) in
            BsyncAdminUpDownSyncTests._fm.fileExistsAtPath(BsyncAdminUpDownSyncTests._folderPath, callBack: { (exists, isADirectory, success, message) in
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
        user.password = BsyncAdminUpDownSyncTests._password
        user.spaceUID = BsyncAdminUpDownSyncTests._spaceUID
        BsyncAdminUpDownSyncTests._user = user
        
        CreateUser.execute(user, inDataSpace: BsyncAdminUpDownSyncTests._spaceUID, sucessHandler: { (context) in
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
        BsyncAdminUpDownSyncTests._fm.createDirectoryAtPath(BsyncAdminUpDownSyncTests._downFolderPath, withIntermediateDirectories: true, attributes: nil, callBack: { (success, message) in
            // Create up folder
            BsyncAdminUpDownSyncTests._fm.createDirectoryAtPath(BsyncAdminUpDownSyncTests._upFolderPath, withIntermediateDirectories: true, attributes: nil, callBack: { (success, message) in
                XCTAssertTrue(success, "\(message)")
                if success {
                    // Create file
                    BsyncAdminUpDownSyncTests._fm.writeString(BsyncAdminUpDownSyncTests._fileContent, path: BsyncAdminUpDownSyncTests._upFilePath, atomically: true, encoding: NSUTF8StringEncoding, callBack: { (success, message) in
                        XCTAssertTrue(success, "\(message)")
                        // Check file existence
                        BsyncAdminUpDownSyncTests._fm.fileExistsAtPath(BsyncAdminUpDownSyncTests._upFilePath, callBack: { (exists, isADirectory, success, message) in
                            XCTAssertTrue(exists, "\(message)")
                            XCTAssertFalse(isADirectory, "\(message)")
                            // Check file content
                            BsyncAdminUpDownSyncTests._fm.readString(contentsOfFile: BsyncAdminUpDownSyncTests._upFilePath, encoding: NSUTF8StringEncoding, callBack: { (string, success, message) in
                                XCTAssertTrue(success, "\(message)")
                                XCTAssertEqual(string, BsyncAdminUpDownSyncTests._fileContent, "\(message)")
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
    
    // MARK: 3 - Run local analyser
    
    func test301_RunLocalAnalyser_UpPath() {
        let expectation = expectationWithDescription("Local analyser should complete")
        var analyzer = BsyncLocalAnalyzer()
        
        do {
            try analyzer.createHashMapFromLocalPath(BsyncAdminUpDownSyncTests._upFolderPath, progressBlock: { (hash, path, index) in
                print("\(index) checksum of \(path) is \(hash)")
                }, completionBlock: { (hashMap) in
                    expectation.fulfill()
            })
        } catch {
            XCTFail("\(error)")
        }
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint("\(error?.localizedDescription)", file: #file, function: #function, line: #line)
        }
    }
    
    func test302_RunLocalAnalyser_DownPath() {
        let expectation = expectationWithDescription("Local analyser should complete")
        var analyzer = BsyncLocalAnalyzer()
        
        do {
            try analyzer.createHashMapFromLocalPath(BsyncAdminUpDownSyncTests._downFolderPath, progressBlock: { (hash, path, index) in
                print("\(index) checksum of \(path) is \(hash)")
                }, completionBlock: { (hashMap) in
                    expectation.fulfill()
            })
        } catch {
            XCTFail("\(error)")
        }
        
        waitForExpectationsWithTimeout(5) { (error) in
            bprint("\(error?.localizedDescription)", file: #file, function: #function, line: #line)
        }
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
            
            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION){ error -> Void in
                if let error = error {
                    bprint("Error: \(error.localizedDescription)")
                }
            }
        }
        else {
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
        
        let admin = BsyncAdmin(context: context)
        
        do {
            try admin.synchronizeWithprogressBlock(ProgressAndCompletionHandler(completionHandler: { (c) in
                XCTAssertTrue(c.success, c.message)
                expectation.fulfill()
            }))
        } catch {
            XCTFail("Synchronize failed")
        }
        
        
        waitForExpectationsWithTimeout(500.0) { (error) in
            if let error = error {
                bprint(error.localizedDescription)
            }
        }
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
        
        let admin = BsyncAdmin(context: context)
        
        do {
            try admin.synchronizeWithprogressBlock(ProgressAndCompletionHandler(completionHandler: { (c) in
                XCTAssertTrue(c.success, c.message)
                expectation.fulfill()
            }))
        } catch {
            XCTFail("Synchronize failed")
        }
        
        waitForExpectationsWithTimeout(500.0) { (error) in
            if let error = error {
                bprint(error.localizedDescription)
            }
        }
    }
    
    func test404_CheckFileHasBeenDownloaded() {
        let expectation = expectationWithDescription("File has been checked")
        
        BsyncAdminUpDownSyncTests._fm.fileExistsAtPath(BsyncAdminUpDownSyncTests._downFilePath) { (exists, isADirectory, success, message) in
            XCTAssertTrue(success, "\(message)")
            XCTAssertTrue(exists)
            BsyncAdminUpDownSyncTests._fm.readString(contentsOfFile: BsyncAdminUpDownSyncTests._downFilePath, encoding: NSUTF8StringEncoding, callBack: { (string, success, message) in
                XCTAssertTrue(success, "\(message)")
                XCTAssertEqual(string, BsyncAdminUpDownSyncTests._fileContent)
                expectation.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint("\(error?.localizedDescription)", file: #file, function: #function, line: #line)
        }
    }
}
