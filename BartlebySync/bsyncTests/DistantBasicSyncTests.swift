//
//  DistantBasicSyncTests.swift
//  bsync
//
//  Created by Martin Delille on 05/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class DistantBasicSyncTests: XCTestCase {
    private static let _fileManager = NSFileManager()

    private static let _treeName = Bartleby.randomStringWithLength(6)
    private static let _upFolderPath = NSTemporaryDirectory() + _treeName
    private static let _upFolderURL = NSURL(fileURLWithPath: _upFolderPath)
    private static let _filePath = _upFolderPath + "/file.txt"
    private static let _fileContent = Bartleby.randomStringWithLength(20)
    
    private static let _apiUrl = TestConfiguration.API_BASE_URL.URLByAppendingPathComponent("BartlebySync")
    private static let _distantTreeURL = _apiUrl.URLByAppendingPathComponent("tree/\(_treeName)")

    // MARK: 1 - Prepare folder and directives
    func test101_CreateFileInUpFolder() {
        do {
            try DistantBasicSyncTests._fileManager.createDirectoryAtPath(DistantBasicSyncTests._upFolderPath, withIntermediateDirectories: false, attributes: nil)
            try DistantBasicSyncTests._fileContent.writeToFile(DistantBasicSyncTests._filePath, atomically: false, encoding: NSUTF8StringEncoding)
            XCTAssertTrue(DistantBasicSyncTests._fileManager.fileExistsAtPath(DistantBasicSyncTests._filePath))
            let fileContent = try String(contentsOfFile: DistantBasicSyncTests._filePath, encoding: NSUTF8StringEncoding)
            XCTAssertEqual(DistantBasicSyncTests._fileContent, fileContent)
        } catch {
            XCTFail("File I/O error with \(DistantBasicSyncTests._filePath)")
        }
    }
    
    func test102_CreateDirectives() {
        let directives = BsyncDirectives()
        directives.sourceURL = DistantBasicSyncTests._upFolderURL
        directives.destinationURL = DistantBasicSyncTests._distantTreeURL
        
        let directivesURL = DistantBasicSyncTests._upFolderURL.URLByAppendingPathComponent(BsyncDirectives.DEFAULT_FILE_NAME, isDirectory: false)
        BsyncAdmin.createDirectives(directives, saveTo: directivesURL)
        if let path = directivesURL.path {
            XCTAssertTrue(DistantBasicSyncTests._fileManager.fileExistsAtPath(path))
        } else {
            XCTFail("Bad directive URL: \(directivesURL)")
        }
    }
    
    // MARK: 2 - Run synchronization
    func test201_RunDirectives() {
        let expectation = expectationWithDescription("Synchronize should success")
        let context = BsyncContext(sourceURL: DistantBasicSyncTests._upFolderURL,
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
    
}
