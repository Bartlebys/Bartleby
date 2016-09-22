//
//  RegistryMetadata+Facilities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 22/09/2016.
//
//

import Foundation

extension RegistryMetadata{

    dynamic var jsonReceivedTrigger:String{
        return self.receivedTriggers.toJSONString(true)!
    }

    dynamic var jsonOperationsQuarantine:String{
        return self.operationsQuarantine.toJSONString(true)!
    }

    dynamic var jsonTriggersQuarantine:String{
        return self.triggersQuarantine.toJSONString(true)!
    }

}
