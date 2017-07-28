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
        guard let _ = self._runTimeTypeName  else {
            self._runTimeTypeName = NSStringFromClass(type(of: self))
            return self._runTimeTypeName!
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
