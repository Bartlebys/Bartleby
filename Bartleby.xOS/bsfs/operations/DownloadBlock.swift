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

/// A cancelable download Block Operation
public class DownloadBlock {

    // https://github.com/Alamofire/Alamofire#downloading-data-to-a-file
    // We could may be resume if necessary.
    // But with our block oriented approach it is not a priority


    internal var _downloadRequest:DownloadRequest?

    internal var _sucessHandler:(_ fileTempURL:URL)->()

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
                sucessHandler success: @escaping(_ fileTempURL:URL)->(),
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
        if let downloadRequest = self._downloadRequest{
            downloadRequest.cancel()
        }
        self._cancelationHandler()
    }


    public var blockUID:String{ return _block.UID }

    public func execute(){
        if let document = Bartleby.sharedInstance.getDocumentByUID(self._documentUID) {
            let pathURL = document.baseURL.appendingPathComponent("block/\(self._block.UID)")

            let tempUrl=URL(fileURLWithPath:document.bsfs.downloadFolderPath+"/\(Bartleby.createUID())")
            let destination:DownloadRequest.DownloadFileDestination = {_,_ in
                return (tempUrl, [.removePreviousFile, .createIntermediateDirectories])
            }

            let queue = DispatchQueue.main
            self._downloadRequest = download(HTTPManager.requestWithToken(inDocumentWithUID:document.UID,withActionName:"DownloadBlock" ,forMethod:"GET", and: pathURL),to:destination)
            self._downloadRequest!.response(completionHandler: { (response) in
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
                        self._sucessHandler(tempUrl)
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
                        self._failureHandler(context)
                    }
                }
                Async.main{
                    //Let's react according to the context.
                    document.perform(reactions, forContext: context)
                }
            }).downloadProgress(queue: queue) { progress in
                self._block.downloadProgression.updateProgression(from: progress)
            }


        }else{
            glog(NSLocalizedString("Document is missing", comment: "Document is missing")+" documentUID =\(self._documentUID)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
        }
        
    }
    
}
