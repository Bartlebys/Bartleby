//
//  LoginUser.swift
//  Bartleby
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import Alamofire
    import ObjectMapper
#endif


open class LoginUser: JObject {

    // Universal type support
    override open class func typeName() -> String {
        return "LoginUser"
    }

    static open func execute(  _ user: User,
                               withPassword password: String,
                               sucessHandler success:@escaping ()->(),
                               failureHandler failure:@escaping (_ context: JHTTPResponse)->()) {

        if let registry=user.document{

            let baseURL=Bartleby.sharedInstance.getCollaborationURL(registry.UID)
            let pathURL=baseURL.appendingPathComponent("user/login")

            // A valid registry is required for any authentication.
            // So you must create a Document and use its spaceUID before to login.
            let cryptoPassword:String = (try? Bartleby.cryptoDelegate.encryptString(password)) ?? password
            let dictionary: Dictionary<String, AnyObject>?=["userUID":user.UID as AnyObject,"password":cryptoPassword as AnyObject, "identification":registry.registryMetadata.identificationMethod.rawValue as AnyObject]
            let urlRequest=HTTPManager.requestWithToken(inRegistryWithUID:registry.UID, withActionName:"LoginUser", forMethod:"POST", and: pathURL)
            do {
                let r=try JSONEncoding().encode(urlRequest,with:dictionary) 
                request(resource:r).validate().responseJSON(completionHandler: { (response) in

                    let request=response.request
                    let result=response.result
                    let response=response.response

                    // Bartleby consignation


                    let context = JHTTPResponse( code: 100,
                                                 caller: "LoginUser.execute",
                                                 relatedURL:request?.url,
                                                 httpStatusCode:response?.statusCode ?? 0,
                                                 response:response,
                                                 result:result.value)

                    // React according to the situation
                    var reactions = Array<Bartleby.Reaction> ()
                    reactions.append(Bartleby.Reaction.track(result: nil, context: context)) // Tracking

                    if result.isFailure {
                        if user.UID == registry.currentUser.UID{
                            registry.currentUser.loginHasSucceed=false
                        }
                        let m = NSLocalizedString("authentication login",
                                                  comment: "authentication login failure description")
                        let failureReaction =  Bartleby.Reaction.dispatchAdaptiveMessage(
                            context: context,
                            title: NSLocalizedString("Unsuccessfull attempt result.isFailure is true",
                                                     comment: "Unsuccessfull attempt"),
                            body:"\(m) httpStatus code = \(response?.statusCode ?? 0 )" ,
                            transmit: { (selectedIndex) -> () in
                        })
                        reactions.append(failureReaction)
                        failure(context)
                    } else {
                        if let statusCode=response?.statusCode {
                            if 200...299 ~= statusCode {
                                if user.UID == registry.currentUser.UID{
                                    registry.currentUser.loginHasSucceed=true
                                }
                                if registry.registryMetadata.identificationMethod == .key{
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
                                let failureReaction =  Bartleby.Reaction.dispatchAdaptiveMessage(
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
                    }
                    //Let's react according to the context.
                    Bartleby.sharedInstance.perform(reactions, forContext: context)
                })
            }catch{
                let context = JHTTPResponse( code:2 ,
                                             caller: "LoginUser.execute",
                                             relatedURL:nil,
                                             httpStatusCode:500,
                                             response:nil,
                                             result:"{\"message\":\"\(error)}")
                failure(context)
            }
        }else{
            // We don't want anymore detached logins.
            // A valid local document is required to proceed to login.

            let context = JHTTPResponse( code: 1,
                                         caller: "LoginUser.execute",
                                         relatedURL:nil,
                                         httpStatusCode:417,
                                         response:nil,
                                         result:"{\"message\":\"Attempt to login without having created a document that holds the dataspace\"}")
            failure(context)
        }
        
    }

}
