//
//  bsyncLocalSyncTests.swift
//  bsync
//
//  Created by Martin Delille on 29/03/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

class LocalDMGSyncTests: LocalSyncTests {
    
    fileprivate let _diskManager = BsyncImageDiskManager()
    fileprivate let _dmgSize = "100m"

    fileprivate static var _treeId = ""
    fileprivate var _masterDMGName = ""
    fileprivate var _masterDMGPath = ""
    fileprivate var _masterDMGFullPath = ""
    fileprivate let _masterDMGPassword = "12345"
    fileprivate var _masterVolumePath = ""
    fileprivate var _masterVolumeURL = TestsConfiguration.API_BASE_URL
    
    fileprivate var _slaveDMGName = ""
    fileprivate var _slaveDMGPath = ""
    fileprivate var _slaveDMGFullPath = ""
    fileprivate let _slaveDMGPassword = "67890"
    fileprivate var _slaveVolumePath = ""
    fileprivate var _slaveVolumeURL = TestsConfiguration.API_BASE_URL


    fileprivate static var _prefix=Bartleby.createUID()

    override class func setUp() {
        super.setUp()
        self._treeId = "synchronized_tests"
    }

    override func setUp() {
        super.setUp();

        self._masterDMGName = LocalDMGSyncTests._prefix+"_Master"
        self._masterDMGPath = self.assetPath + self._masterDMGName
        self._masterDMGFullPath = self._masterDMGPath + "."+BsyncDMGCard.DMG_EXTENSION
        self._masterVolumePath = "/Volumes/" + self._masterDMGName + "/"
        self._masterVolumeURL = URL(fileURLWithPath: self._masterVolumePath)
        
        
        self.sourceFolderPath = self._masterVolumePath+LocalDMGSyncTests._treeId+"/"
        
        self._slaveDMGName = LocalDMGSyncTests._prefix+"_Slave"
        self._slaveDMGPath = self.assetPath + self._slaveDMGName
        self._slaveDMGFullPath = self._slaveDMGPath + "." + BsyncDMGCard.DMG_EXTENSION
        self._slaveVolumePath = "/Volumes/" + self._slaveDMGName + "/"
        self._slaveVolumeURL = URL(fileURLWithPath: self._slaveVolumePath)
        
        destinationFolderPath = self._slaveVolumePath+LocalDMGSyncTests._treeId+"/"
        
    }
    
    override func prepareSync(_ handlers: Handlers) {
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
    
    override func disposeSync(_ handlers: Handlers) {
        // Detach slave DMG
        self._diskManager.detachVolume(self._slaveDMGName, handlers: Handlers { (detachSlave) in
            if detachSlave.success {
                // Remove slave DMG
                do {
                    try self._fm.removeItem(atPath: self._slaveDMGFullPath)
                    // Detach master DMG
                    self._diskManager.detachVolume(self._masterDMGName, handlers: Handlers { (detachMaster) in
                        if detachMaster.success {
                            // Remove master DMG
                            do {
                                try self._fm.removeItem(atPath: self._masterDMGFullPath)
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
