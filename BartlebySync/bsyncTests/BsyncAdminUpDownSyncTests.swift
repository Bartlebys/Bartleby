//
//  BsyncAdminUpDownSyncTests.swift
//  bsync
//
//  Created by Martin Delille on 05/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class BsyncAdminUpDownSyncTests: XCTestCase {
    private static let _spaceUID = Bartleby.createUID()
    private static let _password = Bartleby.randomStringWithLength(6)
    private static var _user: User?
    
    private static let _treeName = Bartleby.randomStringWithLength(6)
    private static let _upFolderURL = Bartleby.getSearchPathURL(.DesktopDirectory)!.URLByAppendingPathComponent("bsyncTests/BsyncAdminUpDownSyncTests/Up/\(_treeName)")
    private static let _upFolderPath = _upFolderURL.path!
    private static let _upFilePath = _upFolderPath + "/file.txt"
    private static let _fileContent = Bartleby.randomStringWithLength(20)
    
    private static let _apiUrl = TestsConfiguration.API_BASE_URL.URLByAppendingPathComponent("BartlebySync")
    private static let _distantTreeURL = _apiUrl.URLByAppendingPathComponent("tree/\(_treeName)")
    
    private static let _downFolderURL = Bartleby.getSearchPathURL(.DesktopDirectory)!.URLByAppendingPathComponent("bsyncTests/BsyncAdminUpDownSyncTests/Down/\(_treeName)")
    private static let _downFolderPath = _downFolderURL.path!
    private static let _downFilePath = _downFolderPath + "/file.txt"
    
    private static let _upDirectivePath = _upFolderPath + "/\(BsyncDirectives.DEFAULT_FILE_NAME)"
    private static let _downDirectivePath = _downFolderPath + "/\(BsyncDirectives.DEFAULT_FILE_NAME)"
    
    private static let _fm = BFileManager()
    
    override static func setUp() {
        Bartleby.sharedInstance.configureWith(TestsConfiguration)
        Bartleby.cryptoDelegate = NoCrypto()
    }
    
    // MARK: 0 - Initialization
    
    func test000_purgeCookiesForTheDomain(){
        print("Using : \(TestsConfiguration.API_BASE_URL)")
        
        if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL){
            for cookie in cookies{
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
            }
        }
        
        if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL){
            XCTAssertTrue((cookies.count==0), "We should  have 0 cookie  #\(cookies.count)")
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
    
    
    func test202_CreateDirectives_UpToDistant() {
        let directives = BsyncDirectives()
        // Credentials:
        directives.user = BsyncAdminUpDownSyncTests._user
        directives.password = BsyncAdminUpDownSyncTests._password
        directives.salt = TestsConfiguration.SHARED_SALT
        
        // Directives:
        directives.sourceURL = BsyncAdminUpDownSyncTests._upFolderURL
        directives.destinationURL = BsyncAdminUpDownSyncTests._distantTreeURL
        directives.automaticTreeCreation = true
        
        let directivesURL = BsyncAdminUpDownSyncTests._upFolderURL.URLByAppendingPathComponent(BsyncDirectives.DEFAULT_FILE_NAME, isDirectory: false)
        let (success, message) = BsyncAdmin.createDirectives(directives, saveTo: directivesURL)
        
        if(!success) {
            if let message = message {
                XCTFail(message)
            } else {
                XCTFail("Unknown error")
            }
        } else {
            BsyncAdminUpDownSyncTests._fm.fileExistsAtPath(BsyncAdminUpDownSyncTests._upDirectivePath, callBack: { (exists, isADirectory, success, message) in
                XCTAssertTrue(exists, "\(message)")
                XCTAssertFalse(isADirectory, "\(message)")
            })
        }
    }
    
    func test203_CreateDirectives_DistantToDown() {
        let directives = BsyncDirectives()
        // Credentials:
        directives.user = BsyncAdminUpDownSyncTests._user
        directives.password = BsyncAdminUpDownSyncTests._password
        directives.salt = TestsConfiguration.SHARED_SALT
        
        // Directives:
        directives.sourceURL = BsyncAdminUpDownSyncTests._distantTreeURL
        directives.destinationURL = BsyncAdminUpDownSyncTests._downFolderURL
        directives.automaticTreeCreation = true
        
        let directivesURL = BsyncAdminUpDownSyncTests._downFolderURL.URLByAppendingPathComponent(BsyncDirectives.DEFAULT_FILE_NAME, isDirectory: false)
        let (success, message) = BsyncAdmin.createDirectives(directives, saveTo: directivesURL)
        
        if(!success) {
            if let message = message {
                XCTFail(message)
            } else {
                XCTFail("Unknown error")
            }
        } else {
            BsyncAdminUpDownSyncTests._fm.fileExistsAtPath(BsyncAdminUpDownSyncTests._downDirectivePath, callBack: { (exists, isADirectory, success, message) in
                XCTAssertTrue(success, "\(message)")
                XCTAssertFalse(isADirectory)
                XCTAssertTrue(exists)
                XCTAssertFalse(isADirectory, "\(message)")
            })
        }
    }
    
    // MARK: 3 - Run local analyser
    
    func test301_RunLocalAnalyser_UpPath() {
        print(BsyncAdminUpDownSyncTests._downDirectivePath)
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
        print(BsyncAdminUpDownSyncTests._downDirectivePath)
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
        print(BsyncAdminUpDownSyncTests._downDirectivePath)
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
        print(BsyncAdminUpDownSyncTests._downDirectivePath)
        let expectation = expectationWithDescription("Synchronization should complete")
        
        BsyncAdminUpDownSyncTests._fm.readString(contentsOfFile: BsyncAdminUpDownSyncTests._upDirectivePath, encoding: NSUTF8StringEncoding) { (string, success, message) in
            XCTAssertTrue(success, "\(message)")
            if let upDirectives = Mapper<BsyncDirectives>().map(string) {
                
                let validity = upDirectives.areValid()
                XCTAssertTrue(validity.valid, "\(validity.message)")
                
                
                let context = BsyncContext(sourceURL: BsyncAdminUpDownSyncTests._upFolderURL,
                                           andDestinationUrl: BsyncAdminUpDownSyncTests._distantTreeURL,
                                           restrictedTo: nil,
                                           autoCreateTrees: true)
                context.credentials = BsyncCredentials()
                context.credentials?.user = upDirectives.user
                context.credentials?.password = upDirectives.password
                context.credentials?.salt = upDirectives.salt
                
                let admin = BsyncAdmin(context: context)
                
                do {
                    try admin.synchronizeWithprogressBlock({ (taskIndex, totalTaskCount, taskProgress, message,data) in
                        print("\(taskIndex)/\(totalTaskCount)")
                    }) { (success, message) in
                        XCTAssertTrue(success, "\(message)")
                        expectation.fulfill()
                    }
                } catch {
                    XCTFail("Synchronize failed")
                }
                
                
            } else {
                XCTFail("Error parsing directives")
            }
        }
        
        waitForExpectationsWithTimeout(500.0) { (error) in
            if let error = error {
                bprint(error.localizedDescription)
            }
        }
    }
    
    func test403_RunDirectives_DistantToDown() {
        print(BsyncAdminUpDownSyncTests._downDirectivePath)
        let expectation = expectationWithDescription("Synchronization should complete")
     

        BsyncAdminUpDownSyncTests._fm.readString(contentsOfFile: BsyncAdminUpDownSyncTests._downDirectivePath, encoding: NSUTF8StringEncoding) { (string, success, message) in
            XCTAssertTrue(success, "\(message)")
            if let downDirectives = Mapper<BsyncDirectives>().map(string) {
                
                let validity = downDirectives.areValid()
                XCTAssertTrue(validity.valid, "\(validity.message)")
                
                let context = BsyncContext(sourceURL: BsyncAdminUpDownSyncTests._distantTreeURL,
                                           andDestinationUrl: BsyncAdminUpDownSyncTests._downFolderURL,
                                           restrictedTo: nil,
                                           autoCreateTrees: true)
                context.credentials = BsyncCredentials()
                context.credentials?.user = downDirectives.user
                context.credentials?.password = downDirectives.password
                context.credentials?.salt = downDirectives.salt
                
                let admin = BsyncAdmin(context: context)
                
                do {
                    try admin.synchronizeWithprogressBlock({ (taskIndex, totalTaskCount, taskProgress, message,data) in
                        print("\(taskIndex)/\(totalTaskCount)")
                    }) { (success, message) in
                        XCTAssertTrue(success, "\(message)")
                        expectation.fulfill()
                    }
                } catch {
                    XCTFail("Synchronize failed")
                }
                
                
            } else {
                XCTFail("Error parsing directives")
            }
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
