//
//  bsyncLocalSyncTests.swift
//  bsync
//
//  Created by Martin Delille on 29/03/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

class LocalDMGSyncTests: LocalSyncTests {
    
    private let _diskManager = BsyncImageDiskManager()
    private let _dmgSize = "100m"

    private static var _treeId = ""
    private var _masterDMGName = ""
    private var _masterDMGPath = ""
    private var _masterDMGFullPath = ""
    private let _masterDMGPassword = "12345"
    private var _masterVolumePath = ""
    private var _masterVolumeURL = NSURL()
    
    private var _slaveDMGName = ""
    private var _slaveDMGPath = ""
    private var _slaveDMGFullPath = ""
    private let _slaveDMGPassword = "67890"
    private var _slaveVolumePath = ""
    private var _slaveVolumeURL = NSURL()


    private static var _prefix=Bartleby.createUID()

    override class func setUp() {
        super.setUp()
        self._treeId = "synchronized_tests"
    }

    override func setUp() {
        super.setUp();

        self._masterDMGName = LocalDMGSyncTests._prefix+"_Master"
        self._masterDMGPath = self.assetPath + self._masterDMGName
        self._masterDMGFullPath = self._masterDMGPath + ".sparseimage"
        self._masterVolumePath = "/Volumes/" + self._masterDMGName + "/"
        self._masterVolumeURL = NSURL(fileURLWithPath: self._masterVolumePath)
        
        
        self.sourceFolderPath = self._masterVolumePath+LocalDMGSyncTests._treeId+"/"
        
        self._slaveDMGName = LocalDMGSyncTests._prefix+"_Slave"
        self._slaveDMGPath = self.assetPath + self._slaveDMGName
        self._slaveDMGFullPath = self._slaveDMGPath + ".sparseimage"
        self._slaveVolumePath = "/Volumes/" + self._slaveDMGName + "/"
        self._slaveVolumeURL = NSURL(fileURLWithPath: self._slaveVolumePath)
        
        destinationFolderPath = self._slaveVolumePath+LocalDMGSyncTests._treeId+"/"
        
    }
    
    override func prepareSync(handlers: Handlers) {
        // Create master DMG
        self._diskManager.createImageDisk(_masterDMGPath, volumeName: _masterDMGName, size: self._dmgSize, password: self._masterDMGPassword, handlers: Handlers { (createMaster) in
            if createMaster.success {
                // Attach master DMG
                self._diskManager.attachVolume(from: self._masterDMGFullPath, withPassword: self._masterDMGPassword, handlers: Handlers { (attachMaster) in
                    if attachMaster.success {
                        // Create slave DMG
                        self._diskManager.createImageDisk(self._slaveDMGPath, volumeName: self._slaveDMGName, size: self._dmgSize, password: self._slaveDMGPassword, handlers: Handlers { (createSlave) in
                            if createSlave.success {
                                // Attache slave DMG
                                self._diskManager.attachVolume(from: self._slaveDMGFullPath, withPassword: self._slaveDMGPassword, handlers: Handlers { (attachSlave) in
                                    if attachSlave.success {
                                        super.prepareSync(handlers)
                                    } else {
                                        handlers.on(attachSlave)
                                    }
                                    })
                            } else {
                                handlers.on(createSlave)
                            }
                            })
                        
                    } else {
                        handlers.on(attachMaster)
                    }
                    })
            } else {
                handlers.on(createMaster)
            }
            })
    }
    
    override func disposeSync(handlers: Handlers) {
        // Detach slave DMG
        self._diskManager.detachVolume(self._slaveDMGName, handlers: Handlers { (detachSlave) in
            if detachSlave.success {
                // Remove slave DMG
                do {
                    try self._fm.removeItemAtPath(self._slaveDMGFullPath)
                    // Detach master DMG
                    self._diskManager.detachVolume(self._masterDMGName, handlers: Handlers { (detachMaster) in
                        if detachMaster.success {
                            // Remove master DMG
                            do {
                                try self._fm.removeItemAtPath(self._masterDMGFullPath)
                                super.disposeSync(handlers)
                            } catch {
                                handlers.on(Completion.failureStateFromError(error))
                            }
                        } else {
                            handlers.on(detachMaster)
                        }
                        })
                } catch {
                    handlers.on(Completion.failureStateFromError(error))
                }
            } else {
                handlers.on(detachSlave)
            }
            })
    }
}
