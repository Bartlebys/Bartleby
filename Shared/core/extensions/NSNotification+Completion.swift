//
//  CompletionNotification.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 03/05/2016.
//
//

import Foundation

public let BARTLEBYS_COMPLETION_NOTIFICATION_NAME="BARTLEBYS_COMPLETION_NOTIFICATION_NAME"

/// A Completion notification
extension NSNotification {

    public convenience init(completionState: Completion, object: AnyObject?) {
        self.init(name: BARTLEBYS_COMPLETION_NOTIFICATION_NAME, object: object, userInfo:completionState.dictionaryRepresentation())
    }

    public func getCompletionState() -> Completion? {
        if let dictionary=self.userInfo as? [String:AnyObject] {
              return JSerializer.sharedInstance.deserializeFromDictionary(dictionary) as? Completion
        }
        return nil
    }

}
