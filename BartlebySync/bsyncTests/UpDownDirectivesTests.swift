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


class UpDownDirectivesTests: SyncTestCase {
    
    private static var _spaceUID = ""
    private static var _user: User?
    
    private static var _treeName = ""
    private static var _upFolderPath = ""
    private static var _upFilePath = ""
    private static var _fileContent1 = ""
    private static var _fileContent2 = ""
    
    private static var _distantTreeURL = NSURL()
    
    private static var _downFolderPath = ""
    private static var _downFilePath = ""
    
    private static var _upDirectives = BsyncDirectives()
    private static var _downDirectives = BsyncDirectives()
    
    override class func setUp() {
        super.setUp()
        
        _spaceUID = Bartleby.createUID()
        
        _treeName = NSStringFromClass(self)

        _upFolderPath = assetPath + "Up/"
        _upFilePath = _upFolderPath + "file.txt"
        _fileContent1 = "first synchronization content"
        _fileContent2 = "second synchronization content"
        
        _distantTreeURL = TestsConfiguration.API_BASE_URL.URLByAppendingPathComponent("BartlebySync/tree/\(_treeName)")
        
        _downFolderPath = assetPath + "Down/"
        _downFilePath = _downFolderPath + "file.txt"
    }
    
    // MARK: 1 - Create user and directives
    func test101_Create_user() {
        let expectation = expectationWithDescription("CreateUser should respond")
        
        let user=User()
        user.creatorUID=user.UID // (!) Auto creation in this context (Check ACL)
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
    
    func test102_Create_upstream_directives() {
        UpDownDirectivesTests._upDirectives = BsyncDirectives.upStreamDirectivesWithDistantURL(UpDownDirectivesTests._distantTreeURL, localPath: UpDownDirectivesTests._upFolderPath)
        UpDownDirectivesTests._upDirectives.automaticTreeCreation = true
        // Credentials:
        UpDownDirectivesTests._upDirectives.user = UpDownDirectivesTests._user
        UpDownDirectivesTests._upDirectives.password = UpDownDirectivesTests._user?.password
        UpDownDirectivesTests._upDirectives.salt = TestsConfiguration.SHARED_SALT
        // Create up folder
        do {
            try _fm.createDirectoryAtPath(UpDownDirectivesTests._upFolderPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            XCTFail("\(error)")
            
        }
    }
    
    func test103_Create_downstream_directives() {
        UpDownDirectivesTests._downDirectives = BsyncDirectives.downStreamDirectivesWithDistantURL(UpDownDirectivesTests._distantTreeURL, localPath: UpDownDirectivesTests._downFolderPath)
        UpDownDirectivesTests._downDirectives.automaticTreeCreation = true
        
        // Credentials:
        UpDownDirectivesTests._downDirectives.user = UpDownDirectivesTests._user
        UpDownDirectivesTests._downDirectives.password = UpDownDirectivesTests._user?.password
        UpDownDirectivesTests._downDirectives.salt = TestsConfiguration.SHARED_SALT
        // Create down folder
        do {
            try _fm.createDirectoryAtPath(UpDownDirectivesTests._downFolderPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            XCTFail("\(error)")
            
        }
    }
    
    // MARK: 2 - Add single file and sync
    func test201_Create_file_in_up_folder() {
        do {
            // Create file in up folder
            try UpDownDirectivesTests._fileContent1.writeToFile(UpDownDirectivesTests._upFilePath, atomically: true, encoding: Default.STRING_ENCODING)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test202_Run_synchronization() {
        let expectation = expectationWithDescription("Synchronization should complete")
        
        self.runUpDownSynchronization(UpDownDirectivesTests._upDirectives, downDirectives: UpDownDirectivesTests._downDirectives, handlers: Handlers { (sync) in
            expectation.fulfill()
            XCTAssertTrue(sync.success, sync.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test203_Check_file_has_been_created_in_down_folder() {
        do {
            let files = try _fm.contentsOfDirectoryAtPath(UpDownDirectivesTests._downFolderPath)
            XCTAssertEqual(files, [".bsync", "file.txt"])
            let content = try String(contentsOfFile: UpDownDirectivesTests._downFilePath)
            XCTAssertEqual(content, UpDownDirectivesTests._fileContent1)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    // MARK: 3 - Edit and synchronize
    func test301_Edit_existing_file() {
        do {
            try UpDownDirectivesTests._fileContent2.writeToFile(UpDownDirectivesTests._upFilePath, atomically: true, encoding: Default.STRING_ENCODING)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test302_Run_synchronization() {
        let expectation = expectationWithDescription("Synchronization should complete")
        
        self.runUpDownSynchronization(UpDownDirectivesTests._upDirectives, downDirectives: UpDownDirectivesTests._downDirectives, handlers: Handlers { (sync) in
            expectation.fulfill()
            XCTAssertTrue(sync.success, sync.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test303_Check_file_has_been_modified() {
        do {
            let files = try _fm.contentsOfDirectoryAtPath(UpDownDirectivesTests._downFolderPath)
            XCTAssertEqual(files, [".bsync", "file.txt"])
            let content = try String(contentsOfFile: UpDownDirectivesTests._downFilePath)
            XCTAssertEqual(content, UpDownDirectivesTests._fileContent2)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    // MARK 6 - Add files in subfolder and synchronize
    private static let _upSubFolderPath = _upFolderPath + "sub/"
    private static let _downSubFolderPath = _downFolderPath + "sub/"
    private let _subFileCount = 4
    private let _subFileContent = "sub file content"
    
    func test601_Add_files_in_subfolder() {
        do {
            try _fm.createDirectoryAtPath(UpDownDirectivesTests._upSubFolderPath, withIntermediateDirectories: true, attributes: nil)
            
            for i in 1..._subFileCount {
                let filePath = UpDownDirectivesTests._upSubFolderPath + "file\(i).txt"
                let content = _subFileContent + "\(i)"
                try content.writeToFile(filePath, atomically: true, encoding: Default.STRING_ENCODING)
            }
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test602_Run_synchronization() {
        let expectation = expectationWithDescription("Synchronization should complete")
        
        self.runUpDownSynchronization(UpDownDirectivesTests._upDirectives, downDirectives: UpDownDirectivesTests._downDirectives, handlers: Handlers { (sync) in
            expectation.fulfill()
            XCTAssertTrue(sync.success, sync.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test604_Check_files_have_been_created() {
        do {
            // Check root folder
            let files = try _fm.contentsOfDirectoryAtPath(UpDownDirectivesTests._downFolderPath)
            XCTAssertEqual(files, [".bsync", "file.txt", "sub"])
            // Check root file content
            let content = try String(contentsOfFile: UpDownDirectivesTests._downFilePath)
            XCTAssertEqual(content, UpDownDirectivesTests._fileContent2)
            // Check subfolder
            let subFiles = try _fm.contentsOfDirectoryAtPath(UpDownDirectivesTests._downSubFolderPath)
            XCTAssertEqual(subFiles.count, _subFileCount)
            
            for i in 1..._subFileCount {
                XCTAssertEqual(subFiles[i - 1], "file\(i).txt")
                let subContent = try String(contentsOfFile: UpDownDirectivesTests._downSubFolderPath + subFiles[i - 1])
                XCTAssertEqual(subContent, _subFileContent + "\(i)")
            }
        } catch {
            XCTFail("\(error)")
        }
    }
    
    // MARK 9 - Cleaning
    func test901_Remove_all_files() {
        do {
            try _fm.removeItemAtPath(UpDownDirectivesTests._upFilePath)
            try _fm.removeItemAtPath(UpDownDirectivesTests._upSubFolderPath)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test902_Run_synchronization() {
        let expectation = expectationWithDescription("Synchronization should complete")
        
        self.runUpDownSynchronization(UpDownDirectivesTests._upDirectives, downDirectives: UpDownDirectivesTests._downDirectives, handlers: Handlers { (sync) in
            expectation.fulfill()
            XCTAssertTrue(sync.success, sync.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test903_Check_file_has_been_modified() {
        do {
            let files = try _fm.contentsOfDirectoryAtPath(UpDownDirectivesTests._downFolderPath)
            XCTAssertEqual(files, [".bsync"])
        } catch {
            XCTFail("\(error)")
        }
    }
    
}
