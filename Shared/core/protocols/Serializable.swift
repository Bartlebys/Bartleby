//
//  Serializable.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 08/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.



import Foundation



/**
 *   Any object that is serializable can be serialized deserialized
 */
public protocol DataSerializable  {
    
    //The class should be securely intializable with a simple init
    //init()
    
    /**
     Serialize the current object with its type
     
     - returns: a NSData
     */
    func serialize() -> NSData

    func deserialize(data:NSData) ->DataSerializable
    
    // TODO: Should be splitter in a specific protocol
    /**
     Patch an existant instance by deserializing the data from NSData
     This approach is usefull for proxies.
     
     - parameter data: the NSData
     
     - returns: the patched Object
     */
    func patchWithSerializedData(data:NSData) ->DataSerializable
    
    /**
     Should return a dictionary composed of native members that can be serialized (!)
     
     - returns: the dictionary
     */
    func dictionaryRepresentation()->[String:AnyObject]

}

/**
 *  Must implement init
 */
public protocol Initializable{
    init()
}


public enum SerializableError : ErrorType {
}

/**
*   Any object that is serializable can be serialized deserialized 
*/
public protocol Serializable:DataSerializable,Initializable {
    
}



