//
//  Completion+Facilities.swift
//  bsync
//
//  Created by Martin Delille on 26/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import Alamofire
#endif

extension Completion: Descriptible {
    public func toString() -> String {
        return "Completion success:\(success) statusCode:\(statusCode) \(data?.count ?? 0) bytes of data.\n\(message) [\(category)/\(externalIdentifier)]"
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
    fileprivate convenience init(success: Bool, message: String = "", statusCode: StatusOfCompletion = .undefined, data: Data? = nil) {
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
    public func identifiedBy(_ category: String, identity: String) -> Completion {
        self.category = category
        externalIdentifier = identity
        return self
    }

    /**
     The default state

     - returns: return value description
     */
    public static func defaultState() -> Completion {
        return Completion(success: false, message: "", statusCode: .undefined)
    }

    /**
     The success state

     - returns: return value description
     */
    public static func successState(_ message: String = "", statusCode: StatusOfCompletion = .ok, data: Data? = nil) -> Completion {
        return Completion(success: true, message: message, statusCode: statusCode, data: data)
    }

    public static func successStateFromHTTPContext(_ context: HTTPContext) -> Completion {
        return Completion(success: true, message: StatusOfCompletion.messageFromStatus(context.httpStatusCode), statusCode: StatusOfCompletion(rawValue: context.httpStatusCode) ?? .undefined)
    }

    /**
     The Failure state

     - returns: return value description
     */
    public static func failureState(_ message: String, statusCode: StatusOfCompletion) -> Completion {
        return Completion(success: false, message: message, statusCode: statusCode)
    }

    public static func failureStateFromError(_ error: Error) -> Completion {
        let nse = error as NSError
        return Completion(success: false, message: "\(error)", statusCode: StatusOfCompletion(rawValue: nse.code) ?? .undefined)
    }

    public static func failureStateFromHTTPContext(_ context: HTTPContext) -> Completion {
        return Completion(success: false, message: StatusOfCompletion.messageFromStatus(context.httpStatusCode), statusCode: StatusOfCompletion(rawValue: context.httpStatusCode) ?? .undefined)
    }

    public static func failureStateFromAlamofire<Value>(_ response: DataResponse<Value>) -> Completion {
        var status = StatusOfCompletion.undefined
        if let statusCode = response.response?.statusCode {
            status = StatusOfCompletion(rawValue: statusCode) ?? StatusOfCompletion.undefined
        }
        if let value = response.result.value {
            return Completion(success: false, message: "\(value)", statusCode: status)
        } else {
            return Completion(success: false, message: "", statusCode: status)
        }
    }
}
