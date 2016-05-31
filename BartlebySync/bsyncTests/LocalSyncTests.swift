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
    private static let _fileContent = "dummy content"
    
    private static let _destinationFolderPath = assetPath + "Destination/" + _treeName + "/"
    private static let _destinationFilePath = _destinationFolderPath + "file.txt"
    
    private static var _directives = BsyncDirectives()
    
    // MARK: 1 - Prepare folder and directives
    func test101_CreateFileInUpFolder() {
        do {
            
            // Create source folder
            try _fm.createDirectoryAtPath(LocalSyncTests._sourceFolderPath, withIntermediateDirectories: true, attributes: nil)
            // Create file
            try LocalSyncTests._fileContent.writeToFile(LocalSyncTests._sourceFilePath, atomically: true, encoding: Default.STRING_ENCODING)
            // Create destination folder
            try _fm.createDirectoryAtPath(LocalSyncTests._destinationFolderPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test102_CreateDirectives() {
        LocalSyncTests._directives = BsyncDirectives.localDirectivesWithPath(LocalSyncTests._sourceFolderPath, destinationPath: LocalSyncTests._destinationFolderPath)
    }
    
    // MARK: Run synchronization
    func test201_RunSynchronisation() {
        let expectation = expectationWithDescription("Synchronize should complete")
        
        let admin = BsyncAdmin()
        admin.runDirectives(LocalSyncTests._directives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: Handlers { (completion) in
            expectation.fulfill()
            XCTAssertTrue(completion.success, completion.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test202_CheckFileHasBeenSynchronized() {
        let expectation = expectationWithDescription("Read destination file")
        let fm = BFileManager()
        fm.readString(contentsOfFile: LocalSyncTests._destinationFilePath, handlers: Handlers { (read) in
            expectation.fulfill()
            if let content = read.getStringResult() where read.success {
                XCTAssertEqual(content, LocalSyncTests._fileContent)
            } else {
                XCTFail(read.message)
            }
            
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
}
