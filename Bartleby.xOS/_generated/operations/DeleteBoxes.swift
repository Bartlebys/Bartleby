//
//  DeleteBoxes.swift
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

@objc(DeleteBoxes) public class DeleteBoxes : ManagedModel,BartlebyOperation{

    // Universal type support
    override open class func typeName() -> String {
        return "DeleteBoxes"
    }

    override open class var collectionName:String{
        return "embeddedInPushOperations"
    }

    override open var d_collectionName:String{
        return "embeddedInPushOperations"
    }

    fileprivate var _payload:String=Default.VOID_STRING

    required public init() {
        super.init()
    }


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
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
    override open func setExposedValue(_ value:Any?, forKey key: String) throws {
        switch key {
            case "_payload":
                if let casted=value as? String{
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
    override open func getExposedValueForKey(_ key:String) throws -> Any?{
        switch key {
            case "_payload":
               return self._payload
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
        self.quietChanges {
			self._payload <- ( map["_payload"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.quietChanges {
			self._payload=String(describing: decoder.decodeObject(of: NSString.self, forKey: "_payload")! as NSString)
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self._payload,forKey:"_payload")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }


    /**
    Creates the operation and proceeds to commit

    - parameter boxes: the instance
    - parameter document:     the document
    */
    static func commit(_ boxes:[Box], from document:BartlebyDocument){
        let operationInstance=DeleteBoxes()
        operationInstance.referentDocument = document
        operationInstance._payload=boxes.toJSONString() ?? Default.VOID_STRING
        let context=Context(code:4041552439, caller: "\(operationInstance.runTimeTypeName()).commit")
        do{
            let ic:ManagedPushOperations = try document.getCollection()
            // Create the pushOperation
            let pushOperation = PushOperation()
            pushOperation.quietChanges{
                pushOperation.commandUID=operationInstance.UID
                pushOperation.collection = ic
                pushOperation.counter += 1
                pushOperation.status=PushOperation.Status.pending
                pushOperation.creationDate=Date()
				let stringIDS=PString.ltrim(boxes.reduce("", { $0+","+$1.UID }),characters:",")
				pushOperation.summary="\(operationInstance.runTimeTypeName())(\(stringIDS))"
                if let currentUser=document.metadata.currentUser{
                    pushOperation.creatorUID=currentUser.UID
                    operationInstance.creatorUID=currentUser.UID
                }
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
        if let boxes = Mapper <Box>().mapArray(JSONString:self._payload){
            do{
                // The unitary operation are not always idempotent
                // so we do not want to push multiple times unintensionnaly.
                // Check BartlebyDocument+Operations.swift to understand Operation status
                let pushOperation = try self._getOperation()
                // Provision the operation
                if  pushOperation.canBePushed(){
                    pushOperation.status=PushOperation.Status.inProgress
                    type(of: self).execute(boxes,
                        from:self.documentUID,
                        sucessHandler: { (context: HTTPContext) -> () in
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
                    glog(NSLocalizedString("Document is missing", comment: "Document is missing")+" documentUID =\(self.documentUID)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
                }
            }catch{
                let context = HTTPContext( code:3 ,
                caller: "DeleteBoxes.execute",
                relatedURL:nil,
                httpStatusCode:StatusOfCompletion.undefined.rawValue)
                context.message="\(error)"
                failure(context)
                glog("\(error)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
            }

        }else{
            glog("boxes should not be nil", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
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

    

    open class func execute(_ boxes:[Box],
            from documentUID:String,
            sucessHandler success: @escaping(_ context:HTTPContext)->(),
            failureHandler failure: @escaping(_ context:HTTPContext)->()){
            if let document = Bartleby.sharedInstance.getDocumentByUID(documentUID) {
                let pathURL = document.baseURL.appendingPathComponent("boxes")
                var parameters=Dictionary<String, Any>()
                parameters["ids"]=boxes.map{$0.UID}
                let urlRequest=HTTPManager.requestWithToken(inDocumentWithUID:document.UID,withActionName:"DeleteBoxes" ,forMethod:"DELETE", and: pathURL)
                do {
                    let r=try JSONEncoding().encode(urlRequest,with:parameters)
                    request(r).responseJSON(completionHandler: { (response) in

                    // Store the response
                    let request=response.request
                    let result=response.result
                    let timeline=response.timeline
                    let statusCode=response.response?.statusCode ?? 0

                    // Bartleby consignation
                    let context = HTTPContext( code: 4010236824,
                        caller: "DeleteBoxes.execute",
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
                        let m = NSLocalizedString("deleteByIds  of boxes",
                            comment: "deleteByIds of boxes failure description")
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
										acknowledgment.operationName="DeleteBoxes"
										acknowledgment.triggerIndex=index.intValue
										acknowledgment.latency=timeline.latency
										acknowledgment.requestDuration=timeline.requestDuration
										acknowledgment.serializationDuration=timeline.serializationDuration
										acknowledgment.totalDuration=timeline.totalDuration
										acknowledgment.triggerRelayDuration=triggerRelayDuration.doubleValue
										acknowledgment.uids=boxes.map({$0.UID})
										document.record(acknowledgment)
										document.report(acknowledgment) // Acknowlegments are also metrics
                                }
                            }
                            success(context)
                        }else{
                            // Bartlby does not currenlty discriminate status codes 100 & 101
                            // and treats any status code >= 300 the same way
                            // because we consider that failures differentiations could be done by the caller.

                            let m=NSLocalizedString("deleteByIds of boxes",
                                    comment: "deleteByIds of boxes failure description")
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
                    caller: "DeleteBoxes.execute",
                    relatedURL:nil,
                    httpStatusCode:StatusOfCompletion.undefined.rawValue)
                    context.message="\(error)"
                    failure(context)
                }

            }else{
                glog(NSLocalizedString("Document is missing", comment: "Document is missing")+" documentUID =\(documentUID)", file: #file, function: #function, line: #line, category: Default.LOG_WARNING, decorative: false)
            }
        }}
