//
//  LoginUser.swift
//  Bartleby
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import Alamofire
    import ObjectMapper
#endif


public class LoginUser: JObject {

    // Universal type support
    override public class func typeName() -> String {
        return "LoginUser"
    }

    static public func execute(  user: User,
                                 withPassword password: String,
                                 sucessHandler success:()->(),
                                 failureHandler failure:(context: JHTTPResponse)->()) {

        let baseURL=Bartleby.sharedInstance.getCollaborationURLForSpaceUID(user.spaceUID)
        let pathURL=baseURL.URLByAppendingPathComponent("user/login")

        if let registry=Bartleby.sharedInstance.getRegistryByUID(user.spaceUID){
            
            // A valid registry is required for any authentication.
            // So you must create a Document and use its spaceUID before to login.

            let dictionary: Dictionary<String, AnyObject>?=["userUID":user.UID,"password":password, "identification":registry.registryMetadata.identificationMethod.rawValue]
            let urlRequest=HTTPManager.mutableRequestWithToken(inDataSpace:user.spaceUID, withActionName:"LoginUser", forMethod:"POST", and: pathURL)
            let r: Request=request(ParameterEncoding.JSON.encode(urlRequest, parameters: dictionary).0)
            r.responseJSON { response in

                let request=response.request
                let result=response.result
                let response=response.response

                // Bartleby consignation

                let context = JHTTPResponse( code: 100,
                    caller: "LoginUser.execute",
                    relatedURL:request?.URL,
                    httpStatusCode:response?.statusCode ?? 0,
                    response:response,
                    result:result.value)

                // React according to the situation
                var reactions = Array<Bartleby.Reaction> ()
                reactions.append(Bartleby.Reaction.Track(result: nil, context: context)) // Tracking

                if result.isFailure {
                    let m = NSLocalizedString("authentication login",
                        comment: "authentication login failure description")
                    let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
                        context: context,
                        title: NSLocalizedString("Unsuccessfull attempt result.isFailure is true",
                            comment: "Unsuccessfull attempt"),
                        body:"\(m) httpStatus code = \(response?.statusCode ?? 0 )" ,
                        transmit: { (selectedIndex) -> () in
                    })
                    reactions.append(failureReaction)
                    failure(context:context)
                } else {
                    if let statusCode=response?.statusCode {
                        if 200...299 ~= statusCode {
                                if registry.registryMetadata.identificationMethod == .Key{
                                    if let kvids = result.value as? [String]{
                                        if kvids.count>=2{
                                            registry.registryMetadata.identificationValue=kvids[1]
                                            bprint("Login kvids \(kvids[0]):\(kvids[1]) ", file: #file, function: #function, line: #line, category: "Credentials", decorative: false)
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
                            let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
                                context: context,
                                title: NSLocalizedString("Unsuccessfull attempt",
                                    comment: "Unsuccessfull attempt"),
                                body:"\(m) httpStatus code = \(statusCode)" ,
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
        }else{
                // We don't want anymore detached logins.
                // A valid local document is required to proceed to login.
            
                let context = JHTTPResponse( code: 1,
                                             caller: "LoginUser.execute",
                                             relatedURL:pathURL,
                                             httpStatusCode:417,
                                             response:nil,
                                             result:"{\"message\":\"Attempt to login without having created a document that holds the dataspace\"}")
                failure(context:context)
        }

    }

}
