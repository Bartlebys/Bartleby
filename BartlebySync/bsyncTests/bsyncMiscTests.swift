//
//  bsyncTests.swift
//  bsyncTests
//
//  Created by Benoit Pereira da silva on 01/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class bsyncMiscTests: TestCase {
    
    func test001_DMG_create_attach_detach() {
        let expectation = self.expectation(description: "DMG_create_attach_detach_remove")
        let dm = BsyncImageDiskManager()
        let fm = FileManager.default
        let path = bsyncMiscTests.assetPath + Bartleby.randomStringWithLength(6)
        do {
            try fm.createDirectory(atPath: bsyncMiscTests.assetPath, withIntermediateDirectories: true, attributes: nil)
            dm.createImageDisk(path, volumeName: "Project 1 Synchronized", size: "2g", password: "gugu", handlers: Handlers { (createDisc) in
                if let imagePath = createDisc.getStringResult() , createDisc.success {
                    dm.attachVolume(from:imagePath, withPassword: "gugu", handlers: Handlers { (attach) in
                        XCTAssert(attach.success, attach.message)
                        dm.detachVolume("Project 1 Synchronized", handlers: Handlers { (detach) in
                            XCTAssert(detach.success, detach.message)
                            expectation.fulfill()
                            do {
                                try fm.removeItem(atPath: imagePath)
                            } catch {
                                XCTFail("Error: \(error)")
                            }
                            })
                        })
                } else {
                    XCTFail(createDisc.message)
                }
                })
            
            self.waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func test002_hash_sample_folder() {
        
        let expectation = self.expectation(description: "hash_sample_folder")
        
        let analyzer=BsyncLocalAnalyzer()
        analyzer.saveHashInAFile=false
        analyzer.recomputeHash=true
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let path = bsyncMiscTests.assetPath
        let fm = BFileManager()
        fm.createDirectoryAtPath(path + "subfolder/", handlers: Handlers { (create) in
            XCTAssert(create.success, create.message)
            
            for i in 1...20 {
                let s = Bartleby.randomStringWithLength(UInt(i * 1024))
                let subPath = path + (i > 10 ? "subfolder/\(i).data" : "\(i).data")
                do {
                    try s.write(toFile: subPath, atomically: false, encoding: Default.STRING_ENCODING)
                } catch {
                    XCTFail("Creation of \(subPath) failure \(error)")
                }
            }
            
            analyzer.createHashMapFromLocalPath(path, handlers: Handlers { (analyze) in
                XCTAssert(analyze.success, analyze.message)
                if let hashMap:BsyncHashMap=analyze.getResult(){

                    var counter=0
                    let filtered=hashMap.filter({ (relativePath) -> Bool in
                        counter += 1
                        return (counter % 2 == 0)
                    })

                    if filtered.pathToHash.count < hashMap.pathToHash.count{

                    }else{
                         XCTFail("Filtered BsyncHashmap is inconsistent")
                    }

                    bprint("BsyncHashMap found \(hashMap)", file: #file, function: #function, line: #line, category: DEFAULT_BPRINT_CATEGORY, decorative: false)
                }else{
                    XCTFail("BsyncHashMap expected")
                }

                let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
                print ("elapsed time \(elapsedTime)")
                fm.removeItemAtPath(path, handlers: Handlers { (remove) in
                    expectation.fulfill()
                    XCTAssert(remove.success, remove.message)
                    })
                })
            })
        
        self.waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func randomStringWithLength (_ len: Int) -> String {
        // We exclude possibily confusing signs "oOiI01" to make random strings less ambiguous
        let signs = "abcdefghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ23456789"
        
        var randomString = ""
        
        for _ in 0 ..< len {
            let length = UInt32 (signs.characters.count)
            let rand = arc4random_uniform(length)
            let idx = signs.characters.index(signs.startIndex, offsetBy: Int(rand))
            let c=signs.characters[idx]
            randomString.append(c)
        }
        
        return randomString
    }
    
    
}
