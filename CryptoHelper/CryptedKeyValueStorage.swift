//
//  CryptedKeyValueStorage.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 08/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif

public class CryptedKeyValueStorage: Mappable {


    var storage: [String:String]=[String:String]()


    // MARK: Mappable

    public required init?(_ map: Map) {
        self.mapping(map)
    }

    public func mapping(map: Map) {
        storage <- (map["storage"], CryptedStringKeyValueTransform())
    }

}
