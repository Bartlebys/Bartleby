//
//  BsyncXPCProtocolTests.swift
//  bsync
//
//  Created by Martin Delille on 08/05/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class BsyncXPCProtocolTests: TestCase {
    func test101_exist_create_write_read_list() {
        // Insert code here to initialize your application
        let connection = NSXPCConnection(serviceName: "fr.chaosmos.BsyncXPC")
        connection.remoteObjectInterface = NSXPCInterface(with: BsyncXPCProtocol.self)
        connection.resume()
        
        if let xpc = connection.remoteObjectProxy as? BsyncXPCProtocol {
            
            let folder = BsyncXPCProtocolTests.assetPath + Bartleby.randomStringWithLength(6)
            
            // Checking no items (directory or file) exists
            let directoryShouldNotExist1 = self.expectation(description: "Directory should not exist")
            xpc.directoryExistsAtPath(folder,
                                          handler: Handlers { (existence) in
                                            directoryShouldNotExist1.fulfill()
                                            XCTAssertFalse(existence.success)
                                            XCTAssertEqual(404, existence.statusCode)
                }.composedHandler())
            let itemShouldNotExist = self.expectation(description: "Directory should not exist")
            xpc.itemExistsAtPath(folder,
                                     handler: Handlers { (existence) in
                                        itemShouldNotExist.fulfill()
                                        XCTAssertFalse(existence.success)
                                        XCTAssertEqual(404, existence.statusCode)
                }.composedHandler())
            let fileShouldNotExist = self.expectation(description: "Directory should not exist")
            xpc.fileExistsAtPath(folder,
                                     handler: Handlers { (existence) in
                                        fileShouldNotExist.fulfill()
                                        XCTAssertFalse(existence.success)
                                        XCTAssertEqual(404, existence.statusCode)
                }.composedHandler())
            
            // Create directory
            let directoryShouldBeCreated = self.expectation(description: "Directory should be created")
            xpc.createDirectoryAtPath(folder, handler: Handlers { (creation) in
                directoryShouldBeCreated.fulfill()
                XCTAssert(creation.success, creation.message)
                
                // Check the new directory exists
                let directoryShouldExist = self.expectation(description: "Directory should exist")
                xpc.directoryExistsAtPath(folder,
                    handler: Handlers { (existence) in
                        directoryShouldExist.fulfill()
                        XCTAssertTrue(existence.success)
                        XCTAssertEqual(200, existence.statusCode)
                    }.composedHandler())
                let itemShouldExist1 = self.expectation(description: "Item should exist")
                xpc.itemExistsAtPath(folder,
                    handler: Handlers { (existence) in
                        itemShouldExist1.fulfill()
                        XCTAssertTrue(existence.success)
                        XCTAssertEqual(200, existence.statusCode)
                    }.composedHandler())
                let itemIsNotAFile = self.expectation(description: "Item is not a file")
                xpc.fileExistsAtPath(folder,
                    handler: Handlers { (existence) in
                        itemIsNotAFile.fulfill()
                        XCTAssertFalse(existence.success)
                        XCTAssertEqual(415, existence.statusCode)
                    }.composedHandler())
                
                // Create file
                let aaa = Bartleby.randomStringWithLength(6)
                let filePath = folder + "test.txt"
                let writeExpectation = self.expectation(description: "A string should be written")
                xpc.writeString(aaa, path: filePath, handler: Handlers { (write) in
                    writeExpectation.fulfill()
                    XCTAssert(write.success, write.message)
                    
                    // Check the new file exists
                    let directoryShouldNotExist2 = self.expectation(description: "Directory should not exist")
                    xpc.directoryExistsAtPath(filePath,
                        handler: Handlers { (existence) in
                            directoryShouldNotExist2.fulfill()
                            XCTAssertFalse(existence.success)
                            XCTAssertEqual(415, existence.statusCode)
                        }.composedHandler())
                    let itemShouldExist2 = self.expectation(description: "Item should exist")
                    xpc.itemExistsAtPath(filePath,
                        handler: Handlers { (existence) in
                            itemShouldExist2.fulfill()
                            XCTAssertTrue(existence.success)
                            XCTAssertEqual(200, existence.statusCode)
                        }.composedHandler())
                    let itemIsNotADirectory = self.expectation(description: "Item is not a directory")
                    xpc.fileExistsAtPath(filePath,
                        handler: Handlers { (existence) in
                            itemIsNotADirectory.fulfill()
                            XCTAssertTrue(existence.success)
                            XCTAssertEqual(200, existence.statusCode)
                        }.composedHandler())
                    
                    // Check the file content
                    let readExpectation = self.expectation(description: "A string shoudl be read")
                    xpc.readString(contentsOfFile: filePath, handler: Handlers { (read) in
                        readExpectation.fulfill()
                        if let bbb = read.getStringResult() , read.success {
                            XCTAssertEqual(bbb, aaa)
                        } else {
                            XCTFail(read.message)
                        }
                        }.composedHandler())
                    
                    // Retrieve the folder content
                    let listExpectation = self.expectation(description: "A list should be returned")
                    xpc.contentsOfDirectoryAtPath(folder, handler: Handlers { (content) in
                        listExpectation.fulfill()
                        XCTAssertEqual(200, content.statusCode)
                        if let list = content.getStringArrayResult() , content.success {
                            XCTAssertEqual(list, ["test.txt"])
                        } else {
                            XCTFail(content.message)
                        }
                        }.composedHandler())
                    
                    }.composedHandler())
                
                
                }.composedHandler())
            
            waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("error unwrapping XPC")
        }
    }
}
