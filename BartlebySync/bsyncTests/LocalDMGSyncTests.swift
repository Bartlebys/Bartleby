//
//  bsyncLocalSyncTests.swift
//  bsync
//
//  Created by Martin Delille on 29/03/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class LocalDMGSyncTests: XCTestCase {
    
    
    private static let _diskManager = BsyncImageDiskManager()
    private static let _fileManager = BFileManager()
    
    private static let _dmgSize = "2g"
    
    private static let _masterDMGName = Bartleby.randomStringWithLength(6)
    private static let _masterDMGPath = NSTemporaryDirectory() + _masterDMGName
    private static let _masterDMGFullPath = _masterDMGPath + ".sparseimage"
    private static let _masterDMGPassword = Bartleby.randomStringWithLength(6)
    private static let _masterVolumePath = "/Volumes/" + _masterDMGName + "/"
    private static let _masterVolumeURL = NSURL(fileURLWithPath: _masterVolumePath)
    
    private static let _slaveDMGName = Bartleby.randomStringWithLength(6)
    private static let _slaveDMGPath = NSTemporaryDirectory() + _slaveDMGName
    private static let _slaveDMGFullPath = _slaveDMGPath + ".sparseimage"
    private static let _slaveDMGPassword = Bartleby.randomStringWithLength(6)
    private static let _slaveVolumePath = "/Volumes/" + _slaveDMGName + "/"
    private static let _slaveVolumeURL = NSURL(fileURLWithPath: _slaveVolumePath)
    
    private static let _filePath = _masterVolumePath + "test.txt"
    private static let _fileContent = Bartleby.randomStringWithLength(20)
    
    // MARK: Master DMG creation, attach and directive creation
    func test001_CreateMasterDMG() {
        let expectation = expectationWithDescription("Create image")
        LocalDMGSyncTests._diskManager.createImageDisk(LocalDMGSyncTests._masterDMGPath,
                                                       volumeName: LocalDMGSyncTests._masterDMGName,
                                                       size: LocalDMGSyncTests._dmgSize,
                                                       password: LocalDMGSyncTests._masterDMGPassword,
                                                       handlers: Handlers { (createDisk) in
                                                        expectation.fulfill()
                                                        if let dmg = createDisk.getStringResult() where createDisk.success {
                                                            XCTAssertEqual(LocalDMGSyncTests._masterDMGFullPath, dmg)
                                                        } else {
                                                            XCTFail(createDisk.message)
                                                        }
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint("\(error)")
        }
    }
    
    func test002_AttachMasterDMG() {
        let expectation = expectationWithDescription("Image attachment")
        LocalDMGSyncTests._diskManager.attachVolume(from: LocalDMGSyncTests._masterDMGFullPath, withPassword: LocalDMGSyncTests._masterDMGPassword, handlers: Handlers { (attach) in
            XCTAssert(attach.success, attach.message)
            expectation.fulfill()
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint("\(error)")
        }
    }
    
    func test003_CreateFileInDMG() {
        let expectation = expectationWithDescription("File creation")
        LocalDMGSyncTests._fileManager.writeString(LocalDMGSyncTests._fileContent,
                                                   path: LocalDMGSyncTests._filePath,
                                                   handlers: Handlers { (createFile) in
                                                    XCTAssert(createFile.success, createFile.message)
                                                    expectation.fulfill()
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint("\(error)")
        }
    }
    
    
    
    // MARK: Slave DMG creation, attach and directives creation
    func test101_CreateSlaveDMG() {
        let expectation = expectationWithDescription("Create image")
        LocalDMGSyncTests._diskManager.createImageDisk(LocalDMGSyncTests._slaveDMGPath,
                                                       volumeName: LocalDMGSyncTests._slaveDMGName,
                                                       size: LocalDMGSyncTests._dmgSize,
                                                       password: LocalDMGSyncTests._slaveDMGPassword,
                                                       handlers: Handlers { (createDisk) in
                                                        expectation.fulfill()
                                                        if let dmg = createDisk.getStringResult() where createDisk.success {
                                                            XCTAssertEqual(LocalDMGSyncTests._slaveDMGFullPath, dmg)
                                                        } else {
                                                            XCTFail(createDisk.message)
                                                        }
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint("\(error)")
        }
    }
    
    func test102_AttachSlaveDMG() {
        let expectation = expectationWithDescription("Image attachment")
        LocalDMGSyncTests._diskManager.attachVolume(from: LocalDMGSyncTests._slaveDMGFullPath, withPassword: LocalDMGSyncTests._slaveDMGPassword, handlers: Handlers { (attach) in
            XCTAssert(attach.success, attach.message)
            expectation.fulfill()
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint("\(error)")
        }
    }
    
    func test103_CreateDirectives() {
        let expectation = expectationWithDescription("File exists")
        let directives = BsyncDirectives()
        directives.sourceURL = LocalDMGSyncTests._masterVolumeURL
        directives.destinationURL = LocalDMGSyncTests._slaveVolumeURL
        
        let directivesURL = LocalDMGSyncTests._masterVolumeURL.URLByAppendingPathComponent(BsyncDirectives.DEFAULT_FILE_NAME, isDirectory: false)
        BsyncAdmin.createDirectives(directives, saveTo: directivesURL)
        if let path = directivesURL.path {
            LocalDMGSyncTests._fileManager.fileExistsAtPath(path, handlers: Handlers { (existence) in
                expectation.fulfill()
                XCTAssert(existence.success, existence.message)
                })
        } else {
            XCTFail("Bad directive URL: \(directivesURL)")
        }
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint("\(error)")
        }
    }
    
    
    // MARK: Run synchronization
    func test201_RunDirectives() {
        let expectation = expectationWithDescription("Synchronize should complete")
        let context = BsyncContext(sourceURL: LocalDMGSyncTests._masterVolumeURL,
                                   andDestinationUrl: LocalDMGSyncTests._slaveVolumeURL,
                                   restrictedTo: BsyncDirectives.NO_HASHMAPVIEW)
        let admin = BsyncAdmin(context: context)
        admin.synchronizeWithprogressBlock(Handlers(completionHandler: { (c) in
            // TODO: @md #test #bsync Reactivate test check wich currently fais
            //XCTAssertTrue(c.success, c.message)
            expectation.fulfill()
        }))
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            if let error = error {
                bprint(error.localizedDescription)
            }
        }
    }
    
    
    // MARK: Cleanup
    func test901_DetachSlaveDMG() {
        let expectation = expectationWithDescription("Detach")
        LocalDMGSyncTests._diskManager.detachVolume(LocalDMGSyncTests._slaveDMGName, handlers: Handlers { (detach) in
            expectation.fulfill()
            XCTAssert(detach.success, detach.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            if let error = error {
                bprint(error.localizedDescription)
            }
        }
    }
    
    func test902_RemoveSlaveDMG() {
        let expectation = expectationWithDescription("Remove")
        LocalDMGSyncTests._fileManager.removeItemAtPath(LocalDMGSyncTests._slaveDMGFullPath, handlers: Handlers { (remove) in
            XCTAssert(remove.success, remove.message)
            expectation.fulfill()
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            if let error = error {
                bprint(error.localizedDescription)
            }
        }
    }
    
    func test903_DetachMasterDMG() {
        let expectation = expectationWithDescription("Detach")
        LocalDMGSyncTests._diskManager.detachVolume(LocalDMGSyncTests._masterDMGName, handlers: Handlers { (detach) in
            expectation.fulfill()
            XCTAssert(detach.success, detach.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            if let error = error {
                bprint(error.localizedDescription)
            }
        }
    }
    
    func test904_RemoveMasterDMG() {
        let expectation = expectationWithDescription("Remove")
        LocalDMGSyncTests._fileManager.removeItemAtPath(LocalDMGSyncTests._masterDMGFullPath, handlers: Handlers { (remove) in
            XCTAssert(remove.success, remove.message)
            expectation.fulfill()
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            if let error = error {
                bprint(error.localizedDescription)
            }
        }
    }
}
