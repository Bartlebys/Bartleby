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

open class TriggersAfterIndex {



    open static func execute( from documentUID: String,
                              index: Int,
                              sucessHandler success:@escaping (_ triggers: [Trigger])->(),
                              failureHandler failure:@escaping (_ context: HTTPContext)->()) {

        if let document=Bartleby.sharedInstance.getDocumentByUID(documentUID){

            let pathURL=document.baseURL.appendingPathComponent("triggers/after/\(index)")
            let urlRequest=HTTPManager.requestWithToken(inDocumentWithUID:document.UID, withActionName:"TriggersAfterIndex", forMethod:"GET", and: pathURL)
            let r=urlRequest
            request(r).validate().responseString(completionHandler: { (response) in

                let request=response.request
                let result=response.result
                let timeline=response.timeline
                let statusCode=response.response?.statusCode ?? 0

                let metrics=Metrics()
                metrics.operationName="TriggersAfterIndex"
                metrics.latency=timeline.latency
                metrics.requestDuration=timeline.requestDuration
                metrics.serializationDuration=timeline.serializationDuration
                metrics.totalDuration=timeline.totalDuration
                let context = HTTPContext( code: 3054667497,
                                           caller: "TriggersAfterIndex.execute",
                                           relatedURL:request?.url,
                                           httpStatusCode: statusCode)

                if let request=request{
                    context.request=HTTPRequest(urlRequest: request)
                }

                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    context.responseString=utf8Text
                }
                metrics.httpContext=context
                document.report(metrics)

                // React according to the situation
                var reactions = Array<Reaction> ()
                reactions.append(Reaction.track(result: result.value, context: context)) // Tracking
                if result.isFailure {
                    /*
                     let failureReaction =  Reaction.dispatchAdaptiveMessage(
                     context: context,
                     title: NSLocalizedString("Unsuccessfull attempt", comment: "Unsuccessfull attempt"),
                     body:"\(result.value)\n\(#file)\n\(#function)\nhttp Status code: (\(statusCode)",
                     transmit: { (selectedIndex) -> () in
                     })
                     reactions.append(failureReaction)
                     */
                    failure(context)
                } else {
                    if 200...299 ~= statusCode {
                        if let string=result.value{
                            if let instance = Mapper <Trigger>().mapArray(JSONString:string){
                                success(instance)
                            }else{
                                let failureReaction =  Reaction.dispatchAdaptiveMessage(
                                    context: context,
                                    title: NSLocalizedString("Deserialization issue",
                                                             comment: "Deserialization issue"),
                                    body:"\(String(describing: result.value))\n\(#file)\n\(#function)\nhttp Status code: (\(statusCode))",
                                    transmit:{ (selectedIndex) -> () in
                                })
                                reactions.append(failureReaction)
                                failure(context)
                            }
                        }else{
                            let failureReaction =  Reaction.dispatchAdaptiveMessage(
                                context: context,
                                title: NSLocalizedString("No String Deserialization issue",
                                                         comment: "No String Deserialization issue"),
                                body: "\(String(describing: result.value))\n\(#file)\n\(#function)\nhttp Status code: (\(statusCode))",
                                transmit: { (selectedIndex) -> () in
                            })
                            reactions.append(failureReaction)
                            failure(context)
                        }
                    } else {
                        // Bartlby does not currenlty discriminate status codes 100 & 101
                        // and treats any status code >= 300 the same way
                        // because we consider that failures differentiations could be done by the caller.
                        let failureReaction =  Reaction.dispatchAdaptiveMessage(
                            context: context,
                            title: NSLocalizedString("Unsuccessfull attempt",comment: "Unsuccessfull attempt"),
                            body:"\(String(describing: result.value))\n\(#file)\n\(#function)\nhttp Status code: (\(statusCode))",
                            transmit:{ (selectedIndex) -> () in
                        })
                        reactions.append(failureReaction)
                        failure(context)
                    }

                }
                //Let s react according to the context.
                document.perform(reactions, forContext: context)
            })

        }else{

            let context = HTTPContext( code: 1,
                                       caller: "TriggersAfterIndex.execute",
                                       relatedURL:nil,
                                       httpStatusCode: 417)
            context.responseString = "{\"message\":\"Unexisting document with documentUID \(documentUID)\"}"
            failure(context)
        }
    }

}
