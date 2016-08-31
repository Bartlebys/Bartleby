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
        return "Completion success:\(success) statusCode:\(statusCode) \(data?.length ?? 0 ) bytes of data.\n\(message) [\(category)/\(externalIdentifier)]"
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
    private convenience init(success: Bool, message: String="", statusCode: StatusOfCompletion  = .Undefined, data: NSData? = nil) {
        self.init()
        self.success = success
        self.message = message
        self.statusCode = statusCode.rawValue
        self.data = data
    }

    /**
     Used to identify states

     - parameter category: the category classifier
     - parameter identity: the identity

     - returns: the state
     */
    public func identifiedBy(_ category:String,_ identity:String)->Completion{
        self.category=category
        self.externalIdentifier=identity
        return self
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
    public static func successState(message: String = "", statusCode: StatusOfCompletion  = .OK, data: NSData? = nil) -> Completion {
        return Completion(success:true, message: message, statusCode:statusCode, data: data)
    }


    public static func successStateFromJHTTPResponse(context: JHTTPResponse) -> Completion {
        return Completion(success: true, message: StatusOfCompletion.messageFromStatus(context.httpStatusCode), statusCode: StatusOfCompletion (rawValue: context.httpStatusCode) ?? .Undefined)
    }


    /**
     The Failure state

     - returns: return value description
     */
    public static func failureState(message: String, statusCode: StatusOfCompletion ) -> Completion {
        return Completion(success:false, message:message, statusCode:statusCode)
    }



    public static func failureStateFromError(error: ErrorType) -> Completion {
        let nse = error as NSError
        return Completion(success: false, message: nse.localizedDescription, statusCode: StatusOfCompletion (rawValue: nse.code) ?? .Undefined)

    }

    public static func failureStateFromJHTTPResponse(context: JHTTPResponse) -> Completion {
        return Completion(success: false, message: StatusOfCompletion.messageFromStatus(context.httpStatusCode), statusCode: StatusOfCompletion (rawValue: context.httpStatusCode) ?? .Undefined)
    }


    public static func failureStateFromAlamofire<Value, Error:ErrorType>(response: Response<Value, Error>) -> Completion {
        var status = StatusOfCompletion .Undefined
        if let statusCode=response.response?.statusCode{
            status = StatusOfCompletion (rawValue:statusCode) ?? StatusOfCompletion .Undefined
        }
        if let value=response.result.value{
            return Completion(success: false, message: "\(value)", statusCode:status )
        }else{
            return Completion(success: false, message: "", statusCode: status )
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
