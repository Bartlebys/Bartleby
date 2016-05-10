//
//  JCollectionMetadatum.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 03/11/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif


// The underlining model has been implemented by flexions in BaseCollectionMetadatum
public class JCollectionMetadatum: BaseCollectionMetadatum, CollectionMetadatum {

    // Universal type support
    override public class func typeName() -> String {
        return "JCollectionMetadatum"
    }


    public var proxy: JObject? {
        didSet {
            if let proxy=proxy as? Collectible {
                self.collectionName=proxy.d_collectionName
            }
        }
    }


    required public init() {
        super.init()
    }

    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }


    // MARK: NSecureCoding


    public override func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
    }

    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)

    }



    override public class func supportsSecureCoding() -> Bool {
        return true
    }



}
