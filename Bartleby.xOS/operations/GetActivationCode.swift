//
//  GetActivationCode.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 13/01/2017.
//
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import Alamofire
#endif


open class GetActivationCode {




    /// Used to obtain the Code from a Locker (the user must be authenticated before to call this operation)
    ///
    /// - Parameters:
    ///   - baseURL: the server base URL
    ///   - documentUID: the document UID (we will extract the spaceUID for integrity control)
    ///   - lockerUID: the lockerUID
    ///   - title: the title
    ///   - body: the body message `$code` will be replaced by the code server side
    ///   - success: the success closure
    ///   - failure: the failure closure
    public static func execute(    baseURL:URL,
                                 documentUID:String,
                                 lockerUID:String,
                                 title:String,
                                 body:String,
                                 sucessHandler success: @escaping(_ context:HTTPContext)->(),
                                 failureHandler failure:@escaping (_ context: HTTPContext)->()) {

        /// This operation is special

        let pathURL=baseURL.appendingPathComponent("activationCode")
        let dictionary: Dictionary<String, String>=[
            "lockerUID":lockerUID,
            "title":title,
            "body":body
        ]

        let urlRequest=HTTPManager.requestWithToken(inDocumentWithUID:documentUID, withActionName:"GetActivationCode", forMethod:"GET", and: pathURL)
        do {
            let r=try URLEncoding().encode(urlRequest,with:dictionary)
            request(r).validate().responseJSON(completionHandler: { (response) in

                // Store the response
                let request=response.request
                let result=response.result
                let timeline=response.timeline
                let statusCode=response.response?.statusCode ?? 0

                let metrics=Metrics()
                metrics.operationName="GetActivationCode"
                metrics.latency=timeline.latency
                metrics.requestDuration=timeline.requestDuration
                metrics.serializationDuration=timeline.serializationDuration
                metrics.totalDuration=timeline.totalDuration

                // Bartleby consignation
                let context = HTTPContext( code: 667,
                                           caller: "GetActivationCode.execute",
                                           relatedURL:request?.url,
                                           httpStatusCode: statusCode)

                if let request=request{
                    context.request=HTTPRequest(urlRequest: request)
                }

                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    context.responseString=utf8Text
                }
                metrics.httpContext=context


                // React according to the situation
                var reactions = Array<Reaction> ()

                if result.isFailure {
                    let m = NSLocalizedString("Activation failure",
                                              comment: "Activation failure description")
                    let failureReaction =  Reaction.dispatchAdaptiveMessage(
                        context: context,
                        title: NSLocalizedString("Unsuccessfull attempt result.isFailure is true",
                                                 comment: "Unsuccessfull attempt"),
                        body:"\(m) \n \(response)" + "\n\(#file)\n\(#function)\nhttp Status code: (\(statusCode))",
                        transmit:{ (selectedIndex) -> () in
                    })
                    reactions.append(failureReaction)
                    failure(context)
                }else{
                    if 200...299 ~= statusCode {
                        success(context)
                    }else{
                        // Bartlby does not currenlty discriminate status codes 100 & 101
                        // and treats any status code >= 300 the same way
                        // because we consider that failures differentiations could be done by the caller.

                        let m=NSLocalizedString("Activation failure",
                                                comment: "Activation failure description")
                        let failureReaction =  Reaction.dispatchAdaptiveMessage(
                            context: context,
                            title: NSLocalizedString("Unsuccessfull attempt",
                                                     comment: "Unsuccessfull attempt"),
                            body: "\(m) \n \(response)" + "\n\(#file)\n\(#function)\nhttp Status code: (\(statusCode))",
                            transmit:{ (selectedIndex) -> () in
                        })
                        reactions.append(failureReaction)
                        failure(context)
                    }
                }
                if let document=Bartleby.sharedInstance.getDocumentByUID(documentUID){
                    // report the metrics
                    document.report(metrics)
                    //Let's react according to the context.
                    document.perform(reactions, forContext: context)
                }else{
                    // Not normal
                    if let url=request?.url{
                        Bartleby.sharedInstance.report(metrics,forURL:url)
                    }
                }

            })
        }catch{
            let context = HTTPContext( code:2 ,
                                       caller: "GetActivationCode.execute",
                                       relatedURL:nil,
                                       httpStatusCode:500)
            context.responseString = "{\"message\":\"\(error)}"
            failure(context)
        }
        
    }
    
}
