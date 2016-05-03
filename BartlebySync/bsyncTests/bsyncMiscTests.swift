//
//  bsyncTests.swift
//  bsyncTests
//
//  Created by Benoit Pereira da silva on 01/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class bsyncMiscTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    // Void >Test to validate that the Test class can be compiled
    func test000_void() {
        let result=true
        XCTAssertTrue(result)
    }


    func test001_DMG_create_attach_detach() {
        let expectation = expectationWithDescription("DMG_create_attach_detach")
        let m=BsyncImageDiskManager()
        do {
            if try m.createImageDisk("\(NSHomeDirectory())/Desktop/blabla", volumeName: "Project 1 Synchronized", size: "2g", password: "gugu") {
                if try m.attachVolume(from:m.createdDmg!, withPassword: "gugu") {
                    if try m.detachVolume("Project 1 Synchronized") {
                        // OK !
                        do {
                            try NSFileManager.defaultManager().removeItemAtPath(m.createdDmg!)
                            expectation.fulfill()
                        } catch {
                            XCTFail("Deletion of \(m.createdDmg!) failure")
                        }
                    } else {
                        XCTFail("Detach failure")
                    }
                } else {
                    XCTFail("Attach failure")
                }
            } else {
                XCTFail("Creation failure")
            }
        } catch {
            XCTFail("Creation failure \(error)")
        }

        // This test is very long
        waitForExpectationsWithTimeout(20.0) { error -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }

    }

    func test002_hash_sample_folder() {

        let expectation = expectationWithDescription("hash_sample_folder")

        var analyzer=BsyncLocalAnalyzer()
        analyzer.saveHashInAFile=false
        analyzer.recomputeHash=true

        let startTime = CFAbsoluteTimeGetCurrent()

        if let url=NSURL(string: "file://\(NSHomeDirectory())/Desktop/UnitTestSamples/") {

            let fsm=NSFileManager()
            if !fsm.fileExistsAtPath(url.path!) {
                do {
                    try fsm.createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
                    try fsm.createDirectoryAtURL(url.URLByAppendingPathComponent("subfolder"), withIntermediateDirectories: true, attributes: nil)

                } catch {
                    XCTFail("Creation of \(url.path) failure \(error)")
                }
            }

            for i in 1...20 {
                let s=randomStringWithLength(i*1024)
                let surl=(i>10 ? url.URLByAppendingPathComponent("subfolder/\(i).data") : url.URLByAppendingPathComponent("\(i).data"))
                do {
                    try s.writeToURL(surl,
                        atomically: false, encoding: Default.TEXT_ENCODING)
                } catch {
                    XCTFail("Creation of \(surl.path) failure \(error)")
                }
            }

            let path=url.path!
             do {
                try analyzer.createHashMapFromLocalPath(path, progressBlock: { (hash, path, index) -> Void in
                        print("\(index)# Hash of \(path) is \(hash)")
                    }, completionBlock: { (hashMap) -> Void in
                        let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
                        print ("elapsed time \(elapsedTime)")
                        do {
                            try fsm.removeItemAtURL(url)
                        } catch {
                            XCTFail("Deletion of folder \(url)failure \(error)")
                        }
                        expectation.fulfill()

                })
             } catch {
                 XCTFail("\(error)")
            }

        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { error -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }

    }

    func randomStringWithLength (len: Int) -> String {
        // We exclude possibily confusing signs "oOiI01" to make random strings less ambiguous
        let signs = "abcdefghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ23456789"

        var randomString = ""

        for _ in 0 ..< len {
            let length = UInt32 (signs.characters.count)
            let rand = arc4random_uniform(length)
            let idx = signs.startIndex.advancedBy(Int(rand))
            let c=signs.characters[idx]
            randomString.append(c)
        }

        return randomString
    }


}
