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



/// A cancelable Upload Block Operation
public class UploadBlock {

    // https://github.com/Alamofire/Alamofire#uploading-data-to-a-server
    // We could may be resume if necessary.
    // But with our block oriented approach it is not a priority

    enum UploadBlockError:Error{
        case responseIssue(message:String)
    }

    internal var _uploadRequest:UploadRequest?

    internal var _sucessHandler:(_ context:HTTPContext)->()

    internal var _failureHandler:(_ context:HTTPContext)->()

    internal var _cancelationHandler:()->()

    internal var _block:Block

    internal var _documentUID:String

    /// Initializer
    ///
    /// - Parameters:
    ///   - block: the block
    ///   - documentUID: its document UID
    ///   - success: the success closure
    ///   - failure: the failure closure
    public init(block:Block,documentUID:String,
                sucessHandler success: @escaping(_ context:HTTPContext)->(),
                failureHandler failure: @escaping(_ context:HTTPContext)->(),
                cancelationHandler cancel: @escaping()->()){
        self._block=block
        self._documentUID=documentUID
        self._sucessHandler=success
        self._failureHandler=failure
        self._cancelationHandler=cancel
    }

    /// Cancels the operation
    public func cancel(){
        if let uploadRequest = self._uploadRequest{
            uploadRequest.cancel()
        }
        self._cancelationHandler()
    }

    public var blockUID:String{ return _block.UID }

    public func execute(){

        if let document = Bartleby.sharedInstance.getDocumentByUID(self._documentUID) {
            let pathURL = document.baseURL.appendingPathComponent("block/\(self._block.UID)")
            if let data=self._block.data{
                let r=HTTPManager.requestWithToken(inDocumentWithUID:document.UID,withActionName:"UploadBlock" ,forMethod:"POST", and: pathURL)
                self._uploadRequest = upload(data, with: r)
                self._uploadRequest!.responseString(completionHandler: { (response) in

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
                        self._failureHandler(context)

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
                                            acknowledgment.uids=[self._block.UID]
                                            document.record(acknowledgment)
                                        }else{
                                            throw UploadBlockError.responseIssue(message: "triggerIndex not found")
                                        }
                                    }else{
                                        throw UploadBlockError.responseIssue(message: "dictionary is not available")
                                    }
                                    self._sucessHandler(context)
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
                                self._failureHandler(context)
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
                            self._failureHandler(context)
                        }
                        
                        
                        //Let's react according to the context.
                        document.perform(reactions, forContext: context)
                    }
                })

            }else{
                // Bartleby consignation
                let context = HTTPContext( code: 827,
                                           caller: "UpdateBlock.execute",
                                           relatedURL:nil,
                                           httpStatusCode:500)
                self._failureHandler(context)
            }

        }else{
            glog(NSLocalizedString("Document is missing", comment: "Document is missing")+" _documentUID =\(self._documentUID)", file: #file, function: #function, line: #line, category: Default.LOG_DEFAULT, decorative: false)
        }
    }
}

