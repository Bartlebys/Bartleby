//
//  Transaction.swift
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

// MARK: Bartleby's Synchronized File System: a transaction is an operation
@objc(Transaction) open class Transaction : BartlebyObject{

    // Universal type support
    override open class func typeName() -> String {
        return "Transaction"
    }

	//the comment
	dynamic open var comment:String? {
	    didSet { 
	       if comment != oldValue {
	            self.provisionChanges(forKey: "comment",oldValue: oldValue,newValue: comment) 
	       } 
	    }
	}

	//The serialized operations (without the data)
	dynamic open var operations:[String] = [String]()

	//Transaction Status
	public enum Status:String{
		case committed = "committed"
		case pushed = "pushed"
	}
	open var status:Status = .committed  {
	    didSet { 
	       if status != oldValue {
	            self.provisionChanges(forKey: "status",oldValue: oldValue.rawValue,newValue: status.rawValue)  
	       } 
	    }
	}

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["comment","operations","status"])
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
            case "comment":
                if let casted=value as? String{
                    self.comment=casted
                }
            case "operations":
                if let casted=value as? [String]{
                    self.operations=casted
                }
            case "status":
                if let casted=value as? Transaction.Status{
                    self.status=casted
                }
            default:
                return try super.setExposedValue(value, forKey: key)
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
            case "comment":
               return self.comment
            case "operations":
               return self.operations
            case "status":
               return self.status
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
			self.comment <- ( map["comment"] )
			self.operations <- ( map["operations"] )// @todo marked generatively as Cryptable Should be crypted!
			self.status <- ( map["status"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self.comment=String(describing: decoder.decodeObject(of: NSString.self, forKey:"comment") as NSString?)
			self.operations=decoder.decodeObject(of: [NSArray.classForCoder(),NSString.self], forKey: "operations")! as! [String]
			self.status=Transaction.Status(rawValue:String(describing: decoder.decodeObject(of: NSString.self, forKey: "status")! as NSString))! 
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		if let comment = self.comment {
			coder.encode(comment,forKey:"comment")
		}
		coder.encode(self.operations,forKey:"operations")
		coder.encode(self.status.rawValue ,forKey:"status")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }

     required public init() {
        super.init()
    }

    // MARK: Identifiable

    override open class var collectionName:String{
        return "transactions"
    }

    override open var d_collectionName:String{
        return Transaction.collectionName
    }
}