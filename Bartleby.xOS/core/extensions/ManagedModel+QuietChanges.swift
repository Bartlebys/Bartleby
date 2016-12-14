//
//  Bartleby+QuietDeserialization.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation

public extension ManagedModel{


    public var wantsQuietChanges:Bool{
        return self._quietChanges
    }


    /// Performs the deserialization without invoking provisionChanges
    ///
    /// - parameter changes: the changes closure
    public func quietChanges(_ changes:()->()){
        self._quietChanges=true
        changes()
        self._quietChanges=false
    }
    
}
