//
//  TriggersAfterIndex.swift
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

@objc(TriggersAfterIndex) open class TriggersAfterIndex: JObject {

    // Universal type support
    override open class func typeName() -> String {
        return "TriggersAfterIndex"
    }


    open static func execute( fromRegistryWithUID registryUID: String,
                              index: Int,
                              sucessHandler success:@escaping (_ triggers: [Trigger])->(),
                              failureHandler failure:@escaping (_ context: JHTTPResponse)->()) {

        if let document=Bartleby.sharedInstance.getDocumentByUID(registryUID){

            let pathURL=document.baseURL.appendingPathComponent("triggers")
            let dictionary=["index":index]
            let urlRequest=HTTPManager.requestWithToken(inRegistryWithUID:document.UID, withActionName:"ReadTriggersByIds", forMethod:"GET", and: pathURL)
            do {
                let r=try URLEncoding().encode(urlRequest,with:dictionary) 
                request(r).validate().responseString(completionHandler: { (response) in

                    let request=response.request
                    let result=response.result
                    let response=response.response
                    // Bartleby consignation
                    let context = JHTTPResponse( code: 3054667497,
                                                 caller: "TriggersAfterIndex.execute",
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
                                if let string=result.value{
                                    if let instance = Mapper <Trigger>().mapArray(JSONString:string){
                                        success(instance)
                                    }else{
                                        let failureReaction =  Bartleby.Reaction.dispatchAdaptiveMessage(
                                            context: context,
                                            title: NSLocalizedString("Deserialization issue",
                                                                     comment: "Deserialization issue"),
                                            body:"(result.value)",
                                            transmit:{ (selectedIndex) -> () in
                                        })
                                        reactions.append(failureReaction)
                                        failure(context)
                                    }
                                }else{
                                    let failureReaction =  Bartleby.Reaction.dispatchAdaptiveMessage(
                                        context: context,
                                        title: NSLocalizedString("No String Deserialization issue",
                                                                 comment: "No String Deserialization issue"),
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
                                             caller: "TriggersAfterIndex.execute",
                                             relatedURL:nil,
                                             httpStatusCode:500,
                                             response:nil,
                                             result:"{\"message\":\"\(error)}")
                failure(context)
            }
        }else{

            let context = JHTTPResponse( code: 1,
                                         caller: "TriggersAfterIndex.execute",
                                         relatedURL:nil,
                                         httpStatusCode: 417,
                                         response: nil,
                                         result:"{\"message\":\"Unexisting document with registryUID \(registryUID)\"}")
            failure(context)
        }
    }
    
}
