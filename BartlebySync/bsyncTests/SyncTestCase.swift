//
//  SyncTestCase.swift
//  bsync
//
//  Created by Martin Delille on 06/06/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation
import XCTest

/// Dummy synchronization class where the source and the destination are the same folder
class SyncTestCase : TestCase {
    
    var _sourceFolderPath = ""
    var _destinationFolderPath = ""
    
    override func setUp() {
        super.setUp()
        
        // Use the same folder for both source and destination folder
        _sourceFolderPath = assetPath
        _destinationFolderPath = assetPath
    }
    
    func prepareSync() {
        // Create folders
        do {
            try _fm.createDirectoryAtPath(_sourceFolderPath, withIntermediateDirectories: true, attributes: nil)
            try _fm.createDirectoryAtPath(_destinationFolderPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            XCTFail("\(error)")
            
        }
    }
    
    func disposeSync() {
        // Doing nothing
    }
    
    func sync(let handler: Handlers) {
        // Dummy sync doing nothing
        handler.on(Completion.successState())
    }
    
    func test001_preparation() {
        prepareSync()
    }
    
    let _fileName = "file.txt"
    let _fileContent1 = "first synchronization content"
    
    func test002_Add_single_file() {
        do {
            // Create file in up folder
            try _fileContent1.writeToFile(_sourceFolderPath + _fileName, atomically: true, encoding: Default.STRING_ENCODING)
            
            let expectation = expectationWithDescription("Synchronization should complete")
            
            // Perform synchronization
            sync(Handlers { (sync) in
                expectation.fulfill()
                XCTAssertTrue(sync.success, sync.message)
                
                // Check result is correct
                do {
                    // List files, excluding path starting with "." (like .bsync folder or prefinalization files if applicable)
                    let files = try self._fm.contentsOfDirectoryAtPath(self._destinationFolderPath).filter({ (filename) -> Bool in
                        return !filename.hasPrefix(".")
                    })
                    XCTAssertEqual(files, ["file.txt"])
                    let content = try String(contentsOfFile: self._destinationFolderPath + self._fileName)
                    XCTAssertEqual(content, self._fileContent1)
                } catch {
                    XCTFail("\(error)")
                }
                
                })
            
            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
            
        } catch {
            XCTFail("\(error)")
        }
    }
   
    let _fileContent2 = "second synchronization content"

    func test003_Edit_existing_file() {
        do {
            try _fileContent2.writeToFile(_sourceFolderPath + _fileName, atomically: true, encoding: Default.STRING_ENCODING)
            
            let expectation = expectationWithDescription("Synchronization should complete")

            // Perform synchronization
            sync(Handlers { (sync) in
                expectation.fulfill()
                XCTAssertTrue(sync.success, sync.message)
                
                // Check result is correct
                do {
                    // List files, excluding path starting with "." (like .bsync folder or prefinalization files if applicable)
                    let files = try self._fm.contentsOfDirectoryAtPath(self._destinationFolderPath).filter({ (filename) -> Bool in
                        return !filename.hasPrefix(".")
                    })
                    XCTAssertEqual(files, ["file.txt"])
                    let content = try String(contentsOfFile: self._destinationFolderPath + self._fileName)
                    XCTAssertEqual(content, self._fileContent2)
                } catch {
                    XCTFail("\(error)")
                }
            })
            
            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)

        } catch {
            XCTFail("\(error)")
        }
    }
    
    let _newFileName = "newfile.txt"

    func test004_Move_existing_file() {
        do {
            try _fm.moveItemAtPath(_sourceFolderPath + _fileName, toPath: _sourceFolderPath + _newFileName)
            
            let expectation = expectationWithDescription("Synchronization should complete")
            
            // Perform synchronization
            sync(Handlers { (sync) in
                expectation.fulfill()
                XCTAssertTrue(sync.success, sync.message)
                
                // Check result is correct
                do {
                    // List files, excluding path starting with "." (like .bsync folder or prefinalization files if applicable)
                    let files = try self._fm.contentsOfDirectoryAtPath(self._destinationFolderPath).filter({ (filename) -> Bool in
                        return !filename.hasPrefix(".")
                    })
                    XCTAssertEqual(files, ["newfile.txt"])
                    let content = try String(contentsOfFile: self._destinationFolderPath + self._newFileName)
                    XCTAssertEqual(content, self._fileContent2)
                } catch {
                    XCTFail("\(error)")
                }
                })
            
            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
            

        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test005_Add_files_in_subfolder() {
        do {
            let _subFileCount = 4
            let _subFileContent = "sub file content"
            
            let subFolderPath = _sourceFolderPath + "sub/"
            try _fm.createDirectoryAtPath(subFolderPath, withIntermediateDirectories: true, attributes: nil)
            
            for i in 1..._subFileCount {
                let filePath = subFolderPath + "file\(i).txt"
                let content = _subFileContent + "\(i)"
                try content.writeToFile(filePath, atomically: true, encoding: Default.STRING_ENCODING)
            }
            
            let expectation = expectationWithDescription("Synchronization should complete")
            
            // Perform synchronization
            sync(Handlers { (sync) in
                expectation.fulfill()
                XCTAssertTrue(sync.success, sync.message)
                
                // Check result is correct
                do {
                    // List files, excluding path starting with "." (like .bsync folder or prefinalization files if applicable)
                    let files = try self._fm.contentsOfDirectoryAtPath(self._destinationFolderPath).filter({ (filename) -> Bool in
                        return !filename.hasPrefix(".")
                    })
                    XCTAssertEqual(files, ["newfile.txt", "sub"])
                    // Check root file content
                    let content = try String(contentsOfFile: self._destinationFolderPath + self._newFileName)
                    XCTAssertEqual(content, self._fileContent2)
                    // Check subfolder
                    let subFolderPath = self._destinationFolderPath + "sub/"
                    let subFiles = try self._fm.contentsOfDirectoryAtPath(subFolderPath)
                    XCTAssertEqual(subFiles.count, _subFileCount)
                    
                    for i in 1..._subFileCount {
                        XCTAssertEqual(subFiles[i - 1], "file\(i).txt")
                        let subContent = try String(contentsOfFile: subFolderPath + subFiles[i - 1])
                        XCTAssertEqual(subContent, _subFileContent + "\(i)")
                    }
                } catch {
                    XCTFail("\(error)")
                }
                })
            
            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
            
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test006_Move_and_copy_existing_file() {
        do {
            try _fm.moveItemAtPath(_sourceFolderPath + _newFileName, toPath: _sourceFolderPath + _fileName)
            try _fm.copyItemAtPath(_sourceFolderPath + _fileName, toPath: _sourceFolderPath + "sub/" + _fileName)
            
            let expectation = expectationWithDescription("Synchronization should complete")
            
            // Perform synchronization
            sync(Handlers { (sync) in
                expectation.fulfill()
                XCTAssertTrue(sync.success, sync.message)
                
                // Check result is correct
                do {
                    // List files, excluding path starting with "." (like .bsync folder or prefinalization files if applicable)
                    let files = try self._fm.contentsOfDirectoryAtPath(self._destinationFolderPath).filter({ (filename) -> Bool in
                        return !filename.hasPrefix(".")
                    })
                    XCTAssertEqual(files, ["file.txt", "sub"])
                    // Check root file content
                    let content1 = try String(contentsOfFile: self._destinationFolderPath + self._fileName)
                    XCTAssertEqual(content1, self._fileContent2)
                    // Check copied file content
                    let content2 = try String(contentsOfFile: self._destinationFolderPath + "sub/" + self._fileName)
                    XCTAssertEqual(content2, self._fileContent2)
                } catch {
                    XCTFail("\(error)")
                }
                })
            
            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)

        } catch {
            XCTFail("\(error)")
        }
    }
    
    // MARK 9 - Cleaning
    func test009_Remove_all_files() {
        do {
            try _fm.removeItemAtPath(_sourceFolderPath + _fileName)
            let subFolderPath = _sourceFolderPath + "sub/"
            if _fm.fileExistsAtPath(subFolderPath) {
                try _fm.removeItemAtPath(subFolderPath)
            }
            
            
            let expectation = expectationWithDescription("Synchronization should complete")
            
            // Perform synchronization
            sync(Handlers { (sync) in
                expectation.fulfill()
                XCTAssertTrue(sync.success, sync.message)
                
                // Check result is correct
                do {
                    // List files, excluding path starting with "." (like .bsync folder or prefinalization files if applicable)
                    let files = try self._fm.contentsOfDirectoryAtPath(self._destinationFolderPath).filter({ (filename) -> Bool in
                        return !filename.hasPrefix(".")
                    })
                    XCTAssertEqual(files, [])
                } catch {
                    XCTFail("\(error)")
                }
                })
            
            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test999_Dispose_sync() {
        disposeSync()
    }
}
