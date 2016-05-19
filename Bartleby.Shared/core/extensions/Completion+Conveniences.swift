//
//  Completion+Facilities.swift
//  bsync
//
//  Created by Martin Delille on 26/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif


extension Completion:ForwardableStates {

}

extension Completion:Descriptible {

    public func toString() -> String {
        return "Success \(success) StatusCode \(statusCode) \(data?.length ?? 0 ) bytes of data.\n\(message)"
    }

}


public extension Completion {
    /**
     Convenience initializer.

     - parameter success:    is it a success?
     - parameter message:    an optionnal message
     - parameter statusCode: the status conde

     - returns: a Completion state instance
     */
    private convenience init(success: Bool, message: String="", statusCode: CompletionStatus = .Undefined, data: NSData? = nil) {
        self.init()
        self.success = success
        self.message = message
        self.statusCode = statusCode.rawValue
        self.data = data
    }


    /**
     The default state

     - returns: return value description
     */
    public static func defaultState() -> Completion {
        return Completion(success:false, message:"", statusCode:.Undefined)
    }


    /**
     The success state

     - returns: return value description
     */
    public static func successState(message: String = "", statusCode: CompletionStatus = .OK, data: NSData? = nil) -> Completion {
        return Completion(success:true, message: message, statusCode:statusCode, data: data)
    }



    /**
     The Failure state

     - returns: return value description
     */
    public static func failureState(message: String, statusCode: CompletionStatus) -> Completion {
        return Completion(success:false, message:message, statusCode:statusCode)
    }



    public static func failureStateFromError(error: ErrorType) -> Completion {
        let nse = error as NSError
        return Completion(success: false, message: nse.localizedDescription, statusCode: CompletionStatus(rawValue: nse.code) ?? .Undefined)
        /*
        if let nse = error as NSError {
            return Completion(success: false, message: nse.localizedDescription, statusCode: CompletionStatus(rawValue: nse.code) ?? .Undefined)
        } else {
            return Completion(success: false, message: "\(error)", statusCode:.Undefined)
        }*/

    }

    public static func failureStateFromJHTTPResponse(context: JHTTPResponse) -> Completion {
                return Completion(success: false, message: messageFromStatus(context.httpStatusCode), statusCode: CompletionStatus(rawValue: context.httpStatusCode) ?? .Undefined)
    }

    /**
     Returns self embedded in a progression Notification

     - returns: a Progression notification
     */
    public var completionNotification: NSNotification {
        get {
            return NSNotification(completionState:self, object:nil)
        }
    }
}
