//
//  RegistryMetadata+Facilities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 22/09/2016.
//
//

import Foundation

extension RegistryMetadata{

    var debugTriggersHistory:Bool{ return true } // Should be set to False

    var jsonReceivedTrigger:String{
        return self.receivedTriggers.toJSONString(prettyPrint: true) ?? "..."
    }

    var jsonOperationsQuarantine:String{
        return self.operationsQuarantine.toJSONString(prettyPrint: true) ?? "..."
    }

}
