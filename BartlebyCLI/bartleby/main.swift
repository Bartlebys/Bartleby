//
//  main.swift
//  bartleby
//
//  Created by Benoit Pereira da silva on 12/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

// Instanciate the facade
let facade = BartlebysCommandFacade()
facade.actOnArguments()

var holdOn = true
let runLoop = RunLoop.current
while holdOn && runLoop.run(mode: RunLoopMode.defaultRunLoopMode, before: NSDate.distantFuture) {}
