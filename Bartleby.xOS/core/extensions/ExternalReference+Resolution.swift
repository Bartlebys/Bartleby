//
//  ExternalReference.swift
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


enum ExternalReferenceError: Error {
    case notFound
}


extension ExternalReference {


    /**
     Sort of a virtual initializer.
     E.g : `let lockerRef=ExternalReference(iUID: lockerUID, iTypeName: Locker.typeName())`

     - parameter iUID:     the instance UID
     - parameter iTypeName: the instance typeName

     - returns: an External Reference.
     */
    public convenience init(iUID: String, iTypeName: String) {
        self.init()
        self.iUID=iUID
        self.iTypeName=iTypeName
    }

    /**
    External reference from a Generic Collectible Instance

     - parameter from: a Collectible instance

     - returns: the ExternalReference
     */
    public convenience init<T: Collectible>(from: T) {
        self.init()
        self.iUID=from.UID
        self.iTypeName=T.typeName()
        if let summary=from.summary{
            self.summary=summary
        }
    }


    /**
     Asynchronous resolution of the instance
     The resolution can be local or distant

     - parameter instanceCallBack: the closure that returns the instance.
     */
    public func fetchInstance<T: Collectible>(_ of: T.Type, instanceCallBack:((_ instance: T?)->())) {
        if let fetched = try? Registry.registredObjectByUID(self.iUID) as T {
            // Return the fetched instance.
            instanceCallBack(instance:fetched)
        } else {
            // Return nil
            instanceCallBack(nil)
        }
    }


    // MARK: - Synchronous Dealiasing


    /**
     Local Dealiasing

     - returns: the local instance
     */
    public func toLocalInstance<T: Collectible>() -> T? {
        return try? Registry.registredObjectByUID(self.iUID) as T
    }


}
