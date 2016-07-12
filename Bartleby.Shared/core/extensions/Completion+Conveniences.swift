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
    import Alamofire
#endif


extension Completion:ForwardableState {

}

extension Completion:Descriptible {

    public func toString() -> String {
        return "Completion success:\(success) statusCode:\(statusCode) \(data?.length ?? 0 ) bytes of data.\n\(message)"
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


    public static func successStateFromJHTTPResponse(context: JHTTPResponse) -> Completion {
        return Completion(success: true, message: messageFromStatus(context.httpStatusCode), statusCode: CompletionStatus(rawValue: context.httpStatusCode) ?? .Undefined)
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

    }

    public static func failureStateFromJHTTPResponse(context: JHTTPResponse) -> Completion {
        return Completion(success: false, message: messageFromStatus(context.httpStatusCode), statusCode: CompletionStatus(rawValue: context.httpStatusCode) ?? .Undefined)
    }


    public static func failureStateFromAlamofire<Value, Error:ErrorType>(response: Response<Value, Error>) -> Completion {
        var completionStatus=CompletionStatus.Undefined
        if let statusCode=response.response?.statusCode{
            completionStatus=CompletionStatus(rawValue:statusCode) ?? CompletionStatus.Undefined
        }
        if let value=response.result.value{
            return Completion(success: false, message: "\(value)", statusCode: completionStatus)
        }else{
            return Completion(success: false, message: "", statusCode: completionStatus)
        }

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
