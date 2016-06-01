//
//  LocalSyncTests.swift
//  bsync
//
//  Created by Martin Delille on 28/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class LocalSyncTests: TestCase {
    
    private static let _diskManager = BsyncImageDiskManager()
    private static let _fileManager = NSFileManager()
    
    private static let _treeName = "LocalSyncTests"
    private static let _sourceFolderPath = assetPath + "Source/" + _treeName + "/"
    private static let _sourceFilePath = _sourceFolderPath + "file.txt"
    private static let _fileContent1 = "dummy content"
    private static let _fileContent2 = "super content"
    
    private static let _destinationFolderPath = assetPath + "Destination/" + _treeName + "/"
    private static let _destinationFilePath = _destinationFolderPath + "file.txt"
    
    private static var _directives = BsyncDirectives()
    
    // MARK: 1 - Prepare folder and directives
    func test101_Create_file_in_source_folder() {
        do {
            
            // Create source folder
            try _fm.createDirectoryAtPath(LocalSyncTests._sourceFolderPath, withIntermediateDirectories: true, attributes: nil)
            // Create file
            try LocalSyncTests._fileContent1.writeToFile(LocalSyncTests._sourceFilePath, atomically: true, encoding: Default.STRING_ENCODING)
            // Create destination folder
            try _fm.createDirectoryAtPath(LocalSyncTests._destinationFolderPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test102_Create_directives() {
        LocalSyncTests._directives = BsyncDirectives.localDirectivesWithPath(LocalSyncTests._sourceFolderPath, destinationPath: LocalSyncTests._destinationFolderPath)
    }
    
    // MARK: 2 - Run synchronization
    func test201_Run_synchronization() {
        let expectation = expectationWithDescription("Synchronize should complete")
        
        let admin = BsyncAdmin()
        admin.runDirectives(LocalSyncTests._directives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: Handlers { (sync) in
            expectation.fulfill()
            XCTAssertTrue(sync.success, sync.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test202_Check_file_has_been_synchronized() {
        do {
            let content = try String(contentsOfFile: LocalSyncTests._destinationFilePath)
            XCTAssertEqual(content, LocalSyncTests._fileContent1)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    // MARK: 3 - Edit file and synchronize
    
    func test301_Edit_existing_file() {
        do {
            try LocalSyncTests._fileContent2.writeToFile(LocalSyncTests._sourceFilePath, atomically: true, encoding: Default.STRING_ENCODING)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test302_Run_synchronization() {
        let expectation = expectationWithDescription("Synchronize should complete")
        
        let admin = BsyncAdmin()
        admin.runDirectives(LocalSyncTests._directives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: Handlers { (sync) in
            expectation.fulfill()
            XCTAssertTrue(sync.success, sync.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test303_Check_file_has_been_modified() {
        do {
            let content = try String(contentsOfFile: LocalSyncTests._destinationFilePath)
            XCTAssertEqual(content, LocalSyncTests._fileContent2)
        } catch {
            XCTFail("\(error)")
        }
    }
}
