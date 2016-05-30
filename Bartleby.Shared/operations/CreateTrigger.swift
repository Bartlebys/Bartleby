//
//  PushTrigger.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/05/2016.
//
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import Alamofire
    import ObjectMapper
#endif


@objc(PushTrigger) public class PushTrigger: JObject {

    // Universal type support
    override public class func typeName() -> String {
        return "PushTrigger"
    }


    static public func execute(  trigger: Trigger,
                                inDataSpace spaceUID: String,
                                sucessHandler success:(context: JHTTPResponse)->(),
                                failureHandler failure:(context: JHTTPResponse)->()) {
        let baseURL=Bartleby.sharedInstance.getCollaborationURLForSpaceUID(spaceUID)
        let pathURL=baseURL.URLByAppendingPathComponent("trigger")
        var parameters=Dictionary<String, AnyObject>()
        parameters["trigger"]=Mapper<Trigger>().toJSON(trigger)
        let urlRequest=HTTPManager.mutableRequestWithToken(inDataSpace:spaceUID, withActionName:"CreateTrigger", forMethod:"POST", and: pathURL)
        let r: Request=request(ParameterEncoding.JSON.encode(urlRequest, parameters: parameters).0)
        r.responseString { response in

            // Store the response
            let request=response.request
            let result=response.result
            let response=response.response

            // Bartleby consignation
            let context = JHTTPResponse( code: 100879527,
                caller: "CreateTrigger.execute",
                relatedURL:request?.URL,
                httpStatusCode: response?.statusCode ?? 0,
                response: response,
                result:result.value)

            // React according to the situation
            var reactions = Array<Bartleby.Reaction> ()
            reactions.append(Bartleby.Reaction.Track(result: result.value, context: context)) // Tracking

            if result.isFailure {
                let m = NSLocalizedString("creation  of trigger",
                    comment: "creation of trigger failure description")
                let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
                    context: context,
                    title: NSLocalizedString("Unsuccessfull attempt result.isFailure is true",
                        comment: "Unsuccessfull attempt"),
                    body:"\(m) \n \(response)" ,
                    trigger: { (selectedIndex) -> () in
                })
                reactions.append(failureReaction)
                failure(context:context)
            } else {
                if let statusCode=response?.statusCode {
                    if 200...299 ~= statusCode {
                        success(context:context)
                    } else {
                        // Bartlby does not currenlty discriminate status codes 100 & 101
                        // and treats any status code >= 300 the same way
                        // because we consider that failures differentiations could be done by the caller.

                        let m=NSLocalizedString("creation of trigger",
                            comment: "creation of trigger failure description")
                        let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
                            context: context,
                            title: NSLocalizedString("Unsuccessfull attempt",
                                comment: "Unsuccessfull attempt"),
                            body: "\(m) \n \(response)",
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
