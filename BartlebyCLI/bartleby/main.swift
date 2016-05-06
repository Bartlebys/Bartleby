    //
//  main.swift
//  bartleby
//
//  Created by Benoit Pereira da silva on 12/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation


    Bartleby.sharedInstance.configureWith(BartlebyDefaultConfiguration)

    let user=User()
    user.defineUID()
    user.email="bpds@me.com"


    let UID=user.UID
    let concreteAlias=ConcreteAlias<User>(withInstanceUID:UID, rn: user.referenceName)

    print("# Concretion #")
    let _=concreteAlias.toConcrete { (instance) in
        if let user=instance {
            print(user)
        } else {
            print("**NO USER!**")
        }
    }


// Instanciate the facade
let facade=BartlebysCommandFacade()
facade.actOnArguments()

var holdOn=true
let runLoop=NSRunLoop.currentRunLoop()
while (holdOn && runLoop.runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture()) ) {}
