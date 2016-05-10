//
//  LoginUser.swift
//  Bartleby
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import Alamofire
    import ObjectMapper
#endif


@objc(LoginUser) public class LoginUser: JObject {

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
        let dictionary: Dictionary<String, AnyObject>?=["userUID":user.UID, "password":password]
        let urlRequest=HTTPManager.mutableRequestWithToken(inDataSpace:user.spaceUID, withActionName:"LoginUser", forMethod:"POST", and: pathURL)
        let r: Request=request(ParameterEncoding.JSON.encode(urlRequest, parameters: dictionary).0)
        r.responseString { response in

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
                    trigger: { (selectedIndex) -> () in
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
                        let m = NSLocalizedString("authentication login",
                            comment: "authentication login failure description")
                        let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
                            context: context,
                            title: NSLocalizedString("Unsuccessfull attempt",
                                comment: "Unsuccessfull attempt"),
                            body:"\(m) httpStatus code = \(statusCode)" ,
                            trigger: { (selectedIndex) -> () in
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

}
