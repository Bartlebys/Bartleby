//
//  DownloadBlock.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/05/2016.
//
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import Alamofire
#endif

@objc(DownloadBlock) public class DownloadBlock: BlockOperationBase {

    // Universal type support
    override open class func typeName() -> String {
        return "DownloadBlock"
    }

    open override class func execute(_ block:Block,
                                     inDocumentWithUID documentUID:String,
                                     sucessHandler success: @escaping(_ context:HTTPContext)->(),
                                     failureHandler failure: @escaping(_ context:HTTPContext)->()){

        if let document = Bartleby.sharedInstance.getDocumentByUID(documentUID) {

            let pathURL = document.baseURL.appendingPathComponent("block/\(block.UID)")
            let destination:DownloadRequest.DownloadFileDestination = {_,_ in
                let url=URL(string:block.absolutePath)!
                return (url, [.removePreviousFile, .createIntermediateDirectories])
            }

            // https://github.com/Alamofire/Alamofire#downloading-data-to-a-file
            // We could may be resume if necessary.
            // But with our block oriented approach it is not a priority
            // The Resume data could be stored in the Operation.

            let queue = GlobalQueue.main.get()

            let r = download(HTTPManager.requestWithToken(inDocumentWithUID:document.UID,withActionName:"DownloadBlock" ,forMethod:"GET", and: pathURL),to:destination)
            r.response(completionHandler: { (response) in
                // Store the response
                let request=response.request
                let statusCode=response.response?.statusCode ?? 0

                // Bartleby consignation
                let context = HTTPContext( code: 825,
                                           caller: "DownloadBlock.execute",
                                           relatedURL:request?.url,
                                           httpStatusCode: statusCode)

                if let request=request{
                    context.request=HTTPRequest(urlRequest: request)
                }

                // React according to the situation
                var reactions = Array<Reaction> ()

                if 200...299 ~= statusCode {
                    Async.main{
                        success(context)
                    }
                }else{
                    Async.main{
                        let m=NSLocalizedString("Download block failure",
                                                comment: "Download block failure description")
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
                Async.main{
                    //Let's react according to the context.
                    document.perform(reactions, forContext: context)
                }
            }).downloadProgress(queue: queue) { progress in
                block.downloadProgression.updateProgression(from: progress)
            }


        }else{
            glog(NSLocalizedString("Document is missing", comment: "Document is missing")+" documentUID =\(documentUID)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
        }
        
    }
    
}
