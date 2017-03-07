//
//  BXWindowController.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 07/03/2017.
//  Copyright © 2017 Chaosmos SAS. All rights reserved.
//


#if os(OSX)

import AppKit
import BartlebyKit


open class BXWindowController: NSWindowController,MessageListener {

    open let UID=Bartleby.createUID()

    open func handle<T:StateMessage>(message:T){}
    
}

#endif

