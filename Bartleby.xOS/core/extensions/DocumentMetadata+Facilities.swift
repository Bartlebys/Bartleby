//
//  DocumentMetadata+Facilities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 22/09/2016.
//
//

import Foundation

public extension DocumentMetadata{

    public var document:BartlebyDocument? { return Bartleby.sharedInstance.getDocumentByUID(self.persistentUID) }

    public var debugTriggersHistory:Bool{ return true } // Should be set to False

    public var jsonReceivedTrigger:String{
        if let data = try? JSON.prettyEncoder.encode(self.receivedTriggers){
            if let string = String(data: data, encoding: Default.STRING_ENCODING){
                return string
            }
        }
        return "..."
    }

    public var jsonOperationsQuarantine:String{
        if let data = try? JSON.prettyEncoder.encode(self.operationsQuarantine){
            if let string = String(data: data, encoding: Default.STRING_ENCODING){
                return string
            }
        }
        return "..."
    }


    @objc public dynamic var currentUser:User?{
        get{
           return try? Bartleby.registredObjectByUID(self.currentUserUID)
        }
    }


    /// Store the user's UID, its email and computed Phone number.
    /// Those properties are used before full decryption
    ///  - to perform authentication and ask for an activation code.
    ///
    ///
    /// - Parameter user: the current user to memorize in the document metadata
    public func configureCurrentUser(_ user:User){
        /// Stores the current user UID
        self.currentUserUID=user.UID
        // Store the email and Phonenumber into the metadata
        // For user clarity purposes
        self.currentUserEmail=user.email
        if user.fullPhoneNumber.characters.count > 3 {
            self.currentUserFullPhoneNumber=user.fullPhoneNumber
        }
    }


    // MARK: - States Saving API


    /// Save the state of a codable into the metadata state dictionary
    /// E.g : save indexes, document related preferences (not app wide)
    ///
    /// - Parameters:
    ///   - value: the value
    ///   - byKey: the identification key (must be unique)
    public func saveStateOf<T:Codable>(_ value:T,identified byKey:String){
        if let value = try? JSON.encoder.encode(value){
            self.statesDictionary[byKey] = value
            self.document?.hasChanged()
        }
    }


    /// Recover the saved state
    ///
    /// - Parameter byKey: the identification key (must be unique)
    /// - Returns: the value
    public func getStateOf<T:Codable>(identified byKey:String)->T?{
        if let data = self.statesDictionary[byKey]{
            if let value = try? JSON.decoder.decode(T.self, from: data){
               return value
            }
        }
        return nil
    }


    /// Save a string into the metadata state dictionary
    /// E.g : save indexes, document related preferences (not app wide)
    ///
    /// - Parameters:
    ///   - string: the string
    ///   - byKey: the identification key (must be unique)
    public func saveStateString(_ string:String,identified byKey:String){
        if let data = Data(base64Encoded: string){
            self.statesDictionary[byKey] = data
            self.document?.hasChanged()
        }
    }


    /// Recover the saved string
    ///
    /// - Parameter byKey: the identification key (must be unique)
    /// - Returns: the string
    public func getString(identified byKey:String)->String?{
        if let base64Data = self.statesDictionary[byKey]{
            return try? base64Data.string(using: Default.STRING_ENCODING)
        }
        return nil
    }


}
