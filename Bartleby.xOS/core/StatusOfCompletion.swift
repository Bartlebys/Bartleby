//
//  StatusOfCompletion.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 03/05/2016.
//
//

import Foundation

// Status Completions are Based on HTTP status Codes
// But can be used in any situation.
public enum StatusOfCompletion: Int {
    // Error
    case error = -1

    // Not Defined
    case undefined = 0

    // Relay
    case `continue` = 100
    case switching_Protocols = 101

    // Explicit Success
    case ok = 200
    case created = 201
    case accepted = 202
    case non_Authoritative_Information = 203
    case no_Content = 204
    case reset_Content = 205
    case partial_Content = 206

    // 3XX - redirections & ...
    case multiple_Choices = 300
    case moved_Permanently = 301
    case found = 302
    case see_Other = 303
    case not_modified = 304
    case use_Proxy = 305
    case unused = 306
    case temporary_Redirect = 307

    // 4XX
    case bad_Request = 400
    case unauthorized = 401
    case payment_Required = 402
    case forbidden = 403
    case not_Found = 404
    case method_Not_Allowed = 405
    case not_Acceptable = 406
    case proxy_Authentication_Required = 407
    case request_Timeout = 408
    case conflict = 409
    case gone = 410
    case length_Required = 411
    case precondition_Failed = 412
    case request_Entity_Too_Large = 413
    case request_URI_Too_Long = 414
    case unsupported_Media_Type = 415
    case requested_Range_Not_Satisfiable = 416
    case expectation_Failed = 417
    case locked = 423

    case internal_Server_Error = 500
    case not_Implemented = 501
    case bad_EndPointsGateway = 502
    case service_Unavailable = 503
    case endPointsGateway_Timeout = 504
    case http_Version_Not_Supported = 505

    public static func messageFromStatus(_ status: StatusOfCompletion) -> String {
        return messageFromStatus(status.rawValue)
    }

    public static func messageFromStatus(_ status: Int) -> String {
        var message: String
        switch status {
        case 100:
            message = NSLocalizedString("Continue", tableName: "system", comment: "Universal Http status code")
        case 101:
            message = NSLocalizedString("Switching Protocols", tableName: "system", comment: "Universal Http status code")
        case 200:
            message = NSLocalizedString("OK", tableName: "system", comment: "Universal Http status code")
        case 201:
            message = NSLocalizedString("Created", tableName: "system", comment: "Universal Http status code")
        case 202:
            message = NSLocalizedString("Accepted", tableName: "system", comment: "Universal Http status code")
        case 203:
            message = NSLocalizedString("Non-Authoritative Information", tableName: "system", comment: "Universal Http status code")
        case 204:
            message = NSLocalizedString("No Content", tableName: "system", comment: "Universal Http status code")
        case 205:
            message = NSLocalizedString("Reset Content", tableName: "system", comment: "Universal Http status code")
        case 206:
            message = NSLocalizedString("Partial Content", tableName: "system", comment: "Universal Http status code")
        case 300:
            message = NSLocalizedString("Multiple Choices", tableName: "system", comment: "Universal Http status code")
        case 301:
            message = NSLocalizedString("Moved Permanently", tableName: "system", comment: "Universal Http status code")
        case 302:
            message = NSLocalizedString("Found", tableName: "system", comment: "Universal Http status code")
        case 303:
            message = NSLocalizedString("See Other", tableName: "system", comment: "Universal Http status code")
        case 304:
            message = NSLocalizedString("Not Modified", tableName: "system", comment: "Universal Http status code")
        case 305:
            message = NSLocalizedString("Use Proxy", tableName: "system", comment: "Universal Http status code")
        case 306:
            message = NSLocalizedString("(Unused)", tableName: "system", comment: "Universal Http status code")
        case 307:
            message = NSLocalizedString("Temporary Redirect", tableName: "system", comment: "Universal Http status code")
        case 400:
            message = NSLocalizedString("Bad Request", tableName: "system", comment: "Universal Http status code")
        case 401:
            message = NSLocalizedString("Unauthorized", tableName: "system", comment: "Universal Http status code")
        case 402:
            message = NSLocalizedString("Payment Required", tableName: "system", comment: "Universal Http status code")
        case 403:
            message = NSLocalizedString("Forbidden", tableName: "system", comment: "Universal Http status code")
        case 404:
            message = NSLocalizedString("Not Found", tableName: "system", comment: "Universal Http status code")
        case 405:
            message = NSLocalizedString("Method Not Allowed", tableName: "system", comment: "Universal Http status code")
        case 406:
            message = NSLocalizedString("Not Acceptable", tableName: "system", comment: "Universal Http status code")
        case 407:
            message = NSLocalizedString("Proxy Authentication Required", tableName: "system", comment: "Universal Http status code")
        case 408:
            message = NSLocalizedString("Request Timeout", tableName: "system", comment: "Universal Http status code")
        case 409:
            message = NSLocalizedString("Conflict", tableName: "system", comment: "Universal Http status code")
        case 410:
            message = NSLocalizedString("Gone", tableName: "system", comment: "Universal Http status code")
        case 411:
            message = NSLocalizedString("Length Required", tableName: "system", comment: "Universal Http status code")
        case 412:
            message = NSLocalizedString("Precondition Failed", tableName: "system", comment: "Universal Http status code")
        case 413:
            message = NSLocalizedString("Request Entity Too Large", tableName: "system", comment: "Universal Http status code")
        case 414:
            message = NSLocalizedString("Request-URI Too Long", tableName: "system", comment: "Universal Http status code")
        case 415:
            message = NSLocalizedString("Unsupported Media Type", tableName: "system", comment: "Universal Http status code")
        case 416:
            message = NSLocalizedString("Requested Range Not Satisfiable", tableName: "system", comment: "Universal Http status code")
        case 417:
            message = NSLocalizedString("Expectation Failed", tableName: "system", comment: "Universal Http status code")
        case 423:
            message = NSLocalizedString("Locked", tableName: "system", comment: "Universal Http status code")
        case 500:
            message = NSLocalizedString("Internal Server Error", tableName: "system", comment: "Universal Http status code")
        case 501:
            message = NSLocalizedString("Not Implemented", tableName: "system", comment: "Universal Http status code")
        case 502:
            message = NSLocalizedString("Bad EndPointsGateway", tableName: "system", comment: "Universal Http status code")
        case 503:
            message = NSLocalizedString("Service Unavailable", tableName: "system", comment: "Universal Http status code")
        case 504:
            message = NSLocalizedString("EndPointsGateway Timeout", tableName: "system", comment: "Universal Http status code")
        case 505:
            message = NSLocalizedString("HTTP Version Not Supported", tableName: "system", comment: "Universal Http status code")
        default:
            message = NSLocalizedString("Undefined", tableName: "system", comment: "Universal Http status code")
        }
        return message
    }
}
