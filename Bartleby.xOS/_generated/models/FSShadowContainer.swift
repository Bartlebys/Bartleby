//
//  FSShadowContainer.swift
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

// MARK: Bartleby's Synchronized File System: A container With shadows of Boxes,Nodes,Blocks
@objc(FSShadowContainer) open class FSShadowContainer : BartlebyObject{

    // Universal type support
    override open class func typeName() -> String {
        return "FSShadowContainer"
    }

	//Boxes
	dynamic open var boxes:[BoxShadow] = [BoxShadow]()

	//Nodes
	dynamic open var nodes:[NodeShadow] = [NodeShadow]()

	//Blocks
	dynamic open var blocks:[BlockShadow] = [BlockShadow]()

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["boxes","nodes","blocks"])
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
            case "boxes":
                if let casted=value as? [BoxShadow]{
                    self.boxes=casted
                }
            case "nodes":
                if let casted=value as? [NodeShadow]{
                    self.nodes=casted
                }
            case "blocks":
                if let casted=value as? [BlockShadow]{
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
        self.silentGroupedChanges {
			self.boxes <- ( map["boxes"] )
			self.nodes <- ( map["nodes"] )
			self.blocks <- ( map["blocks"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self.boxes=decoder.decodeObject(of: [NSArray.classForCoder(),BoxShadow.classForCoder()], forKey: "boxes")! as! [BoxShadow]
			self.nodes=decoder.decodeObject(of: [NSArray.classForCoder(),NodeShadow.classForCoder()], forKey: "nodes")! as! [NodeShadow]
			self.blocks=decoder.decodeObject(of: [NSArray.classForCoder(),BlockShadow.classForCoder()], forKey: "blocks")! as! [BlockShadow]
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
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
        return "fSShadowContainers"
    }

    override open var d_collectionName:String{
        return FSShadowContainer.collectionName
    }
}


// MARK: Shadow

open class FSShadowContainerShadow :FSShadowContainer,Shadow{

    static func from(_ entity:FSShadowContainer)->FSShadowContainerShadow{
        let shadow=FSShadowContainerShadow()
        for k in entity.exposedKeys{
            try? shadow.setExposedValue(entity.getExposedValueForKey(k), forKey: k)
        }
        try? shadow.setShadowUID(UID: entity.UID)
        return shadow
    }

    // MARK: Universal type support

    override open class func typeName() -> String {
        return "FSShadowContainerShadow"
    }

    // MARK: Collectible

    override open class var collectionName:String{
        return "fSShadowContainersShadow"
    }

    override open var d_collectionName:String{
        return FSShadowContainerShadow.collectionName
    }
}