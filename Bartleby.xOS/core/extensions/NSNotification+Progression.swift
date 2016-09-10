//
//  ProgressionNotification.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 03/05/2016.
//
//

import Foundation

public let BARTLEBYS_PROGRESSION_NOTIFICATION_NAME="BARTLEBYS_PROGRESSION_NOTIFICATION_NAME"

/// A Completion notification
extension Notification {

    public init(progressionState: Progression, object: AnyObject?) {
        (self as NSNotification).init(name: BARTLEBYS_PROGRESSION_NOTIFICATION_NAME, object: object, userInfo:progressionState.dictionaryRepresentation())
    }

    public func getProgressionState() -> Progression? {
        if let dictionary=(self as NSNotification).userInfo as? [String:AnyObject] {
            let progression = try? JSerializer.deserializeFromDictionary(dictionary)
            return  progression as? Progression
        }
        return nil
    }

}
