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
extension Notification {

    public init(completionState: Completion, object: AnyObject?) {
        let data = (try? JSONEncoder().encode(completionState)) ?? Data()
        self.init(name: Notification.Name(rawValue: BARTLEBYS_COMPLETION_NOTIFICATION_NAME), object: object, userInfo:["data":data])
    }

    public func getCompletionState() -> Completion? {
        if let dictionary=(self as NSNotification).userInfo as? [String:AnyObject] {
            if let data = dictionary["data"] as? Data{
                return try? JSONDecoder().decode(Completion.self, from: data)
            }
        }
        return nil
    }

}
