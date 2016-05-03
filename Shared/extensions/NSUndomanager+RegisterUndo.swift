//
//  NSUndomanager+RegisterUndo.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 09/02/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS


#if os(OSX)
    import Cocoa
#elseif os(iOS)
    import UIKit
#elseif os(watchOS)

#elseif os(tvOS)

#endif


//

private class SwiftUndoPerformer: NSObject {
    let closure: Void -> Void

    init(closure: Void -> Void) {
        self.closure = closure
    }

    @objc func performWithSelf(retainedSelf: SwiftUndoPerformer) {
        closure()
    }
}

public extension NSUndoManager {

    // With the objc magic casting undoManager.prepareWithInvocationTarget(self) as? UsersCollectionController fails
    // That's why we have added an registerUndo extension on NSUndoManager

    public func registerUndo(closure: Void -> Void) {
        let performer = SwiftUndoPerformer(closure: closure)
        registerUndoWithTarget(performer, selector: #selector(SwiftUndoPerformer.performWithSelf(_:)), object: performer)
        //(Passes unnecessary object to get undo manager to retain SwiftUndoPerformer)
    }

}
