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



// IMPORTANT This class is very special.
// It adds a generic behaviour to an Objc AbstractAlias
// Generic Aliases are "Not visible" from Objc.
// You cannot add  @objc(Alias)
public class Alias<T:Collectible>:AbstractAlias {

    public required init() {
        super.init()
        self.iTypeName=NSStringFromClass(T.self as! AnyClass)
    }

    public convenience init(iUID: String) {
        self.init()
        self.iUID=iUID
        self.defineUID()
    }


    public convenience init(from: Collectible) {
        self.init()
        self.iUID=from.UID
        self.iTypeName=from.typeName()
        self.summary=from.summary
        self.defineUID()
        if !(from is T) {
            bprint("Type Missmatch \(T.self) <- \(from.typeName)", file:#file, function:#function, line:#line)
            ("Type Missmatch")
        }
    }

    // MARK: Serialization


    // Reference name transformations
    // To insure **cross product deserialization** of Aliases
    // Eg:  "_TtGC11BartlebyKit5AliasCS_3Tag_" or "_TtGC5bsync5AliasCS_3Tag_" are transformed to "Alias<Tag>"

    override public func typeName() -> String {
        return self.universalTypeName()
    }

    public func universalTypeName() -> String {
        return "Alias<\(self.iTypeName)>"
    }

    public static func realTypeName(from universalTypeName: String) -> String {
        if let match = universalTypeName.rangeOfString("(?<=<)[^>]+", options: .RegularExpressionSearch) {
            let aliasedTypeName=universalTypeName.substringWithRange(match)
            return _realTypeString(aliasedTypeName)
        }
        return "AdaptedReferenceError"
    }

    private static func _realTypeString(aliasedTypeName: String) -> String {
        return "\(Alias._serializablePrefix())\(aliasedTypeName)\(Alias._serializableSuffix())"
    }

    private static func _serializablePrefix() -> String {
        let alias=Alias()
        let s: String=NSStringFromClass(alias.dynamicType)
        return s.substringToIndex(s.rangeOfString("Alias")!.startIndex)
    }

    private static func _serializableSuffix() -> String {
        let alias=Alias()
        let s: String=NSStringFromClass(alias.dynamicType)
        return s.substringFromIndex(s.rangeOfString("Alias")!.endIndex)
    }


    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
        mapping(map)
    }


    override public func mapping(map: Map) {
        super.mapping(map)
        if map.mappingType == .ToJSON {
            // We inject the universal type name
            self._typeName=self.typeName()
        }
        self._typeName <- map[Default.TYPE_NAME_KEY]

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
