//
//  CollectionMetadatum.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for b@bartlebys.org
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
//
// Copyright (c) 2016  Bartleby's | https://bartlebys.org  All rights reserved.
//
import Foundation
#if !USE_EMBEDDED_MODULES
import Alamofire
import ObjectMapper
#endif

// MARK: Bartleby's Core: Collection Metadatum. Complete implementation in CollectionMetadatum
@objc(CollectionMetadatum) open class CollectionMetadatum : JObject{

    // Universal type support
    override open class func typeName() -> String {
        return "CollectionMetadatum"
    }

	//the used file storage
	public enum Storage:String{
		case monolithicFileStorage = "monolithicFileStorage"
	}
	open var storage:Storage = .monolithicFileStorage
	//The holding collection name
	dynamic open var collectionName:String = "\(Default.NO_NAME)"
	//The proxy object (not serializable, not supervisable)
	dynamic open var proxy:JObject?
	//Allow distant persistency?
	dynamic open var allowDistantPersistency:Bool = true
	//In Memory?
	dynamic open var inMemory:Bool = true


    // MARK: Mappable

    required public init?(map: Map) {
        super.init(map:map)
    }

    override open func mapping(map: Map) {
        super.mapping(map: map)
        self.silentGroupedChanges {
			self.storage <- ( map["storage"] )
			self.collectionName <- ( map["collectionName"] )
			self.allowDistantPersistency <- ( map["allowDistantPersistency"] )
			self.inMemory <- ( map["inMemory"] )
        }
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self.storage=CollectionMetadatum.Storage(rawValue:String(describing: decoder.decodeObject(of: NSString.self, forKey: "storage")! as NSString))! 
			self.collectionName=String(describing: decoder.decodeObject(of: NSString.self, forKey: "collectionName")! as NSString)
			self.allowDistantPersistency=decoder.decodeBool(forKey:"allowDistantPersistency") 
			self.inMemory=decoder.decodeBool(forKey:"inMemory") 
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self.storage.rawValue ,forKey:"storage")
		coder.encode(self.collectionName,forKey:"collectionName")
		coder.encode(self.allowDistantPersistency,forKey:"allowDistantPersistency")
		coder.encode(self.inMemory,forKey:"inMemory")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }


    required public init() {
        super.init()
    }

    // MARK: Identifiable

    override open class var collectionName:String{
        return "collectionMetadata"
    }

    override open var d_collectionName:String{
        return CollectionMetadatum.collectionName
    }


}

