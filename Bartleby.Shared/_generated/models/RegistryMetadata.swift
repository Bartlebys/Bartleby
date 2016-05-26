//
//  RegistryMetadata.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for benoit@pereira-da-silva.com
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
// WE TRY TO GENERATE ANY REPETITIVE CODE AND TO IMPROVE THE QUALITY ITERATIVELY
//
// Copyright (c) 2015  Chaosmos | https://chaosmos.fr  All rights reserved.
//
import Foundation
#if !USE_EMBEDDED_MODULES
import Alamofire
import ObjectMapper
#endif

// MARK: Bartleby's Core: Complete implementation in JRegistryMetadata. All its properties are not observable.
@objc(RegistryMetadata) public class RegistryMetadata : JObject{

    // Universal type support
    override public class func typeName() -> String {
        return "RegistryMetadata"
    }

	//The data space UID can be shared between multiple registries.
	dynamic public var spaceUID:String = "\(Default.NO_UID)"
	//The user currently associated to the local instance of the registry
	public var currentUser:User?
	//The rootObject UID
	dynamic public var rootObjectUID:String = "\(Default.NO_UID)"
	//The url of the collaboration server
	dynamic public var collaborationServerURL:NSURL?
	//A collection of CollectionMetadatum
	public var collectionsMetadata:[CollectionMetadatum] = [CollectionMetadatum]()
	//The State dictionary to insure registry persistency 
	public var stateDictionary:[String:AnyObject] = [String:AnyObject]()
	//The collection of serialized Security-Scoped Bookmarks (you should store NSData)
	public var URLBookmarkData:[String:AnyObject] = [String:AnyObject]()
	//Save the password or not?
	dynamic public var saveThePassword:Bool = Bartleby.configuration.SAVE_PASSWORD_DEFAULT_VALUE
	//The url of the assets folder
	dynamic public var assetsFolderURL:NSURL?


    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
        self.lockAutoCommitObserver()
		self.spaceUID <- ( map["spaceUID"] )
		self.currentUser <- ( map["currentUser"] )
		self.rootObjectUID <- ( map["rootObjectUID"] )
		self.collaborationServerURL <- ( map["collaborationServerURL"], URLTransform() )
		self.collectionsMetadata <- ( map["collectionsMetadata"] )
		self.stateDictionary <- ( map["stateDictionary"] )
		self.URLBookmarkData <- ( map["URLBookmarkData"] )
		self.saveThePassword <- ( map["saveThePassword"] )
		self.assetsFolderURL <- ( map["assetsFolderURL"], URLTransform() )
        self.unlockAutoCommitObserver()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.lockAutoCommitObserver()
		self.spaceUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "spaceUID")! as NSString)
		self.currentUser=decoder.decodeObjectOfClass(User.self, forKey: "currentUser") 
		self.rootObjectUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "rootObjectUID")! as NSString)
		self.collaborationServerURL=decoder.decodeObjectOfClass(NSURL.self, forKey:"collaborationServerURL") as NSURL?
		self.collectionsMetadata=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),CollectionMetadatum.classForCoder()]), forKey: "collectionsMetadata")! as! [CollectionMetadatum]
		self.stateDictionary=decoder.decodeObjectOfClasses(NSSet(array: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()]), forKey: "stateDictionary")as! [String:AnyObject]
		self.URLBookmarkData=decoder.decodeObjectOfClasses(NSSet(array: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()]), forKey: "URLBookmarkData")as! [String:AnyObject]
		self.saveThePassword=decoder.decodeBoolForKey("saveThePassword") 
		self.assetsFolderURL=decoder.decodeObjectOfClass(NSURL.self, forKey:"assetsFolderURL") as NSURL?
        self.unlockAutoCommitObserver()
    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		coder.encodeObject(self.spaceUID,forKey:"spaceUID")
		if let currentUser = self.currentUser {
			coder.encodeObject(currentUser,forKey:"currentUser")
		}
		coder.encodeObject(self.rootObjectUID,forKey:"rootObjectUID")
		if let collaborationServerURL = self.collaborationServerURL {
			coder.encodeObject(collaborationServerURL,forKey:"collaborationServerURL")
		}
		coder.encodeObject(self.collectionsMetadata,forKey:"collectionsMetadata")
		coder.encodeObject(self.stateDictionary,forKey:"stateDictionary")
		coder.encodeObject(self.URLBookmarkData,forKey:"URLBookmarkData")
		coder.encodeBool(self.saveThePassword,forKey:"saveThePassword")
		if let assetsFolderURL = self.assetsFolderURL {
			coder.encodeObject(assetsFolderURL,forKey:"assetsFolderURL")
		}
    }


    override public class func supportsSecureCoding() -> Bool{
        return true
    }


    required public init() {
        super.init()
    }

    // MARK: Identifiable

    override public class var collectionName:String{
        return "registryMetadatas"
    }

    override public var d_collectionName:String{
        return RegistryMetadata.collectionName
    }


}

