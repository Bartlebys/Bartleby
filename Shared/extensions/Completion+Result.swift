//
//  Completion+Result.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 03/05/2016.
//
//

import Foundation

extension Completion {

    /**
     Stores the result by serialization

     - parameter result: the serializable result
     */
    func setResult<T: Serializable>(result: T) {
        self.data=result.serialize()
    }

    /**
     Get result

     - parameter serializer: what serializer should we use?

     - returns: the deserialized result
     */
    func getResult<T: Serializable, S: Serializer>(usingSerializer serializer: S) -> T? {
        if let data=self.data {
            return serializer.deserialize(data) as? T
        }
        return nil
    }

}
