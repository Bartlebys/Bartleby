//
//  CreateLocker.swift
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

@objc(CreateLocker) public class CreateLocker : BartlebyObject,JHTTPCommand{

    // Universal type support
    override open class func typeName() -> String {
        return "CreateLocker"
    }

    fileprivate var _locker:Locker = Locker()

    fileprivate var _registryUID:String=Default.NO_UID

    required public convenience init(){
        self.init(Locker(), inRegistryWithUID:Default.NO_UID)
    }


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["_locker","_registryUID"])
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
            case "_locker":
                if let casted=value as? Locker{
                    self._locker=casted
                }
            case "_registryUID":
                if let casted=value as? String{
                    self._registryUID=casted
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
            case "_locker":
               return self._locker
            case "_registryUID":
               return self._registryUID
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
			self._locker <- ( map["_locker"] )
			self._registryUID <- ( map["_registryUID"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self._locker=decoder.decodeObject(of:Locker.self, forKey: "_locker")! 
			self._registryUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "_registryUID")! as NSString)
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self._locker,forKey:"_locker")
		coder.encode(self._registryUID,forKey:"_registryUID")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }


    /**
    This is the designated constructor.

    - parameter locker: the Locker concerned the operation
    - parameter registryUID the registry or document UID

    */
    init (_ locker:Locker=Locker(), inRegistryWithUID registryUID:String) {
        self._locker=locker
        self._registryUID=registryUID
        super.init()
    }

    /**
     Returns an operation with self.UID as commandUID

     - returns: return the operation
     */
    fileprivate func _getOperation()->PushOperation{
        if let document = Bartleby.sharedInstance.getDocumentByUID(self._registryUID) {
            if let ic:PushOperationsManagedCollection = try? document.getCollection(){
                let operations=ic.filter({ (operation) -> Bool in
                    return operation.commandUID==self.UID
                })
                if let operation=operations.first {
                    return operation
                }}
        }
        let operation=PushOperation()
        operation.disableSupervision()
        operation.commandUID=self.UID
        operation.defineUID()
        return operation
    }


    /**
    Creates the operation and proceeds to commit

    - parameter locker: the instance
    - parameter registryUID:     the registry or document UID
    */
    static func commit(_ locker:Locker, inRegistryWithUID registryUID:String){
        let operationInstance=CreateLocker(locker,inRegistryWithUID:registryUID)
        operationInstance.commit()
    }


    func commit(){
        let context=Context(code:1761865316, caller: "CreateLocker.commit")
        if let document = Bartleby.sharedInstance.getDocumentByUID(self._registryUID) {
            // Provision the operation.
            do{
                let ic:PushOperationsManagedCollection = try document.getCollection()
                let operation=self._getOperation()
                operation.counter += 1
                operation.status=PushOperation.Status.pending
                operation.creationDate=Date()
				operation.summary="CreateLocker(\(self._locker.UID))"
                if let currentUser=document.registryMetadata.currentUser{
                    operation.creatorUID=currentUser.UID
                    self.creatorUID=currentUser.UID
                }
				self._locker.committed=true

                operation.toDictionary=self.dictionaryRepresentation()
                operation.enableSupervision()
                ic.add(operation, commit:false)
            }catch{
                Bartleby.sharedInstance.dispatchAdaptiveMessage(context,
                    title: "Structural Error",
                    body: "Operation collection is missing in  CreateLocker",
                    onSelectedIndex: { (selectedIndex) -> () in
                })
            }
        }else{
            // This document is not available there is nothing to do.
            let m=NSLocalizedString("Registry is missing", comment: "Registry is missing")
            Bartleby.sharedInstance.dispatchAdaptiveMessage(context,
                    title: NSLocalizedString("Structural error", comment: "Structural error"),
                    body: "\(m) registryUID =\(self._registryUID) in CreateLocker",
                    onSelectedIndex: { (selectedIndex) -> () in
                    }
            )
        }
    }

    open func push(sucessHandler success:@escaping (_ context:JHTTPResponse)->(),
        failureHandler failure:@escaping (_ context:JHTTPResponse)->()){
        // The unitary operation are not always idempotent
        // so we do not want to push multiple times unintensionnaly.
        // Check BartlebyDocument+Operations.swift to understand Operation status
        let operation=self._getOperation()
        if  operation.canBePushed(){
            // We try to execute
            operation.status=PushOperation.Status.inProgress
            CreateLocker.execute(self._locker,
                inRegistryWithUID:self._registryUID,
                sucessHandler: { (context: JHTTPResponse) -> () in 
					self._locker.distributed=true
                    operation.counter=operation.counter+1
                    operation.status=PushOperation.Status.completed
                    operation.responseDictionary=Mapper<JHTTPResponse>().toJSON(context)
                    operation.lastInvocationDate=Date()
                    let completion=Completion.successStateFromJHTTPResponse(context)
                    completion.setResult(context)
                    operation.completionState=completion
                    success(context)
                },
                failureHandler: {(context: JHTTPResponse) -> () in
                    operation.counter=operation.counter+1
                    operation.status=PushOperation.Status.completed
                    operation.responseDictionary=Mapper<JHTTPResponse>().toJSON(context)
                    operation.lastInvocationDate=Date()
                    let completion=Completion.failureStateFromJHTTPResponse(context)
                    completion.setResult(context)
                    operation.completionState=completion
                    failure(context)
                }
            )
        }else{
            // This document is not available there is nothing to do.
            let context=Context(code:3189277510, caller: "CreateLocker.push")
            Bartleby.sharedInstance.dispatchAdaptiveMessage(context,
                title: NSLocalizedString("Push error", comment: "Push error"),
                body: "\(NSLocalizedString("Attempt to push an operation with status \"",comment:"Attempt to push an operation with status =="))\(operation.status)\"" + "\n\(#file)\n\(#function)",
                onSelectedIndex: { (selectedIndex) -> () in
            })
        }
    }

    static open func execute(_ locker:Locker,
            inRegistryWithUID registryUID:String,
            sucessHandler success: @escaping(_ context:JHTTPResponse)->(),
            failureHandler failure: @escaping(_ context:JHTTPResponse)->()){
            if let document = Bartleby.sharedInstance.getDocumentByUID(registryUID) {
                let pathURL = document.baseURL.appendingPathComponent("locker")
                var parameters=Dictionary<String, Any>()
                parameters["locker"]=Mapper<Locker>().toJSON(locker)
                let urlRequest=HTTPManager.requestWithToken(inRegistryWithUID:document.UID,withActionName:"CreateLocker" ,forMethod:"POST", and: pathURL)
                do {
                    let r=try JSONEncoding().encode(urlRequest,with:parameters)
                    request(r).validate().responseJSON(completionHandler: { (response) in

                    // Store the response
                    let request=response.request
                    let result=response.result
                    let response=response.response

                    // Bartleby consignation
                    let context = JHTTPResponse( code: 503102730,
                        caller: "CreateLocker.execute",
                        relatedURL:request?.url,
                        httpStatusCode: response?.statusCode ?? 0,
                        response: response,
                        result:result.value)

                    // React according to the situation
                    var reactions = Array<Bartleby.Reaction> ()
                    reactions.append(Bartleby.Reaction.track(result: result.value, context: context)) // Tracking

                    if result.isFailure {
                        let m = NSLocalizedString("creation  of locker",
                            comment: "creation of locker failure description")
                        let failureReaction =  Bartleby.Reaction.dispatchAdaptiveMessage(
                            context: context,
                            title: NSLocalizedString("Unsuccessfull attempt result.isFailure is true",
                            comment: "Unsuccessfull attempt"),
                            body:"\(m) \n \(response)" + "\n\(#file)\n\(#function)\nhttp Status code: (\(response?.statusCode ?? 0))",
                            transmit:{ (selectedIndex) -> () in
                        })
                        reactions.append(failureReaction)
                        failure(context)
                    }else{
                        if let statusCode=response?.statusCode {
                            if 200...299 ~= statusCode {
                                // Acknowledge the trigger if there is one
                                if let dictionary = result.value as? Dictionary< String,AnyObject > {
                                    if let index=dictionary["triggerIndex"] as? NSNumber{
										let acknowledgment=Acknowledgment()
										acknowledgment.triggerIndex=index.intValue
										acknowledgment.uids=[locker.UID]
										acknowledgment.versions=[locker.version]
										document.record(acknowledgment)
                                    }
                                }
                                success(context)
                            }else{
                                // Bartlby does not currenlty discriminate status codes 100 & 101
                                // and treats any status code >= 300 the same way
                                // because we consider that failures differentiations could be done by the caller.

                                let m=NSLocalizedString("creation of locker",
                                        comment: "creation of locker failure description")
                                let failureReaction =  Bartleby.Reaction.dispatchAdaptiveMessage(
                                    context: context,
                                    title: NSLocalizedString("Unsuccessfull attempt",
                                    comment: "Unsuccessfull attempt"),
                                    body: "\(m) \n \(response)" + "\n\(#file)\n\(#function)\nhttp Status code: (\(response?.statusCode ?? 0))",
                                    transmit:{ (selectedIndex) -> () in
                                    })
                                reactions.append(failureReaction)
                                failure(context)
                            }
                        }
                     }
                    //Let's react according to the context.
                    Bartleby.sharedInstance.perform(reactions, forContext: context)
                })
                }catch{
                    let context = JHTTPResponse( code:2 ,
                    caller: "CreateLocker.execute",
                    relatedURL:nil,
                    httpStatusCode:500,
                    response:nil,
                    result:"{\"message\":\"\(error)}")
                    failure(context)
                }

            }else{
                let context = JHTTPResponse( code:1 ,
                    caller: "CreateLocker.execute",
                    relatedURL:nil,
                    httpStatusCode:417,
                    response:nil,
                    result:"{\"message\":\"Unexisting document with registryUID \(registryUID)\"}")
                    failure(context)
            }
        }
}
