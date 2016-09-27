//
//  BsyncContext.swift
//  bsync
//
//  Created by Benoit Pereira da silva on 31/12/2015.
//  Copyright © 2015 Benoit Pereira da silva. All rights reserved.
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import ObjectMapper
    import BartlebyKit
#endif

// Due to partial port to swift2.0
// de-encaspulation of read only properties was necessary to allow mapping from swift.
// (!)  when all the code base will be ported we should reencapsulate
// sourceTreeId, destinationTreeId, sourceBaseUrln destinationBaseUrl, hashMapViewName, syncID
@objc(BsyncContext) open class BsyncContext: PdSSyncContext, Mappable {


    // Can be used during long operation to relog
    // and to give to the ACL layer contextual information like defining the spaceUID
    var credentials: BsyncCredentials?

    // MARK: Mappable

    var hashmapAsADictionary: Dictionary<String, [String:String]> {
        get {
            if let f=self.finalHashMap {
                return f.dictionaryRepresentation() as! Dictionary<String, [String:String]>
            }
            return Dictionary<String, [String:String]>()
        }
        set {
            self.finalHashMap=HashMap.fromDictionary(hashmapAsADictionary)
        }
    }

    override init() {
        super.init()
    }

    init(sourceURL: URL, andDestinationUrl: URL, restrictedTo hashMapViewName: String?, autoCreateTrees: Bool=false) {
        super.init(sourceUrl: sourceURL, andDestinationUrl: andDestinationUrl, restrictedTo: hashMapViewName)
        self.autoCreateTrees=autoCreateTrees
    }


    // MARK: Mappable

    required public init?(map: Map) {
        super.init()
        self.mapping(map:map)
    }

    open func mapping(map: Map) {
        self.credentials <- map ["credentials"]
        self.hashmapAsADictionary <- map["hashmapAsADictionary"]
        self.repositoryPath <- map["repositoryPath"]
        self.sourceTreeId <- map["sourceTreeId"]
        self.destinationTreeId <- map["destinationTreeId"]
        self.sourceBaseUrl <- (map["sourceBaseUrl"], URLTransform())
        self.destinationBaseUrl <- (map["destinationBaseUrl"], URLTransform())
        self.hashMapViewName <- map["hashMapViewName"]
        self.numberOfCompletedCommands <- map["numberOfCompletedCommands"]
        self.numberOfCommands <- map["numberOfCommands"]
        self.autoCreateTrees <- map["autoCreateTrees"]
    }

}
