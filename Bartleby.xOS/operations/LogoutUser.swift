//  Bartleby
//


import Foundation
#if !USE_EMBEDDED_MODULES
    import Alamofire
    import ObjectMapper
#endif

public class LogoutUser: JObject {

    // Universal type support
    override public class func typeName() -> String {
        return "LogoutUser"
    }

    static public func execute( user: User,
                                sucessHandler success:()->(),
                                failureHandler failure:(context: JHTTPResponse)->()) {

                    if let registry=user.document{

                        let baseURL=Bartleby.sharedInstance.getCollaborationURL(registry.UID)
                        let pathURL=baseURL.URLByAppendingPathComponent("user/logout")

                        if registry.registryMetadata.identificationMethod == .Key{
                            // Delete the key
                            registry.registryMetadata.identificationValue=nil
                            registry.hasChanged()
                            success()
                        }else{
                            let dictionary: Dictionary<String, AnyObject>=[:]
                            let urlRequest=HTTPManager.mutableRequestWithToken(inRegistry:registry.UID, withActionName:"LogoutUser", forMethod:"POST", and: pathURL)
                            let r: Request=request(ParameterEncoding.JSON.encode(urlRequest, parameters: dictionary).0)
                            r.responseString { response in
                                let request=response.request
                                let result=response.result
                                let response=response.response

                                // Bartleby consignation

                                let context = JHTTPResponse( code: 100,
                                    caller: "LogoutUser.execute",
                                    relatedURL:request?.URL,
                                    httpStatusCode: response?.statusCode ?? 0,
                                    response: response,
                                    result:result.value)

                                // React according to the situation
                                var reactions = Array<Bartleby.Reaction> ()
                                reactions.append(Bartleby.Reaction.Track(result: nil, context: context)) // Tracking

                                if result.isFailure {
                                    let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
                                        context: context,
                                        title: NSLocalizedString("Unsuccessfull attempt",
                                            comment: "Unsuccessfull attempt"),
                                        body: NSLocalizedString("authentication logout",
                                            comment: "authentication logout failure description")+" | \(result.value)",
                                        transmit: { (selectedIndex) -> () in
                                    })
                                    reactions.append(failureReaction)
                                    failure(context:context)
                                } else {
                                    if let statusCode=response?.statusCode {
                                        if 200...299 ~= statusCode {
                                            success()
                                        } else {
                                            // Bartlby does not currenlty discriminate status codes 100 & 101
                                            // and treats any status code >= 300 the same way
                                            // because we consider that failures differentiations could be done by the caller.
                                            let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
                                                context: context,
                                                title: NSLocalizedString("Unsuccessfull attempt",
                                                    comment: "Unsuccessfull attempt"),
                                                body: NSLocalizedString("termination of session",
                                                    comment: "termination of session failure description | \(result.value)"),
                                                transmit: { (selectedIndex) -> () in
                                            })
                                            reactions.append(failureReaction)
                                            failure(context:context)
                                        }
                                    }
                                }
                                //Let's react according to the context.
                                Bartleby.sharedInstance.perform(reactions, forContext: context)
                            }

                        }


                    }else{
                        // We don't want anymore detached logins/logout
                        // A valid local document is required to proceed to login.

                        let context = JHTTPResponse( code: 1,
                                                     caller: "LogoutUser.execute",
                                                     relatedURL:NSURL(),
                                                     httpStatusCode:417,
                                                     response:nil,
                                                     result:"{\"message\":\"Attempt to logout without having created a document that holds the dataspace\"}")
                        failure(context:context)
        }
    }
}
