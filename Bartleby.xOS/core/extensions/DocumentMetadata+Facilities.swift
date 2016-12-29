//
//  DocumentMetadata+Facilities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 22/09/2016.
//
//

import Foundation

public extension DocumentMetadata{

    public var debugTriggersHistory:Bool{ return true } // Should be set to False

    public var jsonReceivedTrigger:String{
        return self.receivedTriggers.toJSONString(prettyPrint: true) ?? "..."
    }

    public var jsonOperationsQuarantine:String{
        return self.operationsQuarantine.toJSONString(prettyPrint: true) ?? "..."
    }

    public dynamic var currentUser:User?{
        get{
           return try? Bartleby.registredObjectByUID(self.currentUserUID)
        }
        set{
            if let currentUser = currentUser{
                self.currentUserUID=currentUser.UID
            }else{
                self.currentUserUID=Default.NO_UID
            }
        }
    }

}
