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
@objc(BsyncHashMap) class BsyncHashMap:JObject {

    open var pathToHash:Dictionary<String,String>=Dictionary<String,String>()


    // Universal type support
    override open class func typeName() -> String {
        return "BsyncHashMap"
    }


    // MARK: Mappable

    required public init?(map: Map) {
        super.init(map:map)
    }

    override open func mapping(map: Map) {
        super.mapping(map: map)
        self.silentGroupedChanges {
            self.pathToHash <- ( map["pathToHash"] )
        }
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
            self.pathToHash=decoder.decodeObject(of: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()], forKey: "pathToHash") as! Dictionary<String,String>
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(pathToHash,forKey:"pathToHash")
    }


    override open class var supportsSecureCoding:Bool{
        return true
    }


    required public init() {
        super.init()
    }

    // MARK: Identifiable

    override open class var collectionName:String{
        return "BsyncHashMaps"
    }

    override open var d_collectionName:String{
        return BsyncHashMap.collectionName
    }
    
}
