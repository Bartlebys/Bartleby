//
//  HTTPManager.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 16/09/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

#if !USE_EMBEDDED_MODULES
    import Alamofire
#endif

open class HTTPManager: NSObject {

    static open let SPACE_UID_KEY="spaceUID"
    static open let OBSERVATION_UID_KEY="observationUID"
    static open let KVID_KEY="kvid"


    static var baseURLApi: URL?

    static var userAgent: String {
        get {
            //@todo  implement cross anything user agent
            return "Bartleby\(Bartleby.versionString)/ (OS; Appversion; osVersion) (Apple; Mac)"
        }
    }

    fileprivate static var _hasBeenConfigured=false

    /**
     Configure the Manager
     */
    static open func configure()->() {
        if _hasBeenConfigured == false {
            let configuration = URLSessionConfiguration.default
            _ = SessionManager(configuration:configuration)
            _hasBeenConfigured=true
        }
    }


    // MARK: - Requests

    /**
     Returns a mutable request without a salted token.

     - parameter method: The Http Method
     - parameter url:    The URL

     - returns: the mutable request
     */
    static open func mutableRequestWithHeaders(_ method: String, url: URL) -> URLRequest {
        var request=URLRequest(url: url)
        request.httpMethod=method
        let headers=HTTPManager.baseHttpHeaders()
        for (k,v) in headers{
            request.addValue(v, forHTTPHeaderField: k)
        }
        return request
    }

    /**


     - parameter documentUID:   the Document UID
     - parameter actionName: the action name e.g : CreateUser
     - parameter method:     the HTTP method
     - parameter url:        the url.


     - returns: the mutable
     */


    ///  This method returns a mutable request with a salted token.
    ///
    /// - Parameters:
    ///   - documentUID: the document UID
    ///   - actionName: the action name
    ///   - method: the http Method
    ///   - url: the url
    ///   - oUID: an optional observationUID if not set we will use the document.UID
    /// - Returns: return value description
    static open func requestWithToken(inDocumentWithUID documentUID: String,
                                      withActionName actionName: String,
                                      forMethod method: String,
                                      and url: URL,
                                      observableBy oUID:String=Default.NO_UID) -> URLRequest {
        var request=URLRequest(url: url)
        request.httpMethod=method
        let headers=HTTPManager.httpHeadersWithToken(inDocumentWithUID:documentUID, withActionName: actionName)
        for (k,v) in headers{
            request.addValue(v, forHTTPHeaderField: k)
        }
        return request
    }

    // MARK: - HTTP Headers


    /**


     - parameter documentUID:   the Document UID
     - parameter actionName: the actionName
     - parameter method:     the HTTP method (POST,GET, PATCH, DELETE, PUT)
     - parameter url:        the url.

     - returns: the http Headers
     */


    ///  Returns the HTTP headers
    ///
    /// - Parameters:
    ///   - documentUID: the document UID (used to collect the spaceUID, the identification method, ...)
    ///   - actionName: the action Name (for token Permission level)
    ///   - oUID: an optional observationUID if not set we will use the document.UID
    /// - Returns: the HTTP headers
    static open func httpHeadersWithToken(inDocumentWithUID documentUID: String,
                                          withActionName actionName: String,
                                          observableBy oUID:String=Default.NO_UID)->[String:String]{
        var headers=HTTPManager.baseHttpHeaders()

        if let document=Bartleby.sharedInstance.getDocumentByUID(documentUID){

            // We prefer to Inject the token and spaceUID within the HTTP headers.
            // Note It is also possible to pass them as query strings.
            let tokenKey=HTTPManager.salt("\(actionName)#\(document.spaceUID)")
            let tokenValue=HTTPManager.salt(tokenKey)
            headers[tokenKey]=tokenValue

            // SpaceUID
            headers[HTTPManager.SPACE_UID_KEY]=document.spaceUID

            if document.metadata.identificationMethod == .key{
                if  let idv=document.metadata.identificationValue {
                    headers[HTTPManager.KVID_KEY]=idv
                }else{
                    headers[HTTPManager.KVID_KEY]=Default.VOID_STRING
                }
            }
            if oUID==Default.NO_UID{
                // We add the document observationUID
                headers[HTTPManager.OBSERVATION_UID_KEY]=document.UID
            }else{
                // We add the submitted observationUID
                headers[HTTPManager.OBSERVATION_UID_KEY]=oUID
            }
        }


        return headers
    }


    /**
     Returns a bunch of HTTP Header to be used in any Bartleby Http call

     - returns: the headers
     */
    static open func baseHttpHeaders()->[String:String]{
        var headers=[String:String]()
        Bartleby.requestCounter += 1
        headers["User-Agent"]=HTTPManager.userAgent
        headers["Accept"]="application/json"
        headers["Content-Type"]="application/json"
        headers["bartleby"]=Bartleby.versionString
        headers["runUID"]=Bartleby.runUID
        headers["requestCounter"]="\(Bartleby.requestCounter)" // Used for e.g to in Trigger UID = runUID.requestCounter
        if Bartleby.ephemeral {
            headers["ephemeral"]="true"
        }
        return headers
    }



    // MARK: - API

    /**
     Use this method to test if a server is Reachable

     - parameter baseURL:        the base URL
     - parameter successHandler: called on success
     - parameter failureHandler: called on failure
     */
    static open func apiIsReachable(_ baseURL: URL, successHandler:@escaping ()->(), failureHandler:@escaping (_ context: HTTPContext)->()) {
        let pathURL=baseURL.appendingPathComponent("/Reachable")
        let urlRequest=HTTPManager.requestWithToken(inDocumentWithUID:"", withActionName:"Reachable", forMethod:"GET", and: pathURL)
        request(urlRequest).validate().responseString { (response) in

            let request=response.request
            let result=response.result
            let timeline=response.timeline
            let statusCode=response.response?.statusCode ?? 0

            let metrics=Metrics()
            metrics.operationName="Reachable"
            metrics.latency=timeline.latency
            metrics.requestDuration=timeline.requestDuration
            metrics.serializationDuration=timeline.serializationDuration
            metrics.totalDuration=timeline.totalDuration


            // Bartleby consignation
            let context = HTTPContext( code: 1,
                                       caller: "Reachable",
                                       relatedURL:request?.url,
                                       httpStatusCode: statusCode)

            if let request=request{
                context.request=HTTPRequest(urlRequest: request)
            }

            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                context.responseString=utf8Text
            }

            metrics.httpContext=context

            if let url=request?.url{
                // We use Bartleby's report handler (because the document is not always defined when calling this endPoint)
                Bartleby.sharedInstance.report(metrics,forURL:url)
            }

            glog( NSLocalizedString("Server is not reachable",comment: "Server is not reachable")+NSLocalizedString("Please Check your connection or your configuration!",comment: "Please Check your connection or your configuration!"), file: #file, function: #function, line: #line)


            if result.isFailure {
                failureHandler(context)
            } else {
                if 200...299 ~= statusCode {
                    successHandler()
                } else {
                    if let value=result.value {
                        glog(value, file: #file, function: #function, line: #line)
                    }
                    failureHandler(context)
                }

            }
        }
    }




    /**
     Use this method to test if the current user is authorized

     - parameter baseURL:        the base URL
     - parameter documentUID:     the cibled Document UID
     - parameter successHandler: called on success
     - parameter failureHandler: called on failure
     */
    static open func verifyCredentials(_ documentUID: String, baseURL: URL, successHandler:@escaping ()->(), failureHandler:@escaping (_ context: HTTPContext)->()) {
        let pathURL=baseURL.appendingPathComponent("/verify/credentials")
        let document=Bartleby.sharedInstance.getDocumentByUID(documentUID)
        let urlRequest=HTTPManager.requestWithToken(inDocumentWithUID:documentUID, withActionName:"VerifyCredentials", forMethod:"GET", and: pathURL)
        request(urlRequest).validate().responseString { (response) in

            let request=response.request
            let result=response.result
            let timeline=response.timeline
            let statusCode=response.response?.statusCode ?? 0

            let metrics=Metrics()
            metrics.operationName="VerifyCredentials"
            metrics.latency=timeline.latency
            metrics.requestDuration=timeline.requestDuration
            metrics.serializationDuration=timeline.serializationDuration
            metrics.totalDuration=timeline.totalDuration


            // Bartleby consignation

            let context = HTTPContext( code: 1,
                                       caller: "verifyCredentials",
                                       relatedURL:request?.url,
                                       httpStatusCode: statusCode)

            if let request=request{
                context.request=HTTPRequest(urlRequest: request)
            }

            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                context.responseString=utf8Text
            }

            metrics.httpContext=context
            document?.report(metrics)

            // React according to the situation
            var reactions = Array<Reaction> ()
            reactions.append(Reaction.track(result: nil, context: context)) // Tracking

            let failureReaction =  Reaction.dispatchAdaptiveMessage(
                context: context,
                title: NSLocalizedString("Forbidden",
                                         comment: "Forbidden"),
                body: NSLocalizedString("Credentials are not valid",
                                        comment: "Credentials are not valid"),
                transmit: { (selectedIndex) -> () in
                    glog("Post presentation message selectedIndex:\(selectedIndex)", file: #file, function: #function, line: #line)
            })

            if result.isFailure {
                reactions.append(failureReaction)
                failureHandler(context)
            } else {
                if 200...299 ~= statusCode {
                    successHandler()
                } else {
                    reactions.append(failureReaction)
                    if let value=result.value {
                        glog(value, file: #file, function: #function, line: #line)
                    }
                    failureHandler(context)
                }

            }
        }
    }


    /**
     A Simple validation routine

     - parameter testStr: the string to be evaluated

     - returns: true if it is a valid email.
     */
    static open func isValidEmail(_ testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    
    /**
     Salts a string to guarante that the app "knows" the shared salt
     
     - parameter string: the string
     
     - returns: the salted value
     */
    static open func salt(_ string: String) -> String {
        return CryptoHelper.hash(string + Bartleby.configuration.SHARED_SALT)
    }
    
}
