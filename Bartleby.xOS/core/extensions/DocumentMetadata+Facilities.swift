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
    }


    /// Store the user's UID, its email and computed Phone number.
    ///
    /// - Parameter user: the current user to memorize in the document metadata
    public func memorizeUser(_ user:User){

        /// Stores the current user UID
        self.currentUserUID=user.UID

        // Store the email and Phonenumber into the metadata
        // For user clarity purposes

        if let email=user.email{
            self.currentUserEmail=email
        }
        self.currentUserFullPhoneNumber=user.fullPhoneNumber
    }

}
