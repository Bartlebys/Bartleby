//
//  Alias.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 30/03/2016.
//
//

import Foundation

public class Alias<T:Collectible>:AbstractAlias {

    // MARK:  Aliases

    /*
     Those resolutions are asynchronous to permit asynchronous fetching
     We have deprecated the previous synchronous approach.
     For explicitly synchronous situations
     And added facilities toLocalInstance() and toLocalCollectibleInstance()
     */

    public required init() {
        super.init()
    }

    public convenience init(iUID: String, iReferenceName: String) {
        self.init()
        self.iUID=iUID
        self.iReferenceName=iReferenceName
    }

    // MARK: - ASynchronous

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


    // MARK: - Synchronous


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
