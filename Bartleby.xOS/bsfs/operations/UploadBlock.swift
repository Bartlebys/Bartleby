//
//  UploadBlock.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/05/2016.
//
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import Alamofire
#endif

@objc(UploadBlock) public class UploadBlock: BlockOperationBase {

    // Universal type support
    override open class func typeName() -> String {
        return "UploadBlock"
    }

    open override class func execute(_ block:Block,
                            inDocumentWithUID documentUID:String,
                            sucessHandler success: @escaping(_ context:HTTPContext)->(),
                            failureHandler failure: @escaping(_ context:HTTPContext)->()){

        if let document = Bartleby.sharedInstance.getDocumentByUID(documentUID) {
            let pathURL = document.baseURL.appendingPathComponent("block")
            var parameters=Dictionary<String, Any>()
            parameters["id"]=block.UID
            parameters["relativePath"]=block.blockRelativePath()
            let urlRequest=HTTPManager.requestWithToken(inDocumentWithUID:document.UID,withActionName:"UpdateBlock" ,forMethod:"PUT", and: pathURL)
            do {
                let r=try JSONEncoding().encode(urlRequest,with:parameters)
                request(r).validate().responseJSON(completionHandler: { (response) in

                    // Store the response
                    let request=response.request
                    let result=response.result
                    let timeline=response.timeline
                    let statusCode=response.response?.statusCode ?? 0

                    // Bartleby consignation
                    let context = HTTPContext( code: 965365178,
                                               caller: "UpdateBlock.execute",
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
                        let m = NSLocalizedString("update  of block",
                                                  comment: "update of block failure description")
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
                                    acknowledgment.operationName="UpdateBlock"
                                    acknowledgment.triggerIndex=index.intValue
                                    acknowledgment.latency=timeline.latency
                                    acknowledgment.requestDuration=timeline.requestDuration
                                    acknowledgment.serializationDuration=timeline.serializationDuration
                                    acknowledgment.totalDuration=timeline.totalDuration
                                    acknowledgment.triggerRelayDuration=triggerRelayDuration.doubleValue
                                    acknowledgment.uids=[block.UID]
                                    document.record(acknowledgment)
                                    document.report(acknowledgment) // Acknowlegments are also metrics
                                }
                            }
                            success(context)
                        }else{
                            // Bartlby does not currenlty discriminate status codes 100 & 101
                            // and treats any status code >= 300 the same way
                            // because we consider that failures differentiations could be done by the caller.

                            let m=NSLocalizedString("update of block",
                                                    comment: "update of block failure description")
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
                    //Let's react according to the context.
                    document.perform(reactions, forContext: context)
                })
            }catch{
                let context = HTTPContext( code:2 ,
                                           caller: "UpdateBlock.execute",
                                           relatedURL:nil,
                                           httpStatusCode:500)
                failure(context)
            }
            
        }else{
            glog(NSLocalizedString("Document is missing", comment: "Document is missing")+" documentUID =\(documentUID)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
        }

    }
}
