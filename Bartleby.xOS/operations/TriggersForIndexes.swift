//
//  TriggersForIndexes.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/05/2016.
//
//


//class TriggersForIndexes: JObject


import Foundation
#if !USE_EMBEDDED_MODULES
    import Alamofire
    import ObjectMapper
#endif

@objc(TriggersForIndexes) public class TriggersForIndexes: JObject {

    // Universal type support
    override public class func typeName() -> String {
        return "TriggersForIndexes"
    }


    public static func execute(  fromRegistryWithUID registryUID: String,
                                indexes: [Int],
                                ignoreHoles:Bool,
                                sucessHandler success:(triggers: [Trigger])->(),
                                failureHandler failure:(context: JHTTPResponse)->()) {

        if let document=Bartleby.sharedInstance.getDocumentByUID(registryUID){


            let pathURL=document.baseURL.URLByAppendingPathComponent("triggers")
            let dictionary:[String:AnyObject]=["indexes":indexes,"ignoreHoles": ignoreHoles]
            let urlRequest=HTTPManager.mutableRequestWithToken(inRegistryWithUID:document.UID, withActionName:"ReadTriggersByIds", forMethod:"GET", and: pathURL)
            let r: Request=request(ParameterEncoding.URL.encode(urlRequest, parameters: dictionary).0)
            r.responseJSON { response in
                let request=response.request
                let result=response.result
                let response=response.response
                // Bartleby consignation
                let context = JHTTPResponse( code: 3054667497,
                    caller: "TriggersForIndexes.execute",
                    relatedURL:request?.URL,
                    httpStatusCode: response?.statusCode ?? 0,
                    response: response,
                    result:result.value)
                // React according to the situation
                var reactions = Array<Bartleby.Reaction> ()
                reactions.append(Bartleby.Reaction.Track(result: result.value, context: context)) // Tracking
                if result.isFailure {
                    let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
                        context: context,
                        title: NSLocalizedString("Unsuccessfull attempt", comment: "Unsuccessfull attempt"),
                        body:NSLocalizedString("Explicit Failure", comment: "Explicit Failure"),
                        transmit: { (selectedIndex) -> () in
                    })
                    reactions.append(failureReaction)
                    failure(context:context)
                } else {
                    if let statusCode=response?.statusCode {
                        if 200...299 ~= statusCode {
                            if let instance = Mapper <Trigger>().mapArray(result.value) {
                                success(triggers: instance)
                            } else {
                                let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
                                    context: context,
                                    title: NSLocalizedString("Deserialization issue",
                                        comment: "Deserialization issue"),
                                    body:"(result.value)",
                                    transmit: { (selectedIndex) -> () in
                                })
                                reactions.append(failureReaction)
                                failure(context:context)
                            }
                        } else {
                            // Bartlby does not currenlty discriminate status codes 100 & 101
                            // and treats any status code >= 300 the same way
                            // because we consider that failures differentiations could be done by the caller.
                            let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
                                context: context,
                                title: NSLocalizedString("Unsuccessfull attempt", comment: "Unsuccessfull attempt"),
                                body:NSLocalizedString("Implicit Failure", comment: "Implicit Failure"),
                                transmit: { (selectedIndex) -> () in
                            })
                            reactions.append(failureReaction)
                            failure(context:context)
                        }
                    }
                }
                //Let s react according to the context.
                Bartleby.sharedInstance.perform(reactions, forContext: context)
            }
        }else{

            let context = JHTTPResponse( code: 1,
                                         caller: "TriggersForIndexes.execute",
                                         relatedURL:NSURL(),
                                         httpStatusCode: 417,
                                         response: nil,
                                         result:"{\"message\":\"Unexisting document with registryUID \(registryUID)\"}")
            failure(context:context)
        }
    }
    
}
