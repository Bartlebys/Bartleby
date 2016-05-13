//
//  Alias.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 30/03/2016.
//
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import Alamofire
    import ObjectMapper
#endif



// WILL NOT BE USED FOR
// !!! @bpds to be deleted
@objc(ExternalReference) public class ExternalReference: AbstractAlias {


    // Universal type support
    // To insure **cross product deserialization** of Aliases
    // Eg:  "_TtGC11BartlebyKit5AliasCS_3Tag_" or "_TtGC5bsync5AliasCS_3Tag_" are transformed to "Alias<Tag>"
    override public class func typeName() -> String {
        return "ExternalReference"
    }

    public required init() {
        super.init()
    }

    public convenience init(iUID: String, typeName: String) {
        self.init()
        self.iUID=iUID
    }


    public convenience init<T: Collectible>(from: T) {
        self.init()
        self.iUID=from.UID
        self.summary=from.summary
    }


    // MARK: Serialization

    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
        mapping(map)
    }


    override public func mapping(map: Map) {
        super.mapping(map)
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
    }


    override public class func supportsSecureCoding() -> Bool {
        return true
    }


    // MARK: Identifiable

    override public class var collectionName: String {
        return "ExternalReferences"
    }

    override public var d_collectionName: String {
        return ExternalReference.collectionName
    }



    /**
     Asynchronous resolution of the instance
     The resolution can be local or distant

     - parameter instanceCallBack: the closure that returns the instance.
     */
    public func fetchInstance<T: Collectible>(instanceCallBack:((instance: T?)->())) {
        let fetched=Registry.registredObjectByUID(self.iUID) as T?
        instanceCallBack(instance:fetched)
    }

    /**
     Asynchronous resolution of the instance, without inferred type.
     This approach is used in fully dynamic situations in witch the type should not be inferred
     E.G : interpreters
     If possible you should use ```to(call:((instance: T?)->()))```

     - parameter instance: the instance return closure
     */
    public func fetchCollectibleInstance(instanceCallBack:((instance: Collectible?)->())) {
        instanceCallBack(instance:Registry.collectibleInstanceByUID(self.iUID))
    }


    // MARK: - Synchronous Dealiasing


    /**
     Local Dealiasing

     - returns: the local instance
     */
    public func toLocalInstance<T: Collectible>() -> T? {
        return Registry.registredObjectByUID(self.iUID) as T?
    }

    /**
     Local Dealiasing

     - returns: the local instance without inferred type
     */
    public func toLocalCollectibleInstance() -> Collectible? {
        return Registry.collectibleInstanceByUID(self.iUID)
    }

}


///  The ALIAS APPROACH IS CURRENTLY NOT FULLY COMPLIANT WITH THE XPC Context.
///



// IMPORTANT This class is very special.
// It adds a generic behaviour to an Objc AbstractAlias
// Generic Aliases are "Not visible" from Objc.
public class Alias<T:Collectible>:AbstractAlias {


    // Universal type support
    // To insure **cross product deserialization** of Aliases
    // Eg:  "_TtGC11BartlebyKit5AliasCS_3Tag_" or "_TtGC5bsync5AliasCS_3Tag_" are transformed to "Alias<Tag>"
    override public class func typeName() -> String {
        return "Alias<\(T.typeName())>"
    }

    public required init() {
        super.init()
    }

    public convenience init(iUID: String) {
        self.init()
        self.iUID=iUID
    }


    public convenience init<T: Collectible>(from: T) {
        self.init()
        self.iUID=from.UID
        self.summary=from.summary
    }

    // MARK: Serialization

    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
        mapping(map)
    }


    override public func mapping(map: Map) {
        super.mapping(map)
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
    }


    override public class func supportsSecureCoding() -> Bool {
        return true
    }


    // MARK: Identifiable

    override public class var collectionName: String {
        return "aliases"
    }

    override public var d_collectionName: String {
        return Alias.collectionName
    }



    // MARK: - ASynchronous Fetching

    /**
     Asynchronous resolution of the instance
     The resolution can be local or distant

     - parameter instanceCallBack: the closure that returns the instance.
     */
    public func fetchInstance(instanceCallBack:((instance: T?)->())) {
        let fetched=Registry.registredObjectByUID(self.iUID) as T?
        instanceCallBack(instance:fetched)
    }

    /**
     Asynchronous resolution of the instance, without inferred type.
     This approach is used in fully dynamic situations in witch the type should not be inferred
     E.G : interpreters
     If possible you should use ```to(call:((instance: T?)->()))```

     - parameter instance: the instance return closure
     */
    public func fetchCollectibleInstance(instanceCallBack:((instance: Collectible?)->())) {
        instanceCallBack(instance:Registry.collectibleInstanceByUID(self.iUID))
    }


    // MARK: - Synchronous Dealiasing


    /**
     Local Dealiasing

     - returns: the local instance
     */
    public func toLocalInstance() -> T? {
        return Registry.registredObjectByUID(self.iUID) as T?
    }

    /**
     Local Dealiasing

     - returns: the local instance without inferred type
     */
    public func toLocalCollectibleInstance() -> Collectible? {
        return Registry.collectibleInstanceByUID(self.iUID)
    }

}
