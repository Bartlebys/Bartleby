//
//  PrintEntries.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for [Benoit Pereira da Silva] (https://pereira-da-silva.com/contact)
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
//
// Copyright (c) 2016  [Bartleby's org] (https://bartlebys.org)   All rights reserved.
//
import Foundation
#if !USE_EMBEDDED_MODULES
import Alamofire
import ObjectMapper
#endif

// MARK: Bartleby's Core: an object used to Acknowledge a Trigger
@objc(PrintEntries) open class PrintEntries : BartlebyObject{

    // Universal type support
    override open class func typeName() -> String {
        return "PrintEntries"
    }

	//The subjects versions (used to analyze possible divergences)
	dynamic open var entries:[PrintEntry] = [PrintEntry]()  {
	 
	    didSet { 
	       if entries != oldValue {
	            self.provisionChanges(forKey: "entries",oldValue: oldValue,newValue: entries)  
	       } 
	    }
	}

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["entries"])
        return exposed
    }


    /// Set the value of the given key
    ///
    /// - parameter value: the value
    /// - parameter key:   the key
    ///
    /// - throws: throws an Exception when the key is not exposed
    override open func setExposedValue(_ value:Any?, forKey key: String) throws {
        switch key {
            case "entries":
                if let casted=value as? [PrintEntry]{
                    self.entries=casted
                }
            default:
                throw ObjectExpositionError.UnknownKey(key: key)
        }
    }


    /// Returns the value of an exposed key.
    ///
    /// - parameter key: the key
    ///
    /// - throws: throws Exception when the key is not exposed
    ///
    /// - returns: returns the value
    override open func getExposedValueForKey(_ key:String) throws -> Any?{
        switch key {
            case "entries":
               return self.entries
            default:
                return try super.getExposedValueForKey(key)
        }
    }
    // MARK: - Mappable

    required public init?(map: Map) {
        super.init(map:map)
    }

    override open func mapping(map: Map) {
        super.mapping(map: map)
        self.silentGroupedChanges {
			self.entries <- ( map["entries"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {super.init(coder: decoder)
        self.silentGroupedChanges {
			self.entries=decoder.decodeObject(of: [NSArray.classForCoder(),PrintEntry.classForCoder()], forKey: "entries")! as! [PrintEntry]
        }
    }

    override open func encode(with coder: NSCoder) {super.encode(with:coder)
		coder.encode(self.entries,forKey:"entries")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }


     required public init() {
        super.init()
    }

    // MARK: Identifiable

    override open class var collectionName:String{
        return "printEntry"
    }

    override open var d_collectionName:String{
        return PrintEntries.collectionName
    }

}
