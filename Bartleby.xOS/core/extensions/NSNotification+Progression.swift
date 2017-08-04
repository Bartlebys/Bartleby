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
        let data = (try? JSON.encoder.encode(progressionState)) ?? Data()
        self.init(name: Notification.Name(rawValue: BARTLEBYS_COMPLETION_NOTIFICATION_NAME), object: object, userInfo:["data":data])
    }

    public func getProgressionState() -> Progression? {
        if let dictionary=(self as NSNotification).userInfo as? [String:AnyObject] {
            if let data = dictionary["data"] as? Data{
                return try? JSON.decoder.decode(Progression.self, from: data)
            }
        }
        return nil
    }

}
