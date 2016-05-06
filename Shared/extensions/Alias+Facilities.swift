//
//  Alias+Facilities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 30/03/2016.
//
//

import Foundation

public extension Alias {

    // TODO @bpds how to secure ReferenceName?

    public convenience init(withInstanceUID iUID: String, referenceName: String) {
        self.init()
        self.iUID=iUID
        self.iReferenceName=referenceName
    }

    func toInstance<T: Collectible>() -> T? {
        return Registry.registredObjectByUID(self.iUID) as T?
    }

    func toCollectibleInstance() -> Collectible? {
        return Registry.collectibleInstanceByUID(self.iUID)
    }
}
