//
//  ManagedModel+Extended.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation



// A bunch of implementation that are not related to any specific protocol
extension ManagedModel{



    /// A constructor that allows to define the UID of the object
    ///
    /// - Parameter uid: the desired UID
    public convenience init(withUID uid:UID) {
        self.init()
        self._id = uid
    }

    /// Return true if the inspector has been openned.
    open var isInspectable:Bool{
        get{
            var inspectable=false
            if let m=self.referentDocument?.metadata{
                inspectable=m.changesAreInspectables
            }
            return inspectable
        }
    }

    // Returns the referent document UID
    open var documentUID:String{
        return self.referentDocument?.UID ?? Default.NO_UID
    }


    // The runTypeName is used when deserializing the insta@nce.
    open func runTimeTypeName() -> String {
        if self._runTimeTypeName == nil{
            self._runTimeTypeName = NSStringFromClass(type(of: self))
        }
        return self._runTimeTypeName!
    }

    // A a shortcut to the undo manager
    open var undoManager:UndoManager? { return self.referentDocument?.undoManager }

    // Begins a new Undo Grouping 
    open func beginUndoGrouping(){
        if let undoManager = self.undoManager{
            // Has an edit occurred already in this event?
            if undoManager.groupingLevel > 0 {
                // Close the last group
                undoManager.endUndoGrouping()
                // Open a new group
                undoManager.beginUndoGrouping()
            }
        }
    }

    // MARK: - Crypto properties support

    open func encodeCryptedString<Key>(value:String, codingKey:Key, container : inout KeyedEncodingContainer<Key>)throws{
       let crypted = try Bartleby.cryptoDelegate.encryptString(value,useKey:Bartleby.configuration.KEY)
       try container.encode(crypted, forKey: codingKey)
    }

    open func encodeCryptedStringIfPresent<Key>(value:String?, codingKey:Key, container : inout KeyedEncodingContainer<Key>)throws{
        if let string = value{
            let crypted = try Bartleby.cryptoDelegate.encryptString(string,useKey:Bartleby.configuration.KEY)
            try container.encodeIfPresent(crypted, forKey: codingKey)
        }
    }

    open func decodeCryptedString<Key>(codingKey:Key,from container : KeyedDecodingContainer<Key>) throws ->String{
        let crypted = try container.decode(String.self, forKey:codingKey)
        let decrypted = try Bartleby.cryptoDelegate.decryptString(crypted,useKey:Bartleby.configuration.KEY)
        return decrypted
    }

    open func decodeCryptedStringIfPresent<Key>(codingKey:Key,from container : KeyedDecodingContainer<Key>) throws ->String?{
        if let crypted = try container.decodeIfPresent(String.self, forKey:codingKey){
            let decrypted = try Bartleby.cryptoDelegate.decryptString(crypted,useKey:Bartleby.configuration.KEY)
            return decrypted
        }
        return nil
    }

}
