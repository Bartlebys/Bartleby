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


enum UploadBlockError:Error{
    case responseIssue(message:String)
}

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

            let pathURL = document.baseURL.appendingPathComponent("block/\(block.UID)")
            let r = upload(block.url, with: HTTPManager.requestWithToken(inDocumentWithUID:document.UID,withActionName:"UploadBlock" ,forMethod:"POST", and: pathURL))

            r.responseString(completionHandler: { (response) in

                // Store the response
                let request=response.request
                let result=response.result
                let statusCode=response.response?.statusCode ?? 0

                // Bartleby consignation
                let context = HTTPContext( code: 826,
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
                    let m = NSLocalizedString("Upload of a block failure",
                                              comment: "Upload of a block failure description")
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

                        do{
                            if let data = response.data{
                                // Acknowledge the trigger if there is one
                                // We don't incorporate Metrics reports
                                // Because Upload & Downloads are not comparable with the other requests.

                                let jsonObject = try JSONSerialization.jsonObject(with: data, options:[])

                                if let dictionary = jsonObject as? [String: Any] {
                                    if let index=dictionary["triggerIndex"] as? NSNumber{
                                        let acknowledgment=Acknowledgment()
                                        acknowledgment.httpContext=context
                                        acknowledgment.operationName="UploadBlock"
                                        acknowledgment.triggerIndex=index.intValue
                                        acknowledgment.uids=[block.UID]
                                        document.record(acknowledgment)
                                    }else{
                                        throw UploadBlockError.responseIssue(message: "triggerIndex not found")
                                    }
                                }else{
                                    throw UploadBlockError.responseIssue(message: "dictionary is not available")
                                }
                                success(context)
                            }else{
                                throw UploadBlockError.responseIssue(message: "Data not found")
                            }
                        }catch{
                            // JSON de serialization issue
                            let context = HTTPContext( code:827 ,
                                                       caller: "UpdateBlock.execute",
                                                       relatedURL:nil,
                                                       httpStatusCode:statusCode)
                            context.message="\(error)"
                            failure(context)
                        }

                    }else{
                        // Bartlby does not currenlty discriminate status codes 100 & 101
                        // and treats any status code >= 300 the same way
                        // because we consider that failures differentiations could be done by the caller.

                        let m=NSLocalizedString("Upload of a block failure",
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


                    //Let's react according to the context.
                    document.perform(reactions, forContext: context)
                }
            })
            
        }else{
            glog(NSLocalizedString("Document is missing", comment: "Document is missing")+" documentUID =\(documentUID)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
        }
    }
}

