//
//  Container.swift
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

// MARK: Bartleby's Synchronized File System: A container to store Boxes,Nodes,Blocks
@objc(Container) open class Container : ManagedModel{

    // Universal type support
    override open class func typeName() -> String {
        return "Container"
    }

	//You can setup a password
	dynamic open var password:String?

	//Boxes
	dynamic open var boxes:[Box] = [Box]()

	//Nodes
	dynamic open var nodes:[Node] = [Node]()

	//Blocks
	dynamic open var blocks:[Block] = [Block]()

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["password","boxes","nodes","blocks"])
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
            case "password":
                if let casted=value as? String{
                    self.password=casted
                }
            case "boxes":
                if let casted=value as? [Box]{
                    self.boxes=casted
                }
            case "nodes":
                if let casted=value as? [Node]{
                    self.nodes=casted
                }
            case "blocks":
                if let casted=value as? [Block]{
                    self.blocks=casted
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
            case "password":
               return self.password
            case "boxes":
               return self.boxes
            case "nodes":
               return self.nodes
            case "blocks":
               return self.blocks
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
        self.quietChanges {
			self.password <- ( map["password"] )
			self.boxes <- ( map["boxes"] )
			self.nodes <- ( map["nodes"] )
			self.blocks <- ( map["blocks"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.quietChanges {
			self.password=String(describing: decoder.decodeObject(of: NSString.self, forKey:"password") as NSString?)
			self.boxes=decoder.decodeObject(of: [NSArray.classForCoder(),Box.classForCoder()], forKey: "boxes")! as! [Box]
			self.nodes=decoder.decodeObject(of: [NSArray.classForCoder(),Node.classForCoder()], forKey: "nodes")! as! [Node]
			self.blocks=decoder.decodeObject(of: [NSArray.classForCoder(),Block.classForCoder()], forKey: "blocks")! as! [Block]
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		if let password = self.password {
			coder.encode(password,forKey:"password")
		}
		coder.encode(self.boxes,forKey:"boxes")
		coder.encode(self.nodes,forKey:"nodes")
		coder.encode(self.blocks,forKey:"blocks")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }

     required public init() {
        super.init()
    }

    override open class var collectionName:String{
        return "containers"
    }

    override open var d_collectionName:String{
        return Container.collectionName
    }
}