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
@objc(CollectionMetadatum) public class CollectionMetadatum : JObject{

    // Universal type support
    override public class func typeName() -> String {
        return "CollectionMetadatum"
    }

	//the used file storage
	public enum Storage:String{
		case MonolithicFileStorage = "MonolithicFileStorage"
		case SQLiteIncrementalStore = "SQLiteIncrementalStore"
	}
	public var storage:Storage = .MonolithicFileStorage
	//The holding collection name
	public var collectionName:String = "\(Default.NO_NAME)"
	//The proxy object (not serializable, not observable)
	public var proxy:JObject?
	//Allow distant persistency?
	public var allowDistantPersistency:Bool = true
	//In Memory?
	public var inMemory:Bool = true
	//The observable UID
	dynamic public var observableViaUID:String = "\(Default.NO_UID)"


    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
        self.lockAutoCommitObserver()
		self.storage <- ( map["storage"] )
		self.collectionName <- ( map["collectionName"] )
		self.allowDistantPersistency <- ( map["allowDistantPersistency"] )
		self.inMemory <- ( map["inMemory"] )
		self.observableViaUID <- ( map["observableViaUID"] )
        self.unlockAutoCommitObserver()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.lockAutoCommitObserver()
		self.storage=CollectionMetadatum.Storage(rawValue:String(decoder.decodeObjectOfClass(NSString.self, forKey: "storage")! as NSString))! 
		self.collectionName=String(decoder.decodeObjectOfClass(NSString.self, forKey: "collectionName")! as NSString)
		self.allowDistantPersistency=decoder.decodeBoolForKey("allowDistantPersistency") 
		self.inMemory=decoder.decodeBoolForKey("inMemory") 
		self.observableViaUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "observableViaUID")! as NSString)
        self.unlockAutoCommitObserver()
    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		coder.encodeObject(self.storage.rawValue ,forKey:"storage")
		coder.encodeObject(self.collectionName,forKey:"collectionName")
		coder.encodeBool(self.allowDistantPersistency,forKey:"allowDistantPersistency")
		coder.encodeBool(self.inMemory,forKey:"inMemory")
		coder.encodeObject(self.observableViaUID,forKey:"observableViaUID")
    }


    override public class func supportsSecureCoding() -> Bool{
        return true
    }


    required public init() {
        super.init()
    }

    // MARK: Identifiable

    override public class var collectionName:String{
        return "collectionMetadata"
    }

    override public var d_collectionName:String{
        return CollectionMetadatum.collectionName
    }


}

