
//
//  CompletionStatus.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 03/05/2016.
//
//

import Foundation

// Completions status.
// Based on HTTP status Codes
public enum CompletionStatus: Int {

    // Error
    case Error = -1

    // Not Defined
    case Undefined = 0

    // Relay
    case Continue = 100
    case Switching_Protocols = 101

    // Explicit Success
    case OK = 200
    case Created = 201
    case Accepted = 202
    case Non_Authoritative_Information = 203
    case No_Content = 204
    case Reset_Content = 205
    case Partial_Content = 206

    // 3XX - redirections & ...
    case Multiple_Choices = 300
    case Moved_Permanently = 301
    case Found = 302
    case See_Other = 303
    case Not_modified = 304
    case Use_Proxy = 305
    case Unused = 306
    case Temporary_Redirect = 307

    // 4XX
    case Bad_Request = 400
    case Unauthorized = 401
    case Payment_Required = 402
    case Forbidden = 403
    case Not_Found = 404
    case Method_Not_Allowed = 405
    case Not_Acceptable = 406
    case Proxy_Authentication_Required = 407
    case Request_Timeout = 408
    case Conflict = 409
    case Gone = 410
    case Length_Required = 411
    case Precondition_Failed = 412
    case Request_Entity_Too_Large = 413
    case Request_URI_Too_Long = 414
    case Unsupported_Media_Type = 415
    case Requested_Range_Not_Satisfiable = 416
    case Expectation_Failed = 417
    case Locked = 423

    case Internal_Server_Error = 500
    case Not_Implemented = 501
    case Bad_EndPointsGateway = 502
    case Service_Unavailable = 503
    case EndPointsGateway_Timeout = 504
    case HTTP_Version_Not_Supported = 505

}

/**
 Maps Exit code to CompletionStatus , HTTP codes

 - parameter value: the value

 - returns: the status
 */
public func completionStatusFromExitCodes(value: Int32) -> CompletionStatus {
    /*
     public var EX_OK: Int32 { get } /* successful termination */
     public var EX__BASE: Int32 { get } /* base value for error messages */
     public var EX_USAGE: Int32 { get } /* command line usage error */
     public var EX_DATAERR: Int32 { get } /* data format error */
     public var EX_NOINPUT: Int32 { get } /* cannot open input */
     public var EX_NOUSER: Int32 { get } /* addressee unknown */
     public var EX_NOHOST: Int32 { get } /* host name unknown */
     public var EX_UNAVAILABLE: Int32 { get } /* service unavailable */
     public var EX_SOFTWARE: Int32 { get } /* internal software error */
     public var EX_OSERR: Int32 { get } /* system error (e.g., can't fork) */
     public var EX_OSFILE: Int32 { get } /* critical OS file missing */
     public var EX_CANTCREAT: Int32 { get } /* can't create (user) output file */
     public var EX_IOERR: Int32 { get } /* input/output error */
     public var EX_TEMPFAIL: Int32 { get } /* temp failure; user is invited to retry */
     public var EX_PROTOCOL: Int32 { get } /* remote error in protocol */
     public var EX_NOPERM: Int32 { get } /* permission denied */
     public var EX_CONFIG: Int32 { get } /* configuration error */
     public var EX__MAX: Int32 { get } /* maximum listed value */
     */

    switch value {
    case EX_OK:
        return CompletionStatus.OK
    case EX__BASE:
        return CompletionStatus.Bad_Request
    case EX_USAGE:
        return CompletionStatus.Not_Acceptable
    case EX_DATAERR:
        return CompletionStatus.Not_Acceptable
    case EX_NOINPUT:
        return CompletionStatus.Not_Found
    case EX_NOUSER:
        return CompletionStatus.Not_Acceptable
    case EX_NOHOST:
        return CompletionStatus.Not_Found
    case EX_UNAVAILABLE:
        return CompletionStatus.Not_Found
    case EX_SOFTWARE:
        return CompletionStatus.Internal_Server_Error
    case EX_OSERR:
        return CompletionStatus.Internal_Server_Error
    case EX_OSFILE:
        return CompletionStatus.Internal_Server_Error
    case EX_CANTCREAT:
        return CompletionStatus.Internal_Server_Error
    case EX_IOERR:
        return CompletionStatus.Internal_Server_Error
    case EX_TEMPFAIL:
        return CompletionStatus.Expectation_Failed
    case EX_PROTOCOL:
        return CompletionStatus.Expectation_Failed
    case EX_NOPERM:
        return CompletionStatus.Unauthorized
    case EX_CONFIG:
        return CompletionStatus.Precondition_Failed
    case EX__MAX:
        return CompletionStatus.Internal_Server_Error
    default:
        return CompletionStatus.Error
    }

}

public func completionStatusFromExitCodes(value: Int) -> CompletionStatus {
    return completionStatusFromExitCodes(Int32(value))
}

public func messageFromStatus(status: CompletionStatus) -> String {
    return messageFromStatus(status.rawValue)
}

public func messageFromStatus(status: Int) -> String {
    var message: String
    switch status {
    case 100:
        message = "Continue"
    case 101:
        message = "Switching Protocols"
    case 200:
        message = "OK"
    case 201:
        message = "Created"
    case 202:
        message = "Accepted"
    case 203:
        message = "Non-Authoritative Information"
    case 204:
        message = "No Content"
    case 205:
        message = "Reset Content"
    case 206:
        message = "Partial Content"
    case 300:
        message = "Multiple Choices"
    case 301:
        message = "Moved Permanently"
    case 302:
        message = "Found"
    case 303:
        message = "See Other"
    case 304:
        message = "Not Modified"
    case 305:
        message = "Use Proxy"
    case 306:
        message = "(Unused)"
    case 307:
        message = "Temporary Redirect"
    case 400:
        message = "Bad Request"
    case 401:
        message = "Unauthorized"
    case 402:
        message = "Payment Required"
    case 403:
        message = "Forbidden"
    case 404:
        message = "Not Found"
    case 405:
        message = "Method Not Allowed"
    case 406:
        message = "Not Acceptable"
    case 407:
        message = "Proxy Authentication Required"
    case 408:
        message = "Request Timeout"
    case 409:
        message = "Conflict"
    case 410:
        message = "Gone"
    case 411:
        message = "Length Required"
    case 412:
        message = "Precondition Failed"
    case 413:
        message = "Request Entity Too Large"
    case 414:
        message = "Request-URI Too Long"
    case 415:
        message = "Unsupported Media Type"
    case 416:
        message = "Requested Range Not Satisfiable"
    case 417:
        message = "Expectation Failed"
    case 423:
        message = "Locked"
    case 500:
        message = "Internal Server Error"
    case 501:
        message = "Not Implemented"
    case 502:
        message = "Bad EndPointsGateway"
    case 503:
        message = "Service Unavailable"
    case 504:
        message = "EndPointsGateway Timeout"
    case 505:
        message = "HTTP Version Not Supported"
    default:
        message = "Undefined"
    }
    return message
}
