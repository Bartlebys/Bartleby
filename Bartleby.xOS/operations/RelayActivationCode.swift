//
//  RelayActivationCode.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 02/01/2017.
//
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import Alamofire
    import ObjectMapper
#endif


open class RelayActivationCode {


    /// Relays the activation code (ove SSL)
    ///
    /// - Parameters:
    ///   - baseURL: the server base URL
    ///   - documentUID: the document UID (we will extract the spaceUID for integrity control)
    ///   - fromEmail: the emitter email *
    ///   - fromPhoneNumber: the emitter phone number *
    ///   - toEmail: the recipient email *
    ///   - toPhoneNumber: the recipient phone number
    ///   - code: the code
    ///   - title: the title
    ///   - body: the body `$code` will be replaced by the code server side
    ///   - success: the success closure
    ///   - failure: the failure closure
    static open func execute(   baseURL:URL,
                                documentUID:String,
                                fromEmail: String,
                                fromPhoneNumber:String,
                                toEmail:String,
                                toPhoneNumber:String,
                                code:String,
                                title:String,
                                body:String,
        sucessHandler success: @escaping(_ context:HTTPContext)->(),
        failureHandler failure:@escaping (_ context: HTTPContext)->()) {

        /// This operation is special
        /// It may occur on a document that is not available locally
        /// Check IdentityManager for details

        let pathURL=baseURL.appendingPathComponent("relay")
        let dictionary: Dictionary<String, String>=[
            "fromEmail":fromEmail,
            "fromPhoneNumber":fromPhoneNumber,
            "toEmail":toEmail,
            "toPhoneNumber":toPhoneNumber,
            "code":code,
            "title":title,
            "body":body
        ]

        let urlRequest=HTTPManager.requestWithToken(inDocumentWithUID:documentUID, withActionName:"RelayActivationCode", forMethod:"POST", and: pathURL)
        do {
            let r=try JSONEncoding().encode(urlRequest,with:dictionary)
            request(r).validate().responseJSON(completionHandler: { (response) in

                // Store the response
                let request=response.request
                let result=response.result
                let timeline=response.timeline
                let statusCode=response.response?.statusCode ?? 0

                // Bartleby consignation
                let context = HTTPContext( code: 667,
                                           caller: "RelayActivationCode.execute",
                                           relatedURL:request?.url,
                                           httpStatusCode: statusCode)

                if let request=request{
                    context.request=HTTPRequest(urlRequest: request)
                }

                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    context.responseString=utf8Text
                }
                // React according to the situation
                var reactions = Array<Reaction> ()

                if result.isFailure {
                    let m = NSLocalizedString("Relay failure",
                                              comment: "Relay failure failure description")
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
                        // Acknowledge the trigger if there is one
                        if let dictionary = result.value as? Dictionary< String,AnyObject > {
                            if let index=dictionary["triggerIndex"] as? NSNumber,
                                let triggerRelayDuration=dictionary["triggerRelayDuration"] as? NSNumber{
                                let acknowledgment=Acknowledgment()
                                acknowledgment.httpContext=context
                                acknowledgment.operationName="RelayActivationCode"
                                acknowledgment.triggerIndex=index.intValue
                                acknowledgment.latency=timeline.latency
                                acknowledgment.requestDuration=timeline.requestDuration
                                acknowledgment.serializationDuration=timeline.serializationDuration
                                acknowledgment.totalDuration=timeline.totalDuration
                                acknowledgment.triggerRelayDuration=triggerRelayDuration.doubleValue
                                acknowledgment.uids=[]
                                if let document=Bartleby.sharedInstance.getDocumentByUID(documentUID){
                                    document.record(acknowledgment)
                                    document.report(acknowledgment) // Acknowlegments are also metrics
                                }
                            }
                        }
                        success(context)
                    }else{
                        // Bartlby does not currenlty discriminate status codes 100 & 101
                        // and treats any status code >= 300 the same way
                        // because we consider that failures differentiations could be done by the caller.

                        let m=NSLocalizedString("Relay failure",
                                                comment: "Relay failure description")
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
                    //Let's react according to the context.
                    document.perform(reactions, forContext: context)
                }


            })
        }catch{
            let context = HTTPContext( code:2 ,
                                       caller: "RelayActivationCode.execute",
                                       relatedURL:nil,
                                       httpStatusCode:500)
            context.responseString = "{\"message\":\"\(error)}"
            failure(context)
        }
        
    }
    
}
