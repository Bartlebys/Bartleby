//  Bartleby
//


import Foundation
#if !USE_EMBEDDED_MODULES
    import Alamofire
    import ObjectMapper
#endif

open class LogoutUser: JObject {

    // Universal type support
    override open class func typeName() -> String {
        return "LogoutUser"
    }

    static open func execute( _ user: User,
                              sucessHandler success:@escaping ()->(),
                              failureHandler failure:@escaping (_ context: JHTTPResponse)->()) {

        if let registry=user.document{
            let baseURL=Bartleby.sharedInstance.getCollaborationURL(registry.UID)
            let pathURL=baseURL.appendingPathComponent("user/logout")

            if registry.registryMetadata.identificationMethod == .key{
                // Delete the key
                registry.registryMetadata.identificationValue=nil
                registry.hasChanged()
                success()
            }else{
                let dictionary: Dictionary<String, Any>=[:]
                let urlRequest=HTTPManager.mutableRequestWithToken(inRegistryWithUID:registry.UID, withActionName:"LogoutUser", forMethod:"POST", and: pathURL)
                do {
                    let r=try JSONEncoding().encode(urlRequest,with:dictionary)
                    request(resource:r).validate().responseJSON(completionHandler: { (response) in

                        let request=response.request
                        let result=response.result
                        let response=response.response

                        // Bartleby consignation

                        let context = JHTTPResponse( code: 100,
                                                     caller: "LogoutUser.execute",
                                                     relatedURL:request?.url,
                                                     httpStatusCode: response?.statusCode ?? 0,
                                                     response: response,
                                                     result:result.value)

                        // React according to the situation
                        var reactions = Array<Bartleby.Reaction> ()
                        reactions.append(Bartleby.Reaction.track(result: nil, context: context)) // Tracking

                        if result.isFailure {
                            let failureReaction =  Bartleby.Reaction.dispatchAdaptiveMessage(
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

                            if let statusCode=response?.statusCode {
                                if 200...299 ~= statusCode {
                                    if user.UID == registry.currentUser.UID{
                                        registry.currentUser.loginHasSucceed=false
                                    }
                                    success()
                                } else {
                                    // Bartlby does not currenlty discriminate status codes 100 & 101
                                    // and treats any status code >= 300 the same way
                                    // because we consider that failures differentiations could be done by the caller.
                                    let failureReaction =  Bartleby.Reaction.dispatchAdaptiveMessage(
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
                        }
                        //Let's react according to the context.
                        Bartleby.sharedInstance.perform(reactions, forContext: context)
                    })

                }catch{
                    let context = JHTTPResponse( code:2 ,
                                                 caller: "LogoutUser.execute",
                                                 relatedURL:nil,
                                                 httpStatusCode:500,
                                                 response:nil,
                                                 result:"{\"message\":\"\(error)}")
                    failure(context)
                }
            }

        }else{
            // We don't want anymore detached logins/logout
            // A valid local document is required to proceed to login.

            let context = JHTTPResponse( code: 1,
                                         caller: "LogoutUser.execute",
                                         relatedURL:nil,
                                         httpStatusCode:417,
                                         response:nil,
                                         result:"{\"message\":\"Attempt to logout without having created a document that holds the dataspace\"}")
            failure(context)
        }
    }
}
