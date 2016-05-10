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
        let expectation = expectationWithDescription("DMG_create_attach_detach_remove")
        let dm = BsyncImageDiskManager()
        let fm = BFileManager()
        let path = TestsConfiguration.ASSET_PATH + Bartleby.randomStringWithLength(6)
        dm.createImageDisk(path, volumeName: "Project 1 Synchronized", size: "2g", password: "gugu", handlers: Handlers { (createDisc) in
            if let imagePath = createDisc.getStringResult() where createDisc.success {
                dm.attachVolume(from:imagePath, withPassword: "gugu", handlers: Handlers { (attach) in
                    XCTAssert(attach.success, attach.message)
                    dm.detachVolume("Project 1 Synchronized", handlers: Handlers { (detach) in
                        XCTAssert(detach.success, detach.message)
                        fm.removeItemAtPath(imagePath, handlers: Handlers { (remove) in
                            XCTAssert(remove.success, remove.message)
                            expectation.fulfill()
                            })
                        })
                    })
            } else {
                XCTFail(createDisc.message)
            }
            })
        
        // This test is very long
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { error -> Void in
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
