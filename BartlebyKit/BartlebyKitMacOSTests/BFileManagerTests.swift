//
//  BFileManagerTests.swift
//  BartlebyKit
//
//  Created by Martin Delille on 06/05/2016.
//
//

import BartlebyKit
import XCTest

class BFileManagerTests: TestCase {
    let fm = BFileManager()

    static let folder = BFileManagerTests.assetPath + Bartleby.randomStringWithLength(6) + "/"

    func test100_folder_should_not_exists() {
        // Checking no items (directory or file) exists
        let directoryShouldNotExist = expectation(description: "Directory should not exist")
        fm.directoryExistsAtPath(BFileManagerTests.folder,
                                 handlers: Handlers { existence in
                                     directoryShouldNotExist.fulfill()
                                     XCTAssertFalse(existence.success)
                                     XCTAssertEqual(404, existence.statusCode)
        })
        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
}
