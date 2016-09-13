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

@objc(TriggersForIndexes) open class TriggersForIndexes: JObject {

    // Universal type support
    override open class func typeName() -> String {
        return "TriggersForIndexes"
    }


    open static func execute(  fromRegistryWithUID registryUID: String,
                               indexes: [Int],
                               ignoreHoles:Bool,
                               sucessHandler success:@escaping (_ triggers: [Trigger])->(),
                               failureHandler failure:@escaping (_ context: JHTTPResponse)->()) {

        if let document=Bartleby.sharedInstance.getDocumentByUID(registryUID){


            let pathURL=document.baseURL.appendingPathComponent("triggers")
            let dictionary:[String:AnyObject]=["indexes":indexes as AnyObject,"ignoreHoles": ignoreHoles as AnyObject]
            let urlRequest=HTTPManager.requestWithToken(inRegistryWithUID:document.UID, withActionName:"ReadTriggersByIds", forMethod:"GET", and: pathURL)
            do {
                let r=try URLEncoding().encode(urlRequest,with:dictionary) 
                request(r).validate().responseJSON(completionHandler: { (response) in
                    let request=response.request
                    let result=response.result
                    let response=response.response
                    // Bartleby consignation
                    let context = JHTTPResponse( code: 3054667497,
                                                 caller: "TriggersForIndexes.execute",
                                                 relatedURL:request?.url,
                                                 httpStatusCode: response?.statusCode ?? 0,
                                                 response: response,
                                                 result:result.value)
                    // React according to the situation
                    var reactions = Array<Bartleby.Reaction> ()
                    reactions.append(Bartleby.Reaction.track(result: result.value, context: context)) // Tracking
                    if result.isFailure {
                        let failureReaction =  Bartleby.Reaction.dispatchAdaptiveMessage(
                            context: context,
                            title: NSLocalizedString("Unsuccessfull attempt", comment: "Unsuccessfull attempt"),
                            body:NSLocalizedString("Explicit Failure", comment: "Explicit Failure"),
                            transmit: { (selectedIndex) -> () in
                        })
                        reactions.append(failureReaction)
                        failure(context)
                    } else {
                        if let statusCode=response?.statusCode {
                            if 200...299 ~= statusCode {
                                if let instance = Mapper <Trigger>().mapArray(result.value) {
                                    success(instance)
                                } else {
                                    let failureReaction =  Bartleby.Reaction.dispatchAdaptiveMessage(
                                        context: context,
                                        title: NSLocalizedString("Deserialization issue",
                                                                 comment: "Deserialization issue"),
                                        body:"(result.value)",
                                        transmit: { (selectedIndex) -> () in
                                    })
                                    reactions.append(failureReaction)
                                    failure(context)
                                }
                            } else {
                                // Bartlby does not currenlty discriminate status codes 100 & 101
                                // and treats any status code >= 300 the same way
                                // because we consider that failures differentiations could be done by the caller.
                                let failureReaction =  Bartleby.Reaction.dispatchAdaptiveMessage(
                                    context: context,
                                    title: NSLocalizedString("Unsuccessfull attempt", comment: "Unsuccessfull attempt"),
                                    body:NSLocalizedString("Implicit Failure", comment: "Implicit Failure"),
                                    transmit: { (selectedIndex) -> () in
                                })
                                reactions.append(failureReaction)
                                failure(context)
                            }
                        }
                    }
                    //Let s react according to the context.
                    Bartleby.sharedInstance.perform(reactions, forContext: context)
                })
            }catch{
                let context = JHTTPResponse( code:2 ,
                                             caller: "TriggersForIndexes.execute",
                                             relatedURL:nil,
                                             httpStatusCode:500,
                                             response:nil,
                                             result:"{\"message\":\"\(error)}")
                failure(context)
            }
        }else{

            let context = JHTTPResponse( code: 1,
                                         caller: "TriggersForIndexes.execute",
                                         relatedURL:nil,
                                         httpStatusCode: 417,
                                         response: nil,
                                         result:"{\"message\":\"Unexisting document with registryUID \(registryUID)\"}")
            failure(context)
        }
    }
    
}
