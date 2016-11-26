//
//  BartlebyObject+Extended.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation

// A bunch of implementation that are not related to any specific protocol
extension BartlebyObject{

    /**
     The creation of a Unique Identifier is ressource intensive.
     We create the UID only if necessary.
     */
    open func defineUID() {
        if self._id == Default.NO_UID {
            self._id=Bartleby.createUID()
        }
    }

    // Returns the UID
    final public var UID: String {
        get {
            self.defineUID()
            return  self._id
        }
    }


    /// Return true if the inspector has been openned.
    open var isInspectable:Bool{
        get{
            var inspectable=false
            if let m=self.document?.metadata{
                inspectable=m.changesAreInspectables
            }
            return inspectable
        }
    }

    // Retunrns the document UID
    open var documentUID:String{
        return self.document?.UID ?? Default.NO_UID
    }


    // The runTypeName is used when deserializing the instance.
    open func runTimeTypeName() -> String {
        guard let _ = self._runTimeTypeName  else {
            self._runTimeTypeName = NSStringFromClass(type(of: self))
            return self._runTimeTypeName!
        }
        return self._runTimeTypeName!
    }


}
