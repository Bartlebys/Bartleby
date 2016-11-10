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
    }
    
}
