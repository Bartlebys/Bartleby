//
//  UnManagedModel.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 13/12/2016.
//
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif

// Models can be :
// - ManagedModel ( fully managed models)
// - UnManagedModel ( json & secure Coding serialization support no supervision, no change provisionning )
@objc(UnManagedModel) open class UnManagedModel: NSObject, Mappable, NSSecureCoding {

    // MARK: - Mappable

    required public init?(map: Map) {
    }

    open func mapping(map: Map) {
    }

    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init()
    }

    open func encode(with coder: NSCoder) {
    }

    open class var supportsSecureCoding:Bool{
        return true
    }

    required public override init() {
        super.init()
    }

    public func quietChanges(_ changes:()->()){
        changes()
    }

}
