//
//  BsyncHashMap.swift
//  bsync
//
//  Created by Benoit Pereira da silva on 13/06/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import ObjectMapper
    import BartlebyKit
#endif



// Swift Adapter to Objective C Hash Map
@objc(BsyncHashMap) public class BsyncHashMap:JObject {

    public var pathToHash:Dictionary<String,String>=Dictionary<String,String>()


    // Universal type support
    override public class func typeName() -> String {
        return "BsyncHashMap"
    }


    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
        self.lockAutoCommitObserver()
        self.pathToHash <- ( map["pathToHash"] )
        self.unlockAutoCommitObserver()
    }

    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.lockAutoCommitObserver()
        self.pathToHash=decoder.decodeObjectOfClasses(NSSet(array: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()]), forKey: "pathToHash") as! Dictionary<String,String>
        self.unlockAutoCommitObserver()
    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
        coder.encodeObject(pathToHash,forKey:"pathToHash")
    }


    override public class func supportsSecureCoding() -> Bool{
        return true
    }


    required public init() {
        super.init()
    }

    // MARK: Identifiable

    override public class var collectionName:String{
        return "BsyncHashMaps"
    }

    override public var d_collectionName:String{
        return BsyncHashMap.collectionName
    }

}
