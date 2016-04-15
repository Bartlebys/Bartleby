//
//  bsyncDirectivesTests.swift
//  bsync
//
//  Created by Benoit Pereira da silva on 01/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class bsyncDirectivesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test001_create_directives(){
        let expectation = expectationWithDescription("create a directive file")
        let folderURL=self.createATestFolder()
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
    }

    func createATestFolder()->NSURL{
        if let url=NSURL(string: "file://\(NSHomeDirectory())/Desktop/test_folder/"){
            let fsm=NSFileManager()
            if let folderURLPath=url.path{
                if !fsm.fileExistsAtPath(folderURLPath){
                    do{
                        try fsm.createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
                    }catch{
                        // Silent catch, the folder may exist..
                    }
                }
                return url
            }
            
        }
        return NSURL()
    }
    
    
}
