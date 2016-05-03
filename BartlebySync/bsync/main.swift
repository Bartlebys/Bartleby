//
//  main.swift
//  Bartleby's Sync client aka "bsync"
//
//  "bsync" is a command line tool and a client library for BartlebySync 1.0
//  It allows to synchronizes local and distant grouped sets of files.
//  The standard synchronization topology relies on a client software and a light blind Restfull service, but it can work locally and using P2P.
//
//  BartlebySync 1.0 is not anymore retro-compatible with [PdSSync 1.0](https://github.com/benoit-pereira-da-silva/PdSSync)
//  But includes extended features like hashMapViews, synchronization directives, better interruptibility...
//
//  Full Port to swift 2.0 is in progress
//  so we often bridge the calls using swift wrappers.
//
//  Created by Benoit Pereira da Silva on 29/12/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license

import Cocoa


// Instanciate the facade
let facade=CommandsFacade()
facade.actOnArguments()

var holdOn=true
let runLoop=NSRunLoop.currentRunLoop()
while (holdOn && runLoop.runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture()) ) {}
