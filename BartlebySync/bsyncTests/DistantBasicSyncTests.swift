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
    private static let _fileManager = NSFileManager()
    
    private static let _treeName = Bartleby.randomStringWithLength(6)
//    private static let _upFolderPath = NSTemporaryDirectory() + _treeName
//    private static let _upFolderURL = NSURL(fileURLWithPath: _upFolderPath)
    private static let _upFolderURL = Bartleby.getSearchPathURL(.DesktopDirectory)?.URLByAppendingPathComponent("bsyncTests/DistantBasicSyncTests/Up")
    private static let _fileURL = _upFolderURL?.URLByAppendingPathComponent("file.txt")
    private static let _fileContent = Bartleby.randomStringWithLength(20)
    
    private static let _apiUrl = TestConfiguration.API_BASE_URL.URLByAppendingPathComponent("BartlebySync")
    private static let _distantTreeURL = _apiUrl.URLByAppendingPathComponent("tree/\(_treeName)")
    
//    private static let _downFolderPath = NSTemporaryDirectory() + _treeName
//    private static let _downFolderURL = NSURL(fileURLWithPath: _upFolderPath)
    private static let _downFolderURL = Bartleby.getSearchPathURL(.DesktopDirectory)?.URLByAppendingPathComponent("bsyncTests/DistantBasicSyncTests/Down")
    
    override static func setUp() {
        Bartleby.sharedInstance.configureWith(TestConfiguration)
    }
    
    // MARK: 1 - Create user
    func test101_CreateUser() {
        let expectation = expectationWithDescription("LoginUser should respond")
        let user = User()
        user.creatorUID = user.UID
        user.spaceUID = DistantBasicSyncTests._spaceUID
        DistantBasicSyncTests._user = user
        
        CreateUser.execute(user, inDataSpace: user.spaceUID, sucessHandler: { (context) in
            expectation.fulfill()
        }) { (context) in
            expectation.fulfill()
            XCTFail("\(context)")
        }
        
        waitForExpectationsWithTimeout(5) { (error) in
            bprint(error?.localizedDescription, file: #file, function: #function, line: #line)
        }
    }
    
    // MARK: 2 - Prepare folder and directives
    func test201_CreateFileInUpFolder() {
        do {
            try DistantBasicSyncTests._fileManager.createDirectoryAtURL(DistantBasicSyncTests._upFolderURL!, withIntermediateDirectories: true, attributes: nil)
            try DistantBasicSyncTests._fileManager.createDirectoryAtURL(DistantBasicSyncTests._downFolderURL!, withIntermediateDirectories: true, attributes: nil)
            try DistantBasicSyncTests._fileContent.writeToURL(DistantBasicSyncTests._fileURL!, atomically: false, encoding: NSUTF8StringEncoding)
            XCTAssertTrue(DistantBasicSyncTests._fileManager.fileExistsAtPath(DistantBasicSyncTests._fileURL!.path!))
            let fileContent = try String(contentsOfFile: DistantBasicSyncTests._fileURL!.path!, encoding: NSUTF8StringEncoding)
            XCTAssertEqual(DistantBasicSyncTests._fileContent, fileContent)
        } catch {
            XCTFail("File I/O error with \(DistantBasicSyncTests._fileURL)")
        }
    }
    
    func test202_CreateDirectives_UpToDistant() {
        let directives = BsyncDirectives()
        // Credentials:
        directives.user = DistantBasicSyncTests._user
        directives.password = DistantBasicSyncTests._password
        directives.salt = TestConfiguration.SHARED_SALT
        
        // Directives:
        directives.sourceURL = DistantBasicSyncTests._upFolderURL
        directives.destinationURL = DistantBasicSyncTests._distantTreeURL
        
        let directivesURL = DistantBasicSyncTests._upFolderURL!.URLByAppendingPathComponent(BsyncDirectives.DEFAULT_FILE_NAME, isDirectory: false)
        let (success, message) = BsyncAdmin.createDirectives(directives, saveTo: directivesURL)
        
        if(!success) {
            if let message = message {
                XCTFail(message)
            } else {
                XCTFail("Unknown error")
            }
        } else {
            if let path = directivesURL.path {
                XCTAssertTrue(DistantBasicSyncTests._fileManager.fileExistsAtPath(path))
            } else {
                XCTFail("Bad directive URL: \(directivesURL)")
            }
        }
    }
    
    func test203_CreateDirectives_DistantToDown() {
        let directives = BsyncDirectives()
        // Credentials:
        directives.user = DistantBasicSyncTests._user
        directives.password = DistantBasicSyncTests._password
        directives.salt = TestConfiguration.SHARED_SALT
        
        // Directives:
        directives.sourceURL = DistantBasicSyncTests._distantTreeURL
        directives.destinationURL = DistantBasicSyncTests._downFolderURL
        
        let directivesURL = DistantBasicSyncTests._downFolderURL!.URLByAppendingPathComponent(BsyncDirectives.DEFAULT_FILE_NAME, isDirectory: false)
        let (success, message) = BsyncAdmin.createDirectives(directives, saveTo: directivesURL)
        
        if(!success) {
            if let message = message {
                XCTFail(message)
            } else {
                XCTFail("Unknown error")
            }
        } else {
            if let path = directivesURL.path {
                XCTAssertTrue(DistantBasicSyncTests._fileManager.fileExistsAtPath(path))
            } else {
                XCTFail("Bad directive URL: \(directivesURL)")
            }
        }
    }
    
    
    // MARK: 3 - Run synchronization
    func test301_RunDirectives_UpToDistant() {
        let expectation = expectationWithDescription("Synchronize should success")
        let context = BsyncContext(sourceURL: DistantBasicSyncTests._upFolderURL!,
                                   andDestinationUrl: DistantBasicSyncTests._distantTreeURL,
                                   restrictedTo: BsyncDirectives.NO_HASHMAPVIEW)
        let admin = BsyncAdmin(context: context)
        do {
            try admin.synchronizeWithprogressBlock({ (taskIndex, totalTaskCount, taskProgress, message,data) in
                print("\(taskIndex)/\(totalTaskCount)")
            }) { (success, message) in
                print(message)
                expectation.fulfill()
            }
        } catch {
            XCTFail("Synchronize failed")
        }
        
        waitForExpectationsWithTimeout(5.0) { (error) in
            if let error = error {
                bprint(error.localizedDescription)
            }
        }
    }

    func test301_RunDirectives_DistantToDown() {
        let expectation = expectationWithDescription("Synchronize should success")
        let context = BsyncContext(sourceURL: DistantBasicSyncTests._distantTreeURL,
                                   andDestinationUrl: DistantBasicSyncTests._downFolderURL!,
                                   restrictedTo: BsyncDirectives.NO_HASHMAPVIEW)
        let admin = BsyncAdmin(context: context)
        do {
            try admin.synchronizeWithprogressBlock({ (taskIndex, totalTaskCount, taskProgress, message,data) in
                print("\(taskIndex)/\(totalTaskCount)")
            }) { (success, message) in
                print(message)
                expectation.fulfill()
            }
        } catch {
            XCTFail("Synchronize failed")
        }
        
        waitForExpectationsWithTimeout(5.0) { (error) in
            if let error = error {
                bprint(error.localizedDescription)
            }
        }
    }
}
