//
//  TriggersByIds.swift
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

@objc(TriggersByIds) open class TriggersByIds: BartlebyObject {

    // Universal type support
    override open class func typeName() -> String {
        return "TriggersByIds"
    }


    open static func execute( fromRegisty documentUID: String,
                              ids: [String],
                              sucessHandler success:@escaping (_ triggers: [Trigger])->(),
                              failureHandler failure:@escaping (_ context: JHTTPResponse)->()) {

        if let document=Bartleby.sharedInstance.getDocumentByUID(documentUID){

            let pathURL=document.baseURL.appendingPathComponent("triggers")
            let dictionary=["ids":ids]
            let urlRequest=HTTPManager.requestWithToken(inDocumentWithUID:document.UID, withActionName:"TriggersByIds", forMethod:"GET", and: pathURL)
            do {
                let r=try URLEncoding().encode(urlRequest,with:dictionary)
                request(r).validate().responseString(completionHandler: { (response) in

                    let request=response.request
                    let result=response.result
                    let response=response.response
                    // Bartleby consignation
                    let context = JHTTPResponse( code: 3054667497,
                                                 caller: "TriggersByIds.execute",
                                                 relatedURL:request?.url,
                                                 httpStatusCode: response?.statusCode ?? 0,
                                                 response: response,
                                                 result:result.value)
                    // React according to the situation
                    var reactions = Array<Reaction> ()
                    reactions.append(Reaction.track(result: result.value, context: context)) // Tracking
                    if result.isFailure {
                        let failureReaction =  Reaction.dispatchAdaptiveMessage(
                            context: context,
                            title: NSLocalizedString("Unsuccessfull attempt", comment: "Unsuccessfull attempt"),
                            body:"\(result.value)\n\(#file)\n\(#function)\nhttp Status code: (\(response?.statusCode ?? 0))",
                            transmit: { (selectedIndex) -> () in
                        })
                        reactions.append(failureReaction)
                        failure(context)
                    } else {
                        if let statusCode=response?.statusCode {
                            if 200...299 ~= statusCode {
                                if let string=result.value{
                                    if let instance = Mapper <Trigger>().mapArray(JSONString:string) {
                                        success(instance)
                                    } else {
                                        let failureReaction =  Reaction.dispatchAdaptiveMessage(
                                            context: context,
                                            title: NSLocalizedString("Deserialization issue",
                                                                     comment: "Deserialization issue"),
                                            body:"\(result.value)\n\(#file)\n\(#function)\nhttp Status code: (\(response?.statusCode ?? 0))",
                                            transmit:{ (selectedIndex) -> () in
                                        })
                                        reactions.append(failureReaction)
                                        failure(context)                                    }
                                } else {
                                    let failureReaction =  Reaction.dispatchAdaptiveMessage(
                                        context: context,
                                        title: NSLocalizedString("No String Deserialization issue",
                                                                 comment: "No String Deserialization issue"),
                                        body: "\(result.value)\n\(#file)\n\(#function)\nhttp Status code: (\(response?.statusCode ?? 0))",
                                        transmit: { (selectedIndex) -> () in
                                    })
                                    reactions.append(failureReaction)
                                    failure(context)                                }

                            } else {
                                // Bartlby does not currenlty discriminate status codes 100 & 101
                                // and treats any status code >= 300 the same way
                                // because we consider that failures differentiations could be done by the caller.
                                let failureReaction =  Reaction.dispatchAdaptiveMessage(
                                    context: context,
                                    title: NSLocalizedString("Unsuccessfull attempt", comment: "Unsuccessfull attempt"),
                                    body:"\(result.value)\n\(#file)\n\(#function)\nhttp Status code: (\(response?.statusCode ?? 0))",
                                    transmit: { (selectedIndex) -> () in
                                })
                                reactions.append(failureReaction)
                                failure(context)
                            }
                        }
                    }
                    //Let s react according to the context.
                    document.perform(reactions, forContext: context)
                })
            }catch{
                let context = JHTTPResponse( code:2 ,
                                             caller: "TriggersByIds.execute",
                                             relatedURL:nil,
                                             httpStatusCode:500,
                                             response:nil,
                                             result:"{\"message\":\"\(error)}")
                failure(context)
            }
        }else{

            let context = JHTTPResponse( code: 1,
                                         caller: "TriggersByIds.execute",
                                         relatedURL:nil,
                                         httpStatusCode: 417,
                                         response: nil,
                                         result:"{\"message\":\"Unexisting document with documentUID \(documentUID)\"}")
            failure(context)
        }
    }
    
}
