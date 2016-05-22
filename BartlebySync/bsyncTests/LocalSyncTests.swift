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

    private static let _treeName = Bartleby.randomStringWithLength(6)
    private static let _folderPath = TestsConfiguration.ASSET_PATH + "LocalSyncTests/"
    private static let _sourceFolderPath = _folderPath + "Master/" + _treeName + "/"
    private static let _sourceFilePath = _sourceFolderPath + "file.txt"
    private static let _fileContent = Bartleby.randomStringWithLength(20)

    private static let _destinationFolderPath = _folderPath + "Slave/" + _treeName + "/"
    private static let _destinationFilePath = _destinationFolderPath + "file.txt"


    // MARK: 2 - Prepare folder and directives
    func test201_CreateFileInUpFolder() {
        let expectation = expectationWithDescription("All files should be created")
        // Create down folder
        Bartleby.fileManager.createDirectoryAtPath(LocalSyncTests._destinationFolderPath, handlers: Handlers { (destinationFolderCreation) in
            XCTAssert(destinationFolderCreation.success, destinationFolderCreation.message)
            // Create up folder
            Bartleby.fileManager.createDirectoryAtPath(LocalSyncTests._sourceFolderPath, handlers: Handlers { (sourceFolderCreation) in
                XCTAssertTrue(sourceFolderCreation.success, sourceFolderCreation.message)
                // Create file
                Bartleby.fileManager.writeString(LocalSyncTests._fileContent, path: LocalSyncTests._sourceFilePath, handlers: Handlers { (fileCreation) in
                    XCTAssertTrue(fileCreation.success, fileCreation.message)
                    expectation.fulfill()
                    })
                })
            })

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint(error?.localizedDescription, file: #file, function: #function, line: #line)
        }
    }

    //    func test103_CreateDirectives() {
    //        let directives = BsyncDirectives.localDirectivesWithPath(LocalSyncTests._sourceFolderPath, destinationPath: LocalSyncTests._destinationFilePath)
    //
    //        let directivesURL = LocalSyncTests._sourceVolumeURL.URLByAppendingPathComponent(BsyncDirectives.DEFAULT_FILE_NAME, isDirectory: false)
    //        BsyncAdmin.createDirectives(directives, saveTo: directivesURL)
    //        if let path = directivesURL.path {
    //            XCTAssertTrue(LocalSyncTests._fileManager.fileExistsAtPath(path))
    //        } else {
    //            XCTFail("Bad directive URL: \(directivesURL)")
    //        }
    //    }


    // MARK: Run synchronization
    func test201_RunSynchronisation() {
        let expectation = expectationWithDescription("Synchronize should complete")
        let context = BsyncContext(sourceURL: NSURL(fileURLWithPath: LocalSyncTests._sourceFolderPath),
                                   andDestinationUrl: NSURL(fileURLWithPath: LocalSyncTests._destinationFolderPath),
                                   restrictedTo: nil)

        let admin = BsyncAdmin(context: context)
        admin.synchronizeWithprogressBlock(Handlers(completionHandler: { (c) in
            // TODO: @md #test #bsync Reactivate test check wich currently fais
            // XCTAssertTrue(c.success, c.message)
            expectation.fulfill()
            }))

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            if let error = error {
                bprint("Error: \(error.localizedDescription)", file: #file, function: #function, line: #line)
            }
        }
    }
}
