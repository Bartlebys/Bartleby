//  Bartleby
//


import Foundation
#if !USE_EMBEDDED_MODULES
    import Alamofire
    import ObjectMapper
#endif

open class LogoutUser: BartlebyObject {

    // Universal type support
    override open class func typeName() -> String {
        return "LogoutUser"
    }

    static open func execute( _ user: User,
                              sucessHandler success:@escaping ()->(),
                              failureHandler failure:@escaping (_ context: HTTPContext)->()) {

        if let  document=user.document{
            let baseURL=document.baseURL
            let pathURL=baseURL.appendingPathComponent("user/logout")

            if  document.metadata.identificationMethod == .key{
                // Delete the key
                document.metadata.identificationValue=nil
                document.hasChanged()
                success()
            }else{
                let dictionary: Dictionary<String, Any>=[:]
                let urlRequest=HTTPManager.requestWithToken(inDocumentWithUID: document.UID, withActionName:"LogoutUser", forMethod:"POST", and: pathURL)
                do {
                    let r=try JSONEncoding().encode(urlRequest,with:dictionary)
                    request(r).validate().responseJSON(completionHandler: { (response) in

                        let request=response.request
                        let result=response.result
                        let timeline=response.timeline
                        let statusCode=response.response?.statusCode ?? 0

                        let metrics=Metrics()
                        metrics.operationName="LogoutUser"
                        metrics.latency=timeline.latency
                        metrics.requestDuration=timeline.requestDuration
                        metrics.serializationDuration=timeline.serializationDuration
                        metrics.totalDuration=timeline.totalDuration
                        document.report(metrics)

                        let context = HTTPContext( code: 100,
                                                   caller: "LogoutUser.execute",
                                                   relatedURL:request?.url,
                                                   httpStatusCode: statusCode)

                        if let request=request{
                            context.request=HTTPRequest(urlRequest: request)
                        }

                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                            context.responseString=utf8Text
                        }

                        // React according to the situation
                        var reactions = Array<Reaction> ()
                        reactions.append(Reaction.track(result: nil, context: context)) // Tracking

                        if result.isFailure {
                            let failureReaction =  Reaction.dispatchAdaptiveMessage(
                                context: context,
                                title: NSLocalizedString("Unsuccessfull attempt",
                                                         comment: "Unsuccessfull attempt"),
                                body: NSLocalizedString("authentication logout",
                                                        comment: "authentication logout failure description")+" | \(result.value)",
                                transmit: { (selectedIndex) -> () in
                            })
                            reactions.append(failureReaction)
                            failure(context)
                        } else {

                            if 200...299 ~= statusCode {
                                if user.UID ==  document.currentUser.UID{
                                    document.currentUser.loginHasSucceed=false
                                }
                                success()
                            } else {
                                // Bartlby does not currenlty discriminate status codes 100 & 101
                                // and treats any status code >= 300 the same way
                                // because we consider that failures differentiations could be done by the caller.
                                let failureReaction =  Reaction.dispatchAdaptiveMessage(
                                    context: context,
                                    title: NSLocalizedString("Unsuccessfull attempt",
                                                             comment: "Unsuccessfull attempt"),
                                    body: NSLocalizedString("termination of session",
                                                            comment: "termination of session failure description | \(result.value)"),
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
                                               caller: "LogoutUser.execute",
                                               relatedURL:nil,
                                               httpStatusCode:500)
                    context.responseString = "{\"message\":\"\(error)}"
                    failure(context)
                }
            }

        }else{
            // We don't want anymore detached logins/logout
            // A valid local document is required to proceed to login.

            let context = HTTPContext( code: 1,
                                       caller: "LogoutUser.execute",
                                       relatedURL:nil,
                                       httpStatusCode:417)
            context.responseString = "{\"message\":\"Attempt to logout without having created a document that holds the dataspace\"}"
            failure(context)
        }
    }
}
