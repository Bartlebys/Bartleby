//
//  LocalSyncTests.swift
//  bsync
//
//  Created by Martin Delille on 28/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class LocalSyncTests: XCTestCase {
    
    private static let _diskManager = BsyncImageDiskManager()
    private static let _fileManager = NSFileManager()
    
    private static let _treeName = "LocalSyncTests"
    private static let _folderPath = TestsConfiguration.ASSET_PATH + "LocalSyncTests/"
    private static let _sourceFolderPath = _folderPath + "Source/" + _treeName + "/"
    private static let _sourceFilePath = _sourceFolderPath + "file.txt"
    private static let _fileContent = Bartleby.randomStringWithLength(20)
    
    private static let _destinationFolderPath = _folderPath + "Destination/" + _treeName + "/"
    private static let _destinationFilePath = _destinationFolderPath + "file.txt"
    
    private static let _directivesPath = _sourceFolderPath + BsyncDirectives.DEFAULT_FILE_NAME
        
    // MARK: 1 - Prepare folder and directives
    func test101_CreateFileInUpFolder() {
        let expectation = expectationWithDescription("All files should be created")
        
        let fm = BFileManager()
        
        // Remove whole folder
        fm.removeItemAtPath(LocalSyncTests._folderPath, handlers: Handlers { (remove) in
            // Create down folder
            fm.createDirectoryAtPath(LocalSyncTests._destinationFolderPath, handlers: Handlers { (destinationFolderCreation) in
                XCTAssert(destinationFolderCreation.success, destinationFolderCreation.message)
                // Create up folder
                fm.createDirectoryAtPath(LocalSyncTests._sourceFolderPath, handlers: Handlers { (sourceFolderCreation) in
                    XCTAssertTrue(sourceFolderCreation.success, sourceFolderCreation.message)
                    // Create file
                    fm.writeString(LocalSyncTests._fileContent, path: LocalSyncTests._sourceFilePath, handlers: Handlers { (fileCreation) in
                        XCTAssertTrue(fileCreation.success, fileCreation.message)
                        expectation.fulfill()
                        })
                    })
                })
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint(error?.localizedDescription, file: #file, function: #function, line: #line)
        }
    }
    
    func test102_CreateDirectives() {
        let directives = BsyncDirectives.localDirectivesWithPath(LocalSyncTests._sourceFolderPath, destinationPath: LocalSyncTests._destinationFolderPath)
        directives.automaticTreeCreation = true
        
        let admin = BsyncAdmin()
        do {
            try admin.saveDirectives(directives, path: LocalSyncTests._directivesPath)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    
    // MARK: Run synchronization
    func test201_RunSynchronisation() {
        let expectation = expectationWithDescription("Synchronize should complete")
        
        do {
            let admin = BsyncAdmin()
            let directives = try admin.loadDirectives(LocalSyncTests._directivesPath)
            admin.runDirectives(directives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: Handlers { (completion) in
                expectation.fulfill()
                XCTAssertTrue(completion.success, completion.message)
                })
            
        } catch {
            XCTFail("\(error)")
        }
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint(error?.localizedDescription, file: #file, function: #function, line: #line)
        }
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
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint(error?.localizedDescription, file: #file, function: #function, line: #line)
        }
    }
}
