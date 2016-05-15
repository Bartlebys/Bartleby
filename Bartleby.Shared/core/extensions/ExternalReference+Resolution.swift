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


extension ExternalReference {

    public convenience init(iUID: String, typeName: String) {
        self.init()
        self.iUID=iUID
        self.iTypeName=typeName
    }


    public convenience init<T: Collectible>(from: T) {
        self.init()
        self.iUID=from.UID
        self.iTypeName=T.typeName()
        self.summary=from.summary
    }




    /**
     Asynchronous resolution of the instance
     The resolution can be local or distant

     - parameter instanceCallBack: the closure that returns the instance.
     */
    public func fetchInstance<T: Collectible>(of: T.Type, instanceCallBack:((instance: T?)->())) {
        let fetched=Registry.registredObjectByUID(self.iUID) as T?
        instanceCallBack(instance:fetched)
    }


    // MARK: - Synchronous Dealiasing


    /**
     Local Dealiasing

     - returns: the local instance
     */
    public func toLocalInstance<T: Collectible>() -> T? {
        return Registry.registredObjectByUID(self.iUID) as T?
    }


    // MARK : Loosely typing TO BE DEPRECATED
    /*

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


    /**
     Local Dealiasing

     - returns: the local instance without inferred type
     */
    public func toLocalCollectibleInstance() -> Collectible? {
        return Registry.collectibleInstanceByUID(self.iUID)
    }
 */

}
