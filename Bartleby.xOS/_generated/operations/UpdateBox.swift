//
//  UpdateBox.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for [Benoit Pereira da Silva] (https://pereira-da-silva.com/contact)
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
//
// Copyright (c) 2016  [Bartleby's org] (https://bartlebys.org)   All rights reserved.
//
import Foundation
#if !USE_EMBEDDED_MODULES
	import Alamofire
	import ObjectMapper
#endif

@objc(UpdateBox) public class UpdateBox : BartlebyObject,BartlebyOperation{

    // Universal type support
    override open class func typeName() -> String {
        return "UpdateBox"
    }

    fileprivate var _box:Box = Box()

    fileprivate var _documentUID:String=Default.NO_UID

    required public init() {
        super.init()
    }


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["_box","_documentUID"])
        return exposed
    }


    /// Set the value of the given key
    ///
    /// - parameter value: the value
    /// - parameter key:   the key
    ///
    /// - throws: throws an Exception when the key is not exposed
    override open func setExposedValue(_ value:Any?, forKey key: String) throws {
        switch key {
            case "_box":
                if let casted=value as? Box{
                    self._box=casted
                }
            case "_documentUID":
                if let casted=value as? String{
                    self._documentUID=casted
                }
            default:
                return try super.setExposedValue(value, forKey: key)
        }
    }


    /// Returns the value of an exposed key.
    ///
    /// - parameter key: the key
    ///
    /// - throws: throws Exception when the key is not exposed
    ///
    /// - returns: returns the value
    override open func getExposedValueForKey(_ key:String) throws -> Any?{
        switch key {
            case "_box":
               return self._box
            case "_documentUID":
               return self._documentUID
            default:
                return try super.getExposedValueForKey(key)
        }
    }
    // MARK: - Mappable

    required public init?(map: Map) {
        super.init(map:map)
    }

    override open func mapping(map: Map) {
        super.mapping(map: map)
        self.silentGroupedChanges {
			self._box <- ( map["_box"] )
			self._documentUID <- ( map["_documentUID"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self._box=decoder.decodeObject(of:Box.self, forKey: "_box")! 
			self._documentUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "_documentUID")! as NSString)
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self._box,forKey:"_box")
		coder.encode(self._documentUID,forKey:"_documentUID")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }


    /**
     Returns an operation with self.UID as commandUID

     - returns: return the operation
     */
    internal func _getOperation()->PushOperation{
        if let document = Bartleby.sharedInstance.getDocumentByUID(self._documentUID) {
            if let ic:PushOperationsManagedCollection = try? document.getCollection(){
                let pushOperations=ic.filter({ (pushOperation) -> Bool in
                    return pushOperation.commandUID==self.UID
                })
                if let pushOperation=pushOperations.first {
                    return pushOperation
                }}
        }
        let pushOperation=PushOperation()
        pushOperation.silentGroupedChanges {
            pushOperation.commandUID=self.UID
            pushOperation.defineUID()
        }
        return pushOperation
    }


    /**
    Creates the operation and proceeds to commit

    - parameter box: the instance
    - parameter documentUID:     the document UID
    */
    static func commit(_ box:Box, inDocumentWithUID documentUID:String){
        let operationInstance=UpdateBox()
        operationInstance._box=box
        operationInstance._documentUID=documentUID
        operationInstance.commit()
    }


    func commit(){
        let context=Context(code:512285073, caller: "\(self.runTimeTypeName()).commit")
        if let document = Bartleby.sharedInstance.getDocumentByUID(self._documentUID) {
            // Provision the pushOperation.
            do{
                let ic:PushOperationsManagedCollection = try document.getCollection()
                let pushOperation=self._getOperation()
                pushOperation.counter += 1
                pushOperation.status=PushOperation.Status.pending
                pushOperation.creationDate=Date()
				pushOperation.summary="\(self.runTimeTypeName())(\(self._box.UID))"
                if let currentUser=document.metadata.currentUser{
                    pushOperation.creatorUID=currentUser.UID
                    self.creatorUID=currentUser.UID
                }
				self._box.committed=true

                pushOperation.toDictionary=self.dictionaryRepresentation()
                ic.add(pushOperation, commit:false)
            }catch{
               document.dispatchAdaptiveMessage(context,
                    title: "Structural Error",
                    body: "Operation collection is missing in \(self.runTimeTypeName())",
                    onSelectedIndex: { (selectedIndex) -> () in
                })
            }
        }else{
            glog(NSLocalizedString("Document is missing", comment: "Document is missing")+" documentUID =\(self._documentUID)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
        }
    }

    open func push(sucessHandler success:@escaping (_ context:HTTPContext)->(),
        failureHandler failure:@escaping (_ context:HTTPContext)->()){
        // The unitary operation are not always idempotent
        // so we do not want to push multiple times unintensionnaly.
        // Check BartlebyDocument+Operations.swift to understand Operation status
        let pushOperation=self._getOperation()
        if  pushOperation.canBePushed(){
            // We try to execute
            pushOperation.status=PushOperation.Status.inProgress
            type(of: self).execute(self._box,
                inDocumentWithUID:self._documentUID,
                sucessHandler: { (context: HTTPContext) -> () in 
					self._box.hasBeenPushed=true
                    pushOperation.counter=pushOperation.counter+1
                    pushOperation.status=PushOperation.Status.completed
                    pushOperation.responseDictionary=Mapper<HTTPContext>().toJSON(context)
                    pushOperation.lastInvocationDate=Date()
                    let completion=Completion.successStateFromHTTPContext(context)
                    completion.setResult(context)
                    pushOperation.completionState=completion
                    success(context)
                },
                failureHandler: {(context: HTTPContext) -> () in
                    pushOperation.counter=pushOperation.counter+1
                    pushOperation.status=PushOperation.Status.completed
                    pushOperation.responseDictionary=Mapper<HTTPContext>().toJSON(context)
                    pushOperation.lastInvocationDate=Date()
                    let completion=Completion.failureStateFromHTTPContext(context)
                    completion.setResult(context)
                    pushOperation.completionState=completion
                    failure(context)
                }
            )
        }else{
            // This document is not available there is nothing to do.
            glog(NSLocalizedString("Document is missing", comment: "Document is missing")+" documentUID =\(self._documentUID)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
        }
    }

    open class func execute(_ box:Box,
            inDocumentWithUID documentUID:String,
            sucessHandler success: @escaping(_ context:HTTPContext)->(),
            failureHandler failure: @escaping(_ context:HTTPContext)->()){
            if let document = Bartleby.sharedInstance.getDocumentByUID(documentUID) {
                let pathURL = document.baseURL.appendingPathComponent("box")
                var parameters=Dictionary<String, Any>()
                parameters["box"]=Mapper<Box>().toJSON(box)
                let urlRequest=HTTPManager.requestWithToken(inDocumentWithUID:document.UID,withActionName:"UpdateBox" ,forMethod:"PUT", and: pathURL)
                do {
                    let r=try JSONEncoding().encode(urlRequest,with:parameters)
                    request(r).responseJSON(completionHandler: { (response) in

                    // Store the response
                    let request=response.request
                    let result=response.result
                    let timeline=response.timeline
                    let statusCode=response.response?.statusCode ?? 0

                    // Bartleby consignation
                    let context = HTTPContext( code: 3495702702,
                        caller: "UpdateBox.execute",
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
                        let m = NSLocalizedString("update  of box",
                            comment: "update of box failure description")
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
										acknowledgment.operationName="UpdateBox"
										acknowledgment.triggerIndex=index.intValue
										acknowledgment.latency=timeline.latency
										acknowledgment.requestDuration=timeline.requestDuration
										acknowledgment.serializationDuration=timeline.serializationDuration
										acknowledgment.totalDuration=timeline.totalDuration
										acknowledgment.triggerRelayDuration=triggerRelayDuration.doubleValue
										acknowledgment.uids=[box.UID]
										document.record(acknowledgment)
										document.report(acknowledgment) // Acknowlegments are also metrics
                                }
                            }
                            success(context)
                        }else{
                            // Bartlby does not currenlty discriminate status codes 100 & 101
                            // and treats any status code >= 300 the same way
                            // because we consider that failures differentiations could be done by the caller.

                            let m=NSLocalizedString("update of box",
                                    comment: "update of box failure description")
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
                    caller: "UpdateBox.execute",
                    relatedURL:nil,
                    httpStatusCode:500)
                    failure(context)
                }

            }else{
                glog(NSLocalizedString("Document is missing", comment: "Document is missing")+" documentUID =\(documentUID)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
            }
        }
}
