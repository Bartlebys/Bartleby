//
//  Alias+Facilities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 30/03/2016.
//
//

import Foundation


public class ConcreteAlias<T:Collectible>:Alias {
    /**
     Lazy resolution of the instance, with inferred type.

     - parameter instance: the instance return closure
     */

    /**
     Asynchronous resolution of the instance

     - parameter type:     the attended type
     - parameter instance: the returned instance
     */
    public func toConcrete(call:((instance: T?)->())) {
        call(instance:Registry.registredObjectByUID(self.iUID) as T?)
    }


    public required init() {
        super.init()
    }

    public convenience init(withInstanceUID: String, rn: String) {
        self.init()
        self.iUID=iUID
        self.iReferenceName=referenceName
    }


}



public extension Alias {

    // TODO @bpds how to secure ReferenceName?
    public convenience init(withInstanceUID iUID: String, referenceName: String) {
        self.init()
        self.iUID=iUID
        self.iReferenceName=referenceName
    }


    // MARK:  Aliases Resolution
    // TODO @bpds should we throw on to & toCollectible?

    /*
        Those resolutions are asynchronous to permit asynchronous fetching
        We have deprecated the previous synchronous approach.
        To be able to support future asynchronous Adapters and various ditributed topologies

        Legacy approach was :

        ```
            func toInstance<T: Collectible>() -> T? {
                return Registry.registredObjectByUID(self.iUID) as T?
            }

            func toCollectibleInstance() -> Collectible? {
                return Registry.collectibleInstanceByUID(self.iUID)
            }

        ```

     */


    /**
     Lazy resolution of the instance, with inferred type.

     - parameter instance: the instance return closure
     */

    /**
     Asynchronous resolution of the instance

     - parameter type:     the attended type
     - parameter instance: the returned instance
     */
    func to<T: Collectible>( instance:((instance: T?)->())) {
        instance(instance:Registry.registredObjectByUID(self.iUID) as T?)
    }


    /**
     Asynchronous resolution of the instance, without inferred type.
     This approach is used in fully dynamic situations.
     If possible you should use ```to<T: Collectible>(instance:((instance: T?)->()))```

     - parameter instance: the instance return closure
     */
    func toCollectible(instance:((instance: Collectible?)->())) {
        instance(instance:Registry.collectibleInstanceByUID(self.iUID))
    }


    // DEPRECATED

    func toInstance<T: Collectible>() -> T? {
        return Registry.registredObjectByUID(self.iUID) as T?
    }

    func toCollectibleInstance() -> Collectible? {
        return Registry.collectibleInstanceByUID(self.iUID)
    }

}
