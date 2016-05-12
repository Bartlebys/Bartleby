    //
//  main.swift
//  bartleby
//
//  Created by Benoit Pereira da silva on 12/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

// Instanciate the facade
//let facade=BartlebysCommandFacade()
//facade.actOnArguments()
  

graph_exec_completion_routine(TasksGroup.Priority.Background, useRandomPause:false, numberOfSequTask:5)
    
    

var holdOn=true
let runLoop=NSRunLoop.currentRunLoop()
while (holdOn && runLoop.runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture()) ) {}
