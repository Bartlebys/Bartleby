//
//  ManagedModel+Extended.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation

// A bunch of implementation that are not related to any specific protocol
extension ManagedModel{


    /// You may want in very special circomstancies want to replace the UID of a ManagedModel
    /// for example before decrypting the Document in BartlebysUI to authenticate
    /// USE WITH CAUTION (!)
    ///
    /// - Parameter newUID: the new UID
    open func replaceUID(_ newUID:String){
        self._id = newUID
    }

    /// Return true if the inspector has been openned.
    open var isInspectable:Bool{
        get{
            var inspectable=false
            if let m=self.referentDocument?.metadata{
                inspectable=m.changesAreInspectables
            }
            return inspectable
        }
    }

    // Returns the referent document UID
    open var documentUID:String{
        return self.referentDocument?.UID ?? Default.NO_UID
    }


    // The runTypeName is used when deserializing the insta@nce.
    open func runTimeTypeName() -> String {
        if self._runTimeTypeName == nil{
            self._runTimeTypeName = NSStringFromClass(type(of: self))
        }
        return self._runTimeTypeName!
    }

    // A a shortcut to the undo manager
    open var undoManager:UndoManager? { return self.referentDocument?.undoManager }

    // Begins a new Undo Grouping 
    open func beginUndoGrouping(){
        if let undoManager = self.undoManager{
            // Has an edit occurred already in this event?
            if undoManager.groupingLevel > 0 {
                // Close the last group
                undoManager.endUndoGrouping()
                // Open a new group
                undoManager.beginUndoGrouping()
            }
        }
    }


}
