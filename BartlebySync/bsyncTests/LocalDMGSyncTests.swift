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
    
    private static let _directivesPath = _masterVolumePath + BsyncDirectives.DEFAULT_FILE_NAME
    
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
            bprint("Error: \(error?.localizedDescription)", file: #file, function: #function, line: #line)
        }
    }
    
    func test002_AttachMasterDMG() {
        let expectation = expectationWithDescription("Image attachment")
        LocalDMGSyncTests._diskManager.attachVolume(from: LocalDMGSyncTests._masterDMGFullPath, withPassword: LocalDMGSyncTests._masterDMGPassword, handlers: Handlers { (attach) in
            XCTAssert(attach.success, attach.message)
            expectation.fulfill()
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint("Error: \(error?.localizedDescription)", file: #file, function: #function, line: #line)
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
            bprint("Error: \(error?.localizedDescription)", file: #file, function: #function, line: #line)
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
            bprint("Error: \(error?.localizedDescription)", file: #file, function: #function, line: #line)
        }
    }
    
    func test102_AttachSlaveDMG() {
        let expectation = expectationWithDescription("Image attachment")
        LocalDMGSyncTests._diskManager.attachVolume(from: LocalDMGSyncTests._slaveDMGFullPath, withPassword: LocalDMGSyncTests._slaveDMGPassword, handlers: Handlers { (attach) in
            XCTAssert(attach.success, attach.message)
            expectation.fulfill()
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint("Error: \(error?.localizedDescription)", file: #file, function: #function, line: #line)
        }
    }
    
    func test103_CreateDirectives() {
        let directives = BsyncDirectives.localDirectivesWithPath(LocalDMGSyncTests._masterDMGPath, destinationPath: LocalDMGSyncTests._slaveDMGPath)
        let admin = BsyncAdmin()
        do {
            try admin.saveDirectives(directives, path: LocalDMGSyncTests._directivesPath)
        } catch {
            bprint("Error: \(error)", file: #file, function: #function, line: #line)
        }
    }
    
    
    // MARK: Run synchronization
    func test201_RunDirectives() {
        let expectation = expectationWithDescription("Synchronize should complete")
        
        // TODO: @md #test #bsync Use BsyncDirectives
        let context = BsyncContext(sourceURL: LocalDMGSyncTests._masterVolumeURL,
                                   andDestinationUrl: LocalDMGSyncTests._slaveVolumeURL,
                                   restrictedTo: nil)
        let admin = BsyncAdmin()
        admin.synchronize(context, handlers: Handlers(completionHandler: { (c) in
            XCTAssertTrue(c.success, c.message)
            expectation.fulfill()
        }))
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint("Error: \(error?.localizedDescription)", file: #file, function: #function, line: #line)
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
            bprint("Error: \(error?.localizedDescription)", file: #file, function: #function, line: #line)
        }
    }
    
    func test902_RemoveSlaveDMG() {
        let expectation = expectationWithDescription("Remove")
        LocalDMGSyncTests._fileManager.removeItemAtPath(LocalDMGSyncTests._slaveDMGFullPath, handlers: Handlers { (remove) in
            XCTAssert(remove.success, remove.message)
            expectation.fulfill()
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint("Error: \(error?.localizedDescription)", file: #file, function: #function, line: #line)
        }
    }
    
    func test903_DetachMasterDMG() {
        let expectation = expectationWithDescription("Detach")
        LocalDMGSyncTests._diskManager.detachVolume(LocalDMGSyncTests._masterDMGName, handlers: Handlers { (detach) in
            expectation.fulfill()
            XCTAssert(detach.success, detach.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint("Error: \(error?.localizedDescription)", file: #file, function: #function, line: #line)
        }
    }
    
    func test904_RemoveMasterDMG() {
        let expectation = expectationWithDescription("Remove")
        LocalDMGSyncTests._fileManager.removeItemAtPath(LocalDMGSyncTests._masterDMGFullPath, handlers: Handlers { (remove) in
            XCTAssert(remove.success, remove.message)
            expectation.fulfill()
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            bprint("Error: \(error?.localizedDescription)", file: #file, function: #function, line: #line)
        }
    }
}
