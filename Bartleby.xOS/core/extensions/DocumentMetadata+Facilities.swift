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
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(self.receivedTriggers){
            if let string = String(data: data, encoding: Default.STRING_ENCODING){
                return string
            }
        }
        return "..."
    }

    public var jsonOperationsQuarantine:String{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(self.operationsQuarantine){
            if let string = String(data: data, encoding: Default.STRING_ENCODING){
                return string
            }
        }
        return "..."
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
        self.currentUserEmail=user.email
        if user.fullPhoneNumber.characters.count > 3 {
            self.currentUserFullPhoneNumber=user.fullPhoneNumber
        }
    }

}
