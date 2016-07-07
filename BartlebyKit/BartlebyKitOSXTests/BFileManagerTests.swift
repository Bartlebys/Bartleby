//
//  BFileManagerTests.swift
//  BartlebyKit
//
//  Created by Martin Delille on 06/05/2016.
//
//

import XCTest
import BartlebyKit

class BFileManagerTests: TestCase {


    let fm = BFileManager(onQueue:dispatch_get_main_queue())

    static let folder = BFileManagerTests.assetPath + Bartleby.randomStringWithLength(6) + "/"


    func test100_folder_should_not_exists() {

        // Checking no items (directory or file) exists
        let directoryShouldNotExist = self.expectationWithDescription("Directory should not exist")
        self.fm.directoryExistsAtPath(BFileManagerTests.folder,
                                      handlers: Handlers { (existence) in
                                        directoryShouldNotExist.fulfill()
                                        XCTAssertFalse(existence.success)
                                        XCTAssertEqual(404, existence.statusCode)
        })
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }


}
