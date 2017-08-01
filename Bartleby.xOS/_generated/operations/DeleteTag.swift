//
//  DeleteTag.swift
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
#endif

@objc(DeleteTag) public class DeleteTag : ManagedModel,BartlebyOperation{

    // Universal type support
    override open class func typeName() -> String {
        return "DeleteTag"
    }

    override open class var collectionName:String{ return "embeddedInPushOperations" }

    override open var d_collectionName:String{ return "embeddedInPushOperations" }

    fileprivate var _payload:Data?

    required public init() {
        super.init()
    }


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override  open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["_payload"])
        return exposed
    }


    /// Set the value of the given key
    ///
    /// - parameter value: the value
    /// - parameter key:   the key
    ///
    /// - throws: throws an Exception when the key is not exposed
    override  open func setExposedValue(_ value:Any?, forKey key: String) throws {
        switch key {
            case "_payload":
                if let casted=value as? Data{
                    self._payload=casted
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
    override  open func getExposedValueForKey(_ key:String) throws -> Any?{
        switch key {
            case "_payload":
               return self._payload
            default:
                return try super.getExposedValueForKey(key)
        }
    }
    // MARK: - Codable


    enum payloadCodingKeys: String,CodingKey{
		case _payload
    }

    required public init(from decoder: Decoder) throws{
		try super.init(from: decoder)
        try self.quietThrowingChanges {
			let values = try decoder.container(keyedBy: payloadCodingKeys.self)
			self._payload = try values.decode(Data.self,forKey:._payload)
        }
    }

    override open func encode(to encoder: Encoder) throws {
		try super.encode(to:encoder)
		var container = encoder.container(keyedBy: payloadCodingKeys.self)
		try container.encodeIfPresent(self._payload,forKey:._payload)
    }


    /**
    Creates the operation and proceeds to commit

    - parameter tag: the instance
    - parameter document:     the document
    */
    static func commit(_ tag:Tag, from document:BartlebyDocument){
        let operationInstance=DeleteTag()
        operationInstance.referentDocument = document
        let context=Context(code:2502634048, caller: "\(operationInstance.runTimeTypeName()).commit")
        do{
            operationInstance._payload = try JSONEncoder().encode(tag.self)
            let ic:ManagedPushOperations = try document.getCollection()
            // Create the pushOperation
            let pushOperation = PushOperation()
            pushOperation.quietChanges{
                pushOperation.commandUID=operationInstance.UID
                pushOperation.collection = ic
                pushOperation.counter += 1
                pushOperation.status=PushOperation.Status.pending
                pushOperation.creationDate=Date()
				pushOperation.summary="\(operationInstance.runTimeTypeName())(\(tag.UID))"
                pushOperation.creatorUID=document.metadata.currentUserUID
                operationInstance.creatorUID=document.metadata.currentUserUID
                
            }
            pushOperation.toDictionary=operationInstance.dictionaryRepresentation()
            ic.add(pushOperation, commit:false)
        }catch{
            document.dispatchAdaptiveMessage(context,
                                             title: "Structural Error",
                                             body: "Operation collection is missing in \(operationInstance.runTimeTypeName())",
                onSelectedIndex: { (selectedIndex) -> () in
            })
            glog("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
        }
    }


    open func push(sucessHandler success:@escaping (_ context:HTTPContext)->(),
        failureHandler failure:@escaping (_ context:HTTPContext)->()){
            do{
                let tag = try JSONDecoder().decode(Tag.self, from:self._payload ?? Data())
                // The unitary operation are not always idempotent
                // so we do not want to push multiple times unintensionnaly.
                // Check BartlebyDocument+Operations.swift to understand Operation status
                let pushOperation = try self._getOperation()
                // Provision the operation
                if  pushOperation.canBePushed(){
                    pushOperation.status=PushOperation.Status.inProgress
                    type(of: self).execute(tag,
                        from:self.documentUID,
                        sucessHandler: { (context: HTTPContext) -> () in
                            pushOperation.counter=pushOperation.counter+1
                            pushOperation.status=PushOperation.Status.completed
                            pushOperation.responseData = try? JSONEncoder().encode(context)
                            pushOperation.lastInvocationDate=Date()
                            let completion=Completion.successStateFromHTTPContext(context)
                            completion.setResult(context)
                            pushOperation.completionState=completion
                            success(context)
                        },
                        failureHandler: {(context: HTTPContext) -> () in
                            pushOperation.counter=pushOperation.counter+1
                            pushOperation.status=PushOperation.Status.completed
                            pushOperation.responseData = try? JSONEncoder().encode(context)
                            pushOperation.lastInvocationDate=Date()
                            let completion=Completion.failureStateFromHTTPContext(context)
                            completion.setResult(context)
                            pushOperation.completionState=completion
                            failure(context)
                        }
                    )
                }else{
                    glog("Operation can't be pushed \(pushOperation.status)", file: #file, function: #function, line: #line, category: Default.LOG_FAULT, decorative: false)
                }
            }catch{
                let context = HTTPContext( code:3 ,
                caller: "DeleteTag.execute",
                relatedURL:nil,
                httpStatusCode:StatusOfCompletion.undefined.rawValue)
                context.message="\(error)"
                failure(context)
                glog("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
            }

    }

    internal func _getOperation()throws->PushOperation{
        if let document = Bartleby.sharedInstance.getDocumentByUID(self.documentUID) {
            if let idx=document.pushOperations.index(where: { $0.commandUID==self.UID }){
                return document.pushOperations[idx]
            }
            throw BartlebyOperationError.operationNotFound(UID:self.UID)
        }
        throw BartlebyOperationError.documentNotFound(documentUID:self.documentUID)
    }

    

    open class func execute(_ tag:Tag,
            from documentUID:String,
            sucessHandler success: @escaping(_ context:HTTPContext)->(),
            failureHandler failure: @escaping(_ context:HTTPContext)->()){
            if let document = Bartleby.sharedInstance.getDocumentByUID(documentUID) {
                let pathURL = document.baseURL.appendingPathComponent("tag")
                var parameters = [String: Any]()
                parameters["tagId"] = tag.UID
                let urlRequest=HTTPManager.requestWithToken(inDocumentWithUID:document.UID,withActionName:"DeleteTag" ,forMethod:"DELETE", and: pathURL)
                do {
                    let r=try JSONEncoding().encode(urlRequest,with:parameters)
                    request(r).responseJSON(completionHandler: { (response) in

                    // Store the response
                    let request=response.request
                    let result=response.result
                    let timeline=response.timeline
                    let statusCode=response.response?.statusCode ?? 0

                    // Bartleby consignation
                    let context = HTTPContext( code: 553873695,
                        caller: "DeleteTag.execute",
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
                        let m = NSLocalizedString("deleteByIds  of tag",
                            comment: "deleteByIds of tag failure description")
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
										if index.intValue >= 0 {
										    // -2 means the trigger relay has been discarded (the status code can be in 200...299
										    // -1 means an error has occured (the status code should be >299
										    let acknowledgment=Acknowledgment()
										    acknowledgment.httpContext=context
										    acknowledgment.operationName="DeleteTag"
										    acknowledgment.triggerIndex=index.intValue
										    acknowledgment.latency=timeline.latency
										    acknowledgment.requestDuration=timeline.requestDuration
										    acknowledgment.serializationDuration=timeline.serializationDuration
										    acknowledgment.totalDuration=timeline.totalDuration
										    acknowledgment.triggerRelayDuration=triggerRelayDuration.doubleValue
										    acknowledgment.uids=[tag.UID]
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

                            let m=NSLocalizedString("deleteByIds of tag",
                                    comment: "deleteByIds of tag failure description")
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
                    caller: "DeleteTag.execute",
                    relatedURL:nil,
                    httpStatusCode:StatusOfCompletion.undefined.rawValue)
                    context.message="\(error)"
                    failure(context)
                }

            }else{
                glog(NSLocalizedString("Document is missing", comment: "Document is missing")+" documentUID =\(documentUID)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
            }
        }}
