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
    
    private var _treeName = ""
    private var _upFolderPath = ""
    private var _upFilePath = ""
    private var _fileContent1 = ""
    private var _fileContent2 = ""
    
    private var _distantTreeURL = NSURL()
    
    private var _downFolderPath = ""
    private var _downFilePath = ""
    
    private static var _upDirectives = BsyncDirectives()
    private static var _downDirectives = BsyncDirectives()
    
    override func setUp() {
        super.setUp()
        
        _upFolderPath = assetPath + "Up/"
        _upFilePath = _upFolderPath + "file.txt"
        _fileContent1 = "first synchronization content"
        _fileContent2 = "second synchronization content"
        
        _distantTreeURL = TestsConfiguration.API_BASE_URL.URLByAppendingPathComponent("BartlebySync/tree/\(testName)")
        
        _downFolderPath = assetPath + "Down/"
        _downFilePath = _downFolderPath + "file.txt"
    }
    
    // MARK: 1 - Setup
    func test101_Create_user_and_directives() {
        let expectation = expectationWithDescription("Create user")
        
        let user = createUser(spaceUID, handlers: Handlers { (creation) in
            XCTAssert(creation.success, creation.message)
            expectation.fulfill()
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        
        // Create upstream directives
        let upDirectives = BsyncDirectives.upStreamDirectivesWithDistantURL(_distantTreeURL, localPath: _upFolderPath)
        upDirectives.automaticTreeCreation = true
        // Credentials:
        upDirectives.user = user
        upDirectives.password = user.password
        upDirectives.salt = TestsConfiguration.SHARED_SALT
        
        UpDownDirectivesTests._upDirectives = upDirectives
        
        // Create downstream directives
        let downDirectives = BsyncDirectives.downStreamDirectivesWithDistantURL(_distantTreeURL, localPath: _downFolderPath)
        downDirectives.automaticTreeCreation = true
        
        // Credentials:
        downDirectives.user = user
        downDirectives.password = user.password
        downDirectives.salt = TestsConfiguration.SHARED_SALT
        
        UpDownDirectivesTests._downDirectives = downDirectives
        
        // Create folders
        do {
            try _fm.createDirectoryAtPath(_upFolderPath, withIntermediateDirectories: true, attributes: nil)
            try _fm.createDirectoryAtPath(_downFolderPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            XCTFail("\(error)")
            
        }
    }
    
    // MARK: 2 - Add single file and sync
    func test201_Create_file_in_up_folder() {
        do {
            // Create file in up folder
            try _fileContent1.writeToFile(_upFilePath, atomically: true, encoding: Default.STRING_ENCODING)
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
            let files = try _fm.contentsOfDirectoryAtPath(_downFolderPath)
            XCTAssertEqual(files, [".bsync", "file.txt"])
            let content = try String(contentsOfFile: _downFilePath)
            XCTAssertEqual(content, _fileContent1)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    // MARK: 3 - Edit and synchronize
    func test301_Edit_existing_file() {
        do {
            try _fileContent2.writeToFile(_upFilePath, atomically: true, encoding: Default.STRING_ENCODING)
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
            let files = try _fm.contentsOfDirectoryAtPath(_downFolderPath)
            XCTAssertEqual(files, [".bsync", "file.txt"])
            let content = try String(contentsOfFile: _downFilePath)
            XCTAssertEqual(content, _fileContent2)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    // MARK 6 - Add files in subfolder and synchronize
    private let _subFileCount = 4
    private let _subFileContent = "sub file content"
    
    func test601_Add_files_in_subfolder() {
        do {
            let subFolderPath = _upFolderPath + "sub/"
            try _fm.createDirectoryAtPath(subFolderPath, withIntermediateDirectories: true, attributes: nil)
            
            for i in 1..._subFileCount {
                let filePath = subFolderPath + "file\(i).txt"
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
            let files = try _fm.contentsOfDirectoryAtPath(_downFolderPath)
            XCTAssertEqual(files, [".bsync", "file.txt", "sub"])
            // Check root file content
            let content = try String(contentsOfFile: _downFilePath)
            XCTAssertEqual(content, _fileContent2)
            // Check subfolder
            let subFolderPath = _downFolderPath + "sub/"
            let subFiles = try _fm.contentsOfDirectoryAtPath(subFolderPath)
            XCTAssertEqual(subFiles.count, _subFileCount)
            
            for i in 1..._subFileCount {
                XCTAssertEqual(subFiles[i - 1], "file\(i).txt")
                let subContent = try String(contentsOfFile: subFolderPath + subFiles[i - 1])
                XCTAssertEqual(subContent, _subFileContent + "\(i)")
            }
        } catch {
            XCTFail("\(error)")
        }
    }
    
    // MARK 9 - Cleaning
    func test901_Remove_all_files() {
        do {
            try _fm.removeItemAtPath(_upFilePath)
            try _fm.removeItemAtPath(_upFolderPath + "sub/")
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
            let files = try _fm.contentsOfDirectoryAtPath(_downFolderPath)
            XCTAssertEqual(files, [".bsync"])
        } catch {
            XCTFail("\(error)")
        }
    }
    
}
