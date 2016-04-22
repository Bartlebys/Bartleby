//
//  DistantBasicSyncTests.swift
//  bsync
//
//  Created by Martin Delille on 05/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class DistantBasicSyncTests: XCTestCase {
    private static let _spaceUID = Bartleby.createUID()
    private static let _password = Bartleby.randomStringWithLength(6)
    private static var _user: User?
    
    private static let _treeName = Bartleby.randomStringWithLength(6)
    private static let _upFolderURL = Bartleby.getSearchPathURL(.DesktopDirectory)!.URLByAppendingPathComponent("bsyncTests/DistantBasicSyncTests/Up/\(_treeName)")
    private static let _upFolderPath = _upFolderURL.path!
    private static let _upFilePath = _upFolderPath + "/file.txt"
    private static let _fileContent = Bartleby.randomStringWithLength(20)
    
    private static let _apiUrl = TestsConfiguration.API_BASE_URL.URLByAppendingPathComponent("BartlebySync")
    private static let _distantTreeURL = _apiUrl.URLByAppendingPathComponent("tree/\(_treeName)")
    
    private static let _downFolderURL = Bartleby.getSearchPathURL(.DesktopDirectory)!.URLByAppendingPathComponent("bsyncTests/DistantBasicSyncTests/Down/\(_treeName)")
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
        user.password = DistantBasicSyncTests._password
        user.spaceUID = DistantBasicSyncTests._spaceUID
        DistantBasicSyncTests._user = user
        
        CreateUser.execute(user, inDataSpace: DistantBasicSyncTests._spaceUID, sucessHandler: { (context) in
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
        DistantBasicSyncTests._fm.createDirectoryAtPath(DistantBasicSyncTests._downFolderPath, withIntermediateDirectories: true, attributes: nil, callBack: { (success, message) in
            // Create up folder
            DistantBasicSyncTests._fm.createDirectoryAtPath(DistantBasicSyncTests._upFolderPath, withIntermediateDirectories: true, attributes: nil, callBack: { (success, message) in
                XCTAssertTrue(success, "\(message)")
                if success {
                    // Create file
                    DistantBasicSyncTests._fm.writeString(DistantBasicSyncTests._fileContent, path: DistantBasicSyncTests._upFilePath, atomically: true, encoding: NSUTF8StringEncoding, callBack: { (success, message) in
                        XCTAssertTrue(success, "\(message)")
                        // Check file existence
                        DistantBasicSyncTests._fm.fileExistsAtPath(DistantBasicSyncTests._upFilePath, callBack: { (exists, isADirectory, success, message) in
                            XCTAssertTrue(exists, "\(message)")
                            XCTAssertFalse(isADirectory, "\(message)")
                            // Check file content
                            DistantBasicSyncTests._fm.readString(contentsOfFile: DistantBasicSyncTests._upFilePath, encoding: NSUTF8StringEncoding, callBack: { (string, success, message) in
                                XCTAssertTrue(success, "\(message)")
                                XCTAssertEqual(string, DistantBasicSyncTests._fileContent, "\(message)")
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
        directives.user = DistantBasicSyncTests._user
        directives.password = DistantBasicSyncTests._password
        directives.salt = TestsConfiguration.SHARED_SALT
        
        // Directives:
        directives.sourceURL = DistantBasicSyncTests._upFolderURL
        directives.destinationURL = DistantBasicSyncTests._distantTreeURL
        directives.automaticTreeCreation = true
        
        let directivesURL = DistantBasicSyncTests._upFolderURL.URLByAppendingPathComponent(BsyncDirectives.DEFAULT_FILE_NAME, isDirectory: false)
        let (success, message) = BsyncAdmin.createDirectives(directives, saveTo: directivesURL)
        
        if(!success) {
            if let message = message {
                XCTFail(message)
            } else {
                XCTFail("Unknown error")
            }
        } else {
            DistantBasicSyncTests._fm.fileExistsAtPath(DistantBasicSyncTests._upDirectivePath, callBack: { (exists, isADirectory, success, message) in
                XCTAssertTrue(exists, "\(message)")
                XCTAssertFalse(isADirectory, "\(message)")
            })
        }
    }
    
    func test203_CreateDirectives_DistantToDown() {
        let directives = BsyncDirectives()
        // Credentials:
        directives.user = DistantBasicSyncTests._user
        directives.password = DistantBasicSyncTests._password
        directives.salt = TestsConfiguration.SHARED_SALT
        
        // Directives:
        directives.sourceURL = DistantBasicSyncTests._distantTreeURL
        directives.destinationURL = DistantBasicSyncTests._downFolderURL
        directives.automaticTreeCreation = true
        
        let directivesURL = DistantBasicSyncTests._downFolderURL.URLByAppendingPathComponent(BsyncDirectives.DEFAULT_FILE_NAME, isDirectory: false)
        let (success, message) = BsyncAdmin.createDirectives(directives, saveTo: directivesURL)
        
        if(!success) {
            if let message = message {
                XCTFail(message)
            } else {
                XCTFail("Unknown error")
            }
        } else {
            DistantBasicSyncTests._fm.fileExistsAtPath(DistantBasicSyncTests._downDirectivePath, callBack: { (exists, isADirectory, success, message) in
                XCTAssertTrue(success, "\(message)")
                XCTAssertFalse(isADirectory)
                XCTAssertTrue(exists)
                XCTAssertFalse(isADirectory, "\(message)")
            })
        }
    }
    
    // MARK: 3 - Run local analyser
    
    func test301_RunLocalAnalyser_UpPath() {
        print(DistantBasicSyncTests._downDirectivePath)
        let expectation = expectationWithDescription("Local analyser should complete")
        var analyzer = BsyncLocalAnalyzer()
        
        do {
            try analyzer.createHashMapFromLocalPath(DistantBasicSyncTests._upFolderPath, progressBlock: { (hash, path, index) in
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
        print(DistantBasicSyncTests._downDirectivePath)
        let expectation = expectationWithDescription("Local analyser should complete")
        var analyzer = BsyncLocalAnalyzer()
        
        do {
            try analyzer.createHashMapFromLocalPath(DistantBasicSyncTests._downFolderPath, progressBlock: { (hash, path, index) in
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
        print(DistantBasicSyncTests._downDirectivePath)
        let expectation = expectationWithDescription("LoginUser should respond")
        if let user = DistantBasicSyncTests._user {
            user.login(withPassword: DistantBasicSyncTests._password,
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
        print(DistantBasicSyncTests._downDirectivePath)
        let expectation = expectationWithDescription("Synchronization should complete")
        
//        let cmd = RunDirectivesCommand { (success, message) in
//            expectation.fulfill()
//            XCTAssertTrue(success, "\(message)")
//        }
//        cmd.runAsCommandLine = false
//        cmd.addProgressBlock({ (taskIndex, totalTaskCount, taskProgress, message, data) in
//            bprint("\(taskIndex)/\(totalTaskCount)/\(message)", file: #file, function: #function, line: #line)
//        })
//        cmd.runDirectives(DistantBasicSyncTests._upDirectivePath, secretKey: TestsConfiguration.KEY, sharedSalt: TestsConfiguration.SHARED_SALT)
        
        DistantBasicSyncTests._fm.readString(contentsOfFile: DistantBasicSyncTests._upDirectivePath, encoding: NSUTF8StringEncoding) { (string, success, message) in
            XCTAssertTrue(success, "\(message)")
            if let upDirectives = Mapper<BsyncDirectives>().map(string) {
                
                let validity = upDirectives.areValid()
                XCTAssertTrue(validity.valid, "\(validity.message)")
                
                
                let context = BsyncContext(sourceURL: DistantBasicSyncTests._upFolderURL,
                                           andDestinationUrl: DistantBasicSyncTests._distantTreeURL,
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
        print(DistantBasicSyncTests._downDirectivePath)
        let expectation = expectationWithDescription("Synchronization should complete")
        
        DistantBasicSyncTests._fm.readString(contentsOfFile: DistantBasicSyncTests._downDirectivePath, encoding: NSUTF8StringEncoding) { (string, success, message) in
            XCTAssertTrue(success, "\(message)")
            if let downDirectives = Mapper<BsyncDirectives>().map(string) {
                
                let validity = downDirectives.areValid()
                XCTAssertTrue(validity.valid, "\(validity.message)")
                
                let context = BsyncContext(sourceURL: DistantBasicSyncTests._distantTreeURL,
                                           andDestinationUrl: DistantBasicSyncTests._downFolderURL,
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
        
        DistantBasicSyncTests._fm.fileExistsAtPath(DistantBasicSyncTests._downFilePath) { (exists, isADirectory, success, message) in
            XCTAssertTrue(success, "\(message)")
            XCTAssertTrue(exists)
            DistantBasicSyncTests._fm.readString(contentsOfFile: DistantBasicSyncTests._downFilePath, encoding: NSUTF8StringEncoding, callBack: { (string, success, message) in
                XCTAssertTrue(success, "\(message)")
                XCTAssertEqual(string, DistantBasicSyncTests._fileContent)
                expectation.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint("\(error?.localizedDescription)", file: #file, function: #function, line: #line)
        }
    }
}
