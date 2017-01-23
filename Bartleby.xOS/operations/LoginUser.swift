//
//  LoginUser.swift
//  Bartleby
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import Alamofire
    import ObjectMapper
#endif


open class LoginUser {
    
    static open func execute(  _ user: User,
                               sucessHandler success:@escaping ()->(),
                               failureHandler failure:@escaping (_ context: HTTPContext)->()) {

        if let document=user.referentDocument{

            let baseURL=document.baseURL
            let pathURL=baseURL.appendingPathComponent("user/login")

            // A valid document is required for any authentication.
            // So you must create a Document and use its spaceUID before to login.
            let dictionary: Dictionary<String, AnyObject>?=["userUID":user.UID as AnyObject,"password":user.cryptoPassword as AnyObject, "identification":document.metadata.identificationMethod.rawValue as AnyObject]
            let urlRequest=HTTPManager.requestWithToken(inDocumentWithUID:document.UID, withActionName:"LoginUser", forMethod:"POST", and: pathURL)
            do {
                let r=try JSONEncoding().encode(urlRequest,with:dictionary)

                request(r).validate().responseJSON(completionHandler: { (response) in

                    let request=response.request
                    let result=response.result
                    let timeline=response.timeline
                    let statusCode=response.response?.statusCode ?? 0

                    let metrics=Metrics()
                    metrics.operationName="LoginUser"
                    metrics.latency=timeline.latency
                    metrics.requestDuration=timeline.requestDuration
                    metrics.serializationDuration=timeline.serializationDuration
                    metrics.totalDuration=timeline.totalDuration
                    let context = HTTPContext( code: 100,
                                               caller: "LoginUser.execute",
                                               relatedURL:request?.url,
                                               httpStatusCode:statusCode)
                    if let request=request{
                        context.request=HTTPRequest(urlRequest: request)
                    }

                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        context.responseString=utf8Text
                        if Bartleby.configuration.DEVELOPER_MODE{
                             print("Login \(user.UID) \n\(user.email) \n\(request?.url) \npassword:\(user.password) \ncryptoPassword:\(user.cryptoPassword) \nResult: \(utf8Text)")
                        }
                    }
                    metrics.httpContext=context
                    document.report(metrics)

                    // React according to the situation
                    var reactions = Array<Reaction> ()
                    reactions.append(Reaction.track(result: nil, context: context)) // Tracking

                    if result.isFailure {
                        if user.UID == document.currentUser.UID{
                            document.currentUser.loginHasSucceed=false
                        }
                        let m = NSLocalizedString("authentication login",
                                                  comment: "authentication login failure description")
                        let failureReaction =  Reaction.dispatchAdaptiveMessage(
                            context: context,
                            title: NSLocalizedString("Unsuccessfull attempt result.isFailure is true",
                                                     comment: "Unsuccessfull attempt"),
                            body:"\(m) httpStatus code = \(statusCode)" ,
                            transmit: { (selectedIndex) -> () in
                        })
                        reactions.append(failureReaction)
                        failure(context)
                    } else {
                        if 200...299 ~= statusCode {
                            if user.UID == document.currentUser.UID{
                                document.currentUser.loginHasSucceed=true
                            }
                            if document.metadata.identificationMethod == .key{
                                if let kvids = result.value as? [String]{
                                    if kvids.count>=2{
                                        document.metadata.identificationValue=kvids[1]
                                        document.log("Login kvids \(kvids[0]):\(kvids[1]) ", file: #file, function: #function, line: #line, category: "Credentials", decorative: false)
                                    }
                                }
                            }
                            success()
                        } else {
                            // Bartlby does not currenlty discriminate status codes 100 & 101
                            // and treats any status code >= 300 the same way
                            // because we consider that failures differentiations could be done by the caller.
                            let m = NSLocalizedString("authentication login",
                                                      comment: "authentication login failure description")
                            let failureReaction =  Reaction.dispatchAdaptiveMessage(
                                context: context,
                                title: NSLocalizedString("Unsuccessfull attempt",
                                                         comment: "Unsuccessfull attempt"),
                                body:"\(m) httpStatus code = \(statusCode)" ,
                                transmit: { (selectedIndex) -> () in
                            })
                            reactions.append(failureReaction)
                            failure(context)
                        }

                    }
                    //Let's react according to the context.
                    document.perform(reactions, forContext: context)
                })
            }catch{
                let context = HTTPContext( code:2 ,
                                           caller: "LoginUser.execute",
                                           relatedURL:nil,
                                           httpStatusCode:500)
                context.responseString = "{\"message\":\"\(error)}"
                failure(context)
            }
        }else{
            // We don't want anymore detached logins.
            // A valid local document is required to proceed to login.

            let context = HTTPContext( code: 1,
                                       caller: "LoginUser.execute",
                                       relatedURL:nil,
                                       httpStatusCode:417)
            context.responseString = "{\"message\":\"Attempt to login without having created a document that holds the dataspace\"}"
            failure(context)
        }
        
    }
    
}
