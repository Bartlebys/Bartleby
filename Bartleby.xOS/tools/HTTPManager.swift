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

public class HTTPManager: NSObject {

    static public let SPACE_UID_KEY="spaceUID"


    static var baseURLApi: NSURL?

    static var userAgent: String {
        get {
            //@todo  implement cross anything user agent
            return "Bartleby\(Bartleby.versionString)/ (OS; Appversion; osVersion) (Apple; Mac)"
        }
    }



    private static var _hasBeenConfigured=false

    /**
     Configure the Manager
     */
    static public func configure()->() {
        if _hasBeenConfigured == false {
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            _ = Manager(configuration:configuration)
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
    static public func mutableRequestWithHeaders(method: String, url: NSURL) -> NSMutableURLRequest {
        let request=NSMutableURLRequest(URL: url)
        request.HTTPMethod=method
        let headers=HTTPManager.baseHttpHeaders()
        for (k,v) in headers{
            request.addValue(v, forHTTPHeaderField: k)
        }
        return request
    }

    /**
     This method returns a mutable request with a salted token.

     - parameter registryUID:   the registry UID
     - parameter actionName: the action name e.g : CreateUser
     - parameter method:     the HTTP method
     - parameter url:        the url.

     - returns: the mutable
     */
    static public func mutableRequestWithToken(inRegistryWithUID registryUID: String, withActionName actionName: String, forMethod method: String, and url: NSURL) -> NSMutableURLRequest {
        let request=NSMutableURLRequest(URL: url)
        request.HTTPMethod=method
        let headers=HTTPManager.httpHeadersWithToken(inRegistryWithUID:registryUID, withActionName: actionName)
        for (k,v) in headers{
            request.addValue(v, forHTTPHeaderField: k)
        }
        return request
    }

    // MARK: - HTTP Headers


    /**
     Returns the Http Headers

     - parameter registryUID:   the registry UID
     - parameter actionName: the actionName
     - parameter method:     the HTTP method (POST,GET, PATCH, DELETE, PUT)
     - parameter url:        the url.

     - returns: the http Headers
     */
    static public func httpHeadersWithToken(inRegistryWithUID registryUID: String, withActionName actionName: String)->[String:String]{
        var headers=HTTPManager.baseHttpHeaders()

        if let document=Bartleby.sharedInstance.getDocumentByUID(registryUID){

            // We prefer to Inject the token and spaceUID within the HTTP headers.
            // Note It is also possible to pass them as query strings.
            let tokenKey=HTTPManager.salt("\(actionName)#\(document.spaceUID)")
            let tokenValue=HTTPManager.salt(tokenKey)
            headers[tokenKey]=tokenValue

            // SpaceUID
            headers[HTTPManager.SPACE_UID_KEY]=document.spaceUID

                if document.registryMetadata.identificationMethod == .Key{
                    if  let idv=document.registryMetadata.identificationValue {
                        headers["kvid"]=idv
                    }else{
                        headers["kvid"]=Default.VOID_STRING
                    }
                }
                // We add the observationUID
                headers["observationUID"]=document.UID

        }


        return headers
    }


    /**
     Returns a bunch of HTTP Header to be used in any Bartleby Http call

     - returns: the headers
     */
    static public func baseHttpHeaders()->[String:String]{
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
    static public func apiIsReachable(baseURL: NSURL, successHandler:()->(), failureHandler:(context: JHTTPResponse)->()) {
        let pathURL=baseURL.URLByAppendingPathComponent("/Reachable")
        let urlRequest=HTTPManager.mutableRequestWithToken(inRegistryWithUID:"", withActionName:"Reachable", forMethod:"GET", and: pathURL)
        let r: Request=request(urlRequest)
        r.responseString { response in

            let request=response.request
            let result=response.result
            let response=response.response

            // Bartleby consignation

            let context = JHTTPResponse( code: 1,
                caller: "Reachable",
                relatedURL:request?.URL,
                httpStatusCode: response?.statusCode ?? 0,
                response: response )

            // React according to the situation
            var reactions = Array<Bartleby.Reaction> ()
            reactions.append(Bartleby.Reaction.Track(result: nil, context: context)) // Tracking

            let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
                context: context,
                title: NSLocalizedString("Server is not reachable",
                    comment: "Server is not reachable"),
                body: NSLocalizedString("Please Check your connection or your configuration!",
                    comment: "Please Check your connection or your configuration!"),
                transmit: { (selectedIndex) -> () in
                    bprint("Post presentation message selectedIndex:\(selectedIndex)", file: #file, function: #function, line: #line)
            })

            if result.isFailure {
                reactions.append(failureReaction)
                failureHandler(context:context)
            } else {
                if let statusCode=response?.statusCode {
                    if 200...299 ~= statusCode {
                        successHandler()
                    } else {
                        reactions.append(failureReaction)
                        if let value=result.value {
                            bprint(value, file: #file, function: #function, line: #line)
                        }
                        failureHandler(context:context)
                    }
                }
            }
            //Let's react according to the context.
            Bartleby.sharedInstance.perform(reactions, forContext: context)

        }
    }

    /**
     Use this method to test if the current user is authorized

     - parameter baseURL:        the base URL
     - parameter registryUID:     the cibled registry UID
     - parameter successHandler: called on success
     - parameter failureHandler: called on failure
     */
    static public func verifyCredentials(registryUID: String, baseURL: NSURL, successHandler:()->(), failureHandler:(context: JHTTPResponse)->()) {
        let pathURL=baseURL.URLByAppendingPathComponent("/verify/credentials")
        let urlRequest=HTTPManager.mutableRequestWithToken(inRegistryWithUID:registryUID, withActionName:"Reachable", forMethod:"GET", and: pathURL)
        let r: Request=request(urlRequest)
        r.responseString { response in

            let request=response.request
            let result=response.result
            let response=response.response

            // Bartleby consignation

            let context = JHTTPResponse( code: 1,
                caller: "verifyCredentials",
                relatedURL:request?.URL,
                httpStatusCode: response?.statusCode ?? 0,
                response: response )

            // React according to the situation
            var reactions = Array<Bartleby.Reaction> ()
            reactions.append(Bartleby.Reaction.Track(result: nil, context: context)) // Tracking

            let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
                context: context,
                title: NSLocalizedString("Forbidden",
                    comment: "Forbidden"),
                body: NSLocalizedString("Credentials are not valid",
                    comment: "Credentials are not valid"),
                transmit: { (selectedIndex) -> () in
                    bprint("Post presentation message selectedIndex:\(selectedIndex)", file: #file, function: #function, line: #line)
            })

            if result.isFailure {
                reactions.append(failureReaction)
                failureHandler(context:context)
            } else {
                if let statusCode=response?.statusCode {
                    if 200...299 ~= statusCode {
                        successHandler()
                    } else {
                        reactions.append(failureReaction)
                        if let value=result.value {
                            bprint(value, file: #file, function: #function, line: #line)
                        }
                        failureHandler(context:context)
                    }
                }
            }
            //Let's react according to the context.
            Bartleby.sharedInstance.perform(reactions, forContext: context)
        }
    }


    /**
     A Simple validation routine

     - parameter testStr: the string to be evaluated

     - returns: true if it is a valid email.
     */
    static public func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }


    /**
    Salts a string to guarante that the app "knows" the shared salt

     - parameter string: the string

     - returns: the salted value
     */
    static public func salt(string: String) -> String {
        return CryptoHelper.hash(string.stringByAppendingString(Bartleby.configuration.SHARED_SALT))
    }

}
