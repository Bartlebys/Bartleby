//
//  bsyncDirectivesTests.swift
//  bsync
//
//  Created by Benoit Pereira da silva on 01/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class bsyncDirectivesTests: XCTestCase {
    
    func test001_create_directives(){
        let expectation = expectationWithDescription("create a directive file")
        let fsm = NSFileManager()
        let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory() + Bartleby.randomStringWithLength(6))
        do {
            try fsm.createDirectoryAtURL(folderURL, withIntermediateDirectories: true, attributes: nil)
            let sourceURL=TestConfiguration.distantTestTreeUrl
            let directives = BsyncDirectives.upStreamDirectivesWithDistantURL(sourceURL, localURL: folderURL, creativeKey: TestConfiguration.creativeKey)
            BsyncAdmin.createDirectives(directives, saveTo: folderURL.URLByAppendingPathComponent(BsyncDirectives.DEFAULT_FILE_NAME, isDirectory: false))
            let fsm=NSFileManager()
            if fsm.fileExistsAtPath(folderURL.path!){
                expectation.fulfill()
            }
            waitForExpectationsWithTimeout(1.0){ error -> Void in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        } catch {
            XCTFail("\(error)")
        }
    }
}
