//
//  CompletionNotification.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 03/05/2016.
//
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import Alamofire
    import ObjectMapper
#endif

public let BARTLEBYS_COMPLETION_NOTIFICATION_NAME="BARTLEBYS_COMPLETION_NOTIFICATION_NAME"

/// A Completion notification
extension Notification {

    public init(completionState: Completion, object: AnyObject?) {
       self.init(name: Notification.Name(rawValue: BARTLEBYS_COMPLETION_NOTIFICATION_NAME), object: object, userInfo:completionState.toJSON())
    }

    public func getCompletionState() -> Completion? {
        if let dictionary=(self as NSNotification).userInfo as? [String:AnyObject] {
            let completion = Mapper<Completion>().map(JSON: dictionary)
            return completion
        }
        return nil
    }

}
