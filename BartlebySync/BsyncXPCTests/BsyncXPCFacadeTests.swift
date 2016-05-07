//
//  BsyncXPCFacadeTests.swift
//  bsync
//
//  Created by Martin Delille on 07/05/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class BsyncXPCFacadeTests: XCTestCase {
    let fm = BsyncXPCFacade()
    let contextName = Bartleby.randomStringWithLength(6) + "/"
    
    func test101_exist_create_write_read_list() {
        let folder = TestsConfiguration.ASSET_PATH + contextName
        
        // Checking no items (directory or file) exists
        let directoryShouldNotExist1 = self.expectationWithDescription("Directory should not exist")
        self.fm.directoryExistsAtPath(folder,
                                      handlers: Handlers { (existence) in
                                        directoryShouldNotExist1.fulfill()
                                        XCTAssertFalse(existence.success)
                                        XCTAssertEqual(404, existence.statusCode)
            })
        let itemShouldNotExist = self.expectationWithDescription("Directory should not exist")
        self.fm.itemExistsAtPath(folder,
                                 handlers: Handlers { (existence) in
                                    itemShouldNotExist.fulfill()
                                    XCTAssertFalse(existence.success)
                                    XCTAssertEqual(404, existence.statusCode)
            })
        let fileShouldNotExist = self.expectationWithDescription("Directory should not exist")
        self.fm.fileExistsAtPath(folder,
                                 handlers: Handlers { (existence) in
                                    fileShouldNotExist.fulfill()
                                    XCTAssertFalse(existence.success)
                                    XCTAssertEqual(404, existence.statusCode)
            })
        
        // Create directory
        let directoryShouldBeCreated = self.expectationWithDescription("Directory should be created")
        self.fm.createDirectoryAtPath(folder, handlers: Handlers { (creation) in
            directoryShouldBeCreated.fulfill()
            XCTAssert(creation.success, creation.message)
            
            // Check the new directory exists
            let directoryShouldExist = self.expectationWithDescription("Directory should exist")
            self.fm.directoryExistsAtPath(folder,
                handlers: Handlers { (existence) in
                    directoryShouldExist.fulfill()
                    XCTAssertTrue(existence.success)
                    XCTAssertEqual(200, existence.statusCode)
                })
            let itemShouldExist1 = self.expectationWithDescription("Item should exist")
            self.fm.itemExistsAtPath(folder,
                handlers: Handlers { (existence) in
                    itemShouldExist1.fulfill()
                    XCTAssertTrue(existence.success)
                    XCTAssertEqual(200, existence.statusCode)
                })
            let itemIsNotAFile = self.expectationWithDescription("Item is not a file")
            self.fm.fileExistsAtPath(folder,
                handlers: Handlers { (existence) in
                    itemIsNotAFile.fulfill()
                    XCTAssertFalse(existence.success)
                    XCTAssertEqual(415, existence.statusCode)
                })
            
            // Create file
            let aaa = Bartleby.randomStringWithLength(6)
            let filePath = folder + "test.txt"
            let writeExpectation = self.expectationWithDescription("A string should be written")
            self.fm.writeString(aaa, path: filePath, handlers: Handlers { (write) in
                writeExpectation.fulfill()
                XCTAssert(write.success, write.message)
                
                // Check the new file exists
                let directoryShouldNotExist2 = self.expectationWithDescription("Directory should not exist")
                self.fm.directoryExistsAtPath(filePath,
                    handlers: Handlers { (existence) in
                        directoryShouldNotExist2.fulfill()
                        XCTAssertFalse(existence.success)
                        XCTAssertEqual(415, existence.statusCode)
                    })
                let itemShouldExist2 = self.expectationWithDescription("Item should exist")
                self.fm.itemExistsAtPath(filePath,
                    handlers: Handlers { (existence) in
                        itemShouldExist2.fulfill()
                        XCTAssertTrue(existence.success)
                        XCTAssertEqual(200, existence.statusCode)
                    })
                let itemIsNotADirectory = self.expectationWithDescription("Item is not a directory")
                self.fm.fileExistsAtPath(filePath,
                    handlers: Handlers { (existence) in
                        itemIsNotADirectory.fulfill()
                        XCTAssertTrue(existence.success)
                        XCTAssertEqual(200, existence.statusCode)
                    })
                
                // Check the file content
                let readExpectation = self.expectationWithDescription("A string shoudl be read")
                self.fm.readString(contentsOfFile: filePath, handlers: Handlers { (read) in
                    readExpectation.fulfill()
                    if let bbb = read.getStringResult() where read.success {
                        XCTAssertEqual(bbb, aaa)
                    } else {
                        XCTFail(read.message)
                    }
                    })
                
                // Retrieve the folder content
                let listExpectation = self.expectationWithDescription("A list should be returned")
                self.fm.contentsOfDirectoryAtPath(folder, handlers: Handlers { (content) in
                    listExpectation.fulfill()
                    XCTAssertEqual(200, content.statusCode)
                    if let list = content.getStringArrayResult() where content.success {
                        XCTAssertEqual(list, ["test.txt"])
                    } else {
                        XCTFail(content.message)
                    }
                    })
                
                })
            
            
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint(error?.localizedDescription)
        }
    }
}
