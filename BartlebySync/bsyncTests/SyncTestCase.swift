//
//  SyncTestCase.swift
//  bsync
//
//  Created by Martin Delille on 06/06/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

/// Helper test class for sync
class SyncTestCase : TestCase {
    
    static private let _admin = BsyncAdmin()
    
    /**
     Run both directives (upstream and downstream)
     
     - parameter upDirectives:   Upstream directives
     - parameter downDirectives: Downstream directives
     - parameter handlers:       The progress and completion handlers
     */
    func runUpDownSynchronization(upDirectives: BsyncDirectives, downDirectives: BsyncDirectives, handlers: Handlers) {
        SyncTestCase._admin.runDirectives(upDirectives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: Handlers { (upSync) in
            if upSync.success {
                SyncTestCase._admin.runDirectives(downDirectives, sharedSalt: TestsConfiguration.SHARED_SALT, handlers: handlers)
            } else {
                handlers.on(upSync)
            }
            })
    }
}