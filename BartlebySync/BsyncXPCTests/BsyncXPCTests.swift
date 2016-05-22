//
//  BsyncXPCTests.swift
//  bsync
//
//  Created by Martin Delille on 07/05/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class BsyncXPCTests: XCTestCase {
    
    // MARK: BFileManager (kind of duplicate)
    func test101_exist_create_write_read_list() {
        let xpc = BsyncXPC()
        let contextName = Bartleby.randomStringWithLength(6) + "/"
        let folder = TestsConfiguration.ASSET_PATH + contextName
        
        // Checking no items (directory or file) exists
        let directoryShouldNotExist1 = self.expectationWithDescription("Directory should not exist")
        xpc.directoryExistsAtPath(folder,
                                  handlers: Handlers { (existence) in
                                    directoryShouldNotExist1.fulfill()
                                    XCTAssertFalse(existence.success)
                                    XCTAssertEqual(404, existence.statusCode)
            })
        let itemShouldNotExist = self.expectationWithDescription("Directory should not exist")
        xpc.itemExistsAtPath(folder,
                             handlers: Handlers { (existence) in
                                itemShouldNotExist.fulfill()
                                XCTAssertFalse(existence.success)
                                XCTAssertEqual(404, existence.statusCode)
            })
        let fileShouldNotExist = self.expectationWithDescription("Directory should not exist")
        xpc.fileExistsAtPath(folder,
                             handlers: Handlers { (existence) in
                                fileShouldNotExist.fulfill()
                                XCTAssertFalse(existence.success)
                                XCTAssertEqual(404, existence.statusCode)
            })
        
        // Create directory
        let directoryShouldBeCreated = self.expectationWithDescription("Directory should be created")
        xpc.createDirectoryAtPath(folder, handlers: Handlers { (creation) in
            directoryShouldBeCreated.fulfill()
            XCTAssert(creation.success, creation.message)
            
            // Check the new directory exists
            let directoryShouldExist = self.expectationWithDescription("Directory should exist")
            xpc.directoryExistsAtPath(folder,
                handlers: Handlers { (existence) in
                    directoryShouldExist.fulfill()
                    XCTAssertTrue(existence.success)
                    XCTAssertEqual(200, existence.statusCode)
                })
            let itemShouldExist1 = self.expectationWithDescription("Item should exist")
            xpc.itemExistsAtPath(folder,
                handlers: Handlers { (existence) in
                    itemShouldExist1.fulfill()
                    XCTAssertTrue(existence.success)
                    XCTAssertEqual(200, existence.statusCode)
                })
            let itemIsNotAFile = self.expectationWithDescription("Item is not a file")
            xpc.fileExistsAtPath(folder,
                handlers: Handlers { (existence) in
                    itemIsNotAFile.fulfill()
                    XCTAssertFalse(existence.success)
                    XCTAssertEqual(415, existence.statusCode)
                })
            
            // Create file
            let aaa = Bartleby.randomStringWithLength(6)
            let filePath = folder + "test.txt"
            let writeExpectation = self.expectationWithDescription("A string should be written")
            xpc.writeString(aaa, path: filePath, handlers: Handlers { (write) in
                writeExpectation.fulfill()
                XCTAssert(write.success, write.message)
                
                // Check the new file exists
                let directoryShouldNotExist2 = self.expectationWithDescription("Directory should not exist")
                xpc.directoryExistsAtPath(filePath,
                    handlers: Handlers { (existence) in
                        directoryShouldNotExist2.fulfill()
                        XCTAssertFalse(existence.success)
                        XCTAssertEqual(415, existence.statusCode)
                    })
                let itemShouldExist2 = self.expectationWithDescription("Item should exist")
                xpc.itemExistsAtPath(filePath,
                    handlers: Handlers { (existence) in
                        itemShouldExist2.fulfill()
                        XCTAssertTrue(existence.success)
                        XCTAssertEqual(200, existence.statusCode)
                    })
                let itemIsNotADirectory = self.expectationWithDescription("Item is not a directory")
                xpc.fileExistsAtPath(filePath,
                    handlers: Handlers { (existence) in
                        itemIsNotADirectory.fulfill()
                        XCTAssertTrue(existence.success)
                        XCTAssertEqual(200, existence.statusCode)
                    })
                
                // Check the file content
                let readExpectation = self.expectationWithDescription("A string shoudl be read")
                xpc.readString(contentsOfFile: filePath, handlers: Handlers { (read) in
                    readExpectation.fulfill()
                    if let bbb = read.getStringResult() where read.success {
                        XCTAssertEqual(bbb, aaa)
                    } else {
                        XCTFail(read.message)
                    }
                    })
                
                // Retrieve the folder content
                let listExpectation = self.expectationWithDescription("A list should be returned")
                xpc.contentsOfDirectoryAtPath(folder, handlers: Handlers { (content) in
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
            bprint("Error: \(error.localizedDescription)", file: #file, function: #function, line: #line)
        }
    }
    
    // MARK: DMG manipulation
    func test_DMG_without_password() {
        let expectation = expectationWithDescription("create attach detach")
        let xpc = BsyncXPC()
        let name = Bartleby.randomStringWithLength(6)
        let path = TestsConfiguration.ASSET_PATH + name
        // Create disk
        xpc.createImageDisk(path, volumeName: name, size: "1g", password: nil, handlers: Handlers { (createDisk) in
            if let imagePath = createDisk.getStringResult() where createDisk.success {
                xpc.attachVolume(from: imagePath, withPassword: nil, handlers: Handlers { (attach) in
                    XCTAssert(attach.success, attach.message)
                    xpc.detachVolume(name, handlers: Handlers { (detach) in
                        XCTAssert(detach.success, detach.message)
                        expectation.fulfill()
                        })
                    })
            } else {
                XCTFail(createDisk.message)
            }
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint("Error: \(error.localizedDescription)", file: #file, function: #function, line: #line)
        }
    }
    
    func test_DMG_with_password() {
        let expectation = expectationWithDescription("create attach detach")
        let xpc = BsyncXPC()
        let name = Bartleby.randomStringWithLength(6)
        let path = TestsConfiguration.ASSET_PATH + name
        let password = Bartleby.randomStringWithLength(6)
        // Create disk
        xpc.createImageDisk(path, volumeName: name, size: "1g", password: password, handlers: Handlers { (createDisk) in
            if let imagePath = createDisk.getStringResult() where createDisk.success {
                xpc.attachVolume(from: imagePath, withPassword: password, handlers: Handlers { (attach) in
                    XCTAssert(attach.success, attach.message)
                    xpc.detachVolume(name, handlers: Handlers { (detach) in
                        XCTAssert(detach.success, detach.message)
                        expectation.fulfill()
                        })
                    })
            } else {
                XCTFail(createDisk.message)
            }
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint("Error: \(error.localizedDescription)", file: #file, function: #function, line: #line)
        }
    }
}
