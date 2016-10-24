//
//  UpdateUser.swift
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

@objc(UpdateUser) public class UpdateUser : BartlebyObject,JHTTPCommand{

    // Universal type support
    override open class func typeName() -> String {
        return "UpdateUser"
    }

    fileprivate var _user:User = User()

    fileprivate var _documentUID:String=Default.NO_UID

    required public convenience init(){
        self.init(User(), inDocumentWithUID:Default.NO_UID)
    }


    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["_user","_documentUID"])
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
            case "_user":
                if let casted=value as? User{
                    self._user=casted
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
            case "_user":
               return self._user
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
			self._user <- ( map["_user"] )
			self._documentUID <- ( map["_documentUID"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self._user=decoder.decodeObject(of:User.self, forKey: "_user")! 
			self._documentUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "_documentUID")! as NSString)
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self._user,forKey:"_user")
		coder.encode(self._documentUID,forKey:"_documentUID")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }


    /**
    This is the designated constructor.

    - parameter user: the User concerned the operation
    - parameter documentUID the document UID

    */
    init (_ user:User=User(), inDocumentWithUID documentUID:String) {
        self._user=user
        self._documentUID=documentUID
        super.init()
    }

    /**
     Returns an operation with self.UID as commandUID

     - returns: return the operation
     */
    fileprivate func _getOperation()->PushOperation{
        if let document = Bartleby.sharedInstance.getDocumentByUID(self._documentUID) {
            if let ic:PushOperationsManagedCollection = try? document.getCollection(){
                let operations=ic.filter({ (operation) -> Bool in
                    return operation.commandUID==self.UID
                })
                if let operation=operations.first {
                    return operation
                }}
        }
        let operation=PushOperation()
        operation.silentGroupedChanges {
            operation.commandUID=self.UID
            operation.defineUID()
        }
        return operation
    }


    /**
    Creates the operation and proceeds to commit

    - parameter user: the instance
    - parameter documentUID:     the document UID
    */
    static func commit(_ user:User, inDocumentWithUID documentUID:String){
        let operationInstance=UpdateUser(user,inDocumentWithUID:documentUID)
        operationInstance.commit()
    }


    func commit(){
        let context=Context(code:933151040, caller: "UpdateUser.commit")
        if let document = Bartleby.sharedInstance.getDocumentByUID(self._documentUID) {
            // Provision the operation.
            do{
                let ic:PushOperationsManagedCollection = try document.getCollection()
                let operation=self._getOperation()
                operation.counter += 1
                operation.status=PushOperation.Status.pending
                operation.creationDate=Date()
				operation.summary="UpdateUser(\(self._user.UID))"
                if let currentUser=document.metadata.currentUser{
                    operation.creatorUID=currentUser.UID
                    self.creatorUID=currentUser.UID
                }
				self._user.committed=true

                operation.toDictionary=self.dictionaryRepresentation()
                ic.add(operation, commit:false)
            }catch{
               document.dispatchAdaptiveMessage(context,
                    title: "Structural Error",
                    body: "Operation collection is missing in  UpdateUser",
                    onSelectedIndex: { (selectedIndex) -> () in
                })
            }
        }else{
            glog(NSLocalizedString("Document is missing", comment: "Document is missing")+" documentUID =\(self._documentUID)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
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
            UpdateUser.execute(self._user,
                inDocumentWithUID:self._documentUID,
                sucessHandler: { (context: JHTTPResponse) -> () in 
					self._user.distributed=true
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
            glog(NSLocalizedString("Document is missing", comment: "Document is missing")+" documentUID =\(self._documentUID)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
        }
    }

    static open func execute(_ user:User,
            inDocumentWithUID documentUID:String,
            sucessHandler success: @escaping(_ context:JHTTPResponse)->(),
            failureHandler failure: @escaping(_ context:JHTTPResponse)->()){
            if let document = Bartleby.sharedInstance.getDocumentByUID(documentUID) {
                let pathURL = document.baseURL.appendingPathComponent("user")
                var parameters=Dictionary<String, Any>()
                parameters["user"]=Mapper<User>().toJSON(user)
                let urlRequest=HTTPManager.requestWithToken(inDocumentWithUID:document.UID,withActionName:"UpdateUser" ,forMethod:"PUT", and: pathURL)
                do {
                    let r=try JSONEncoding().encode(urlRequest,with:parameters)
                    request(r).validate().responseJSON(completionHandler: { (response) in

                    // Store the response
                    let request=response.request
                    let result=response.result
                    let timeline=response.timeline
                    let response=response.response

                    // Bartleby consignation
                    let context = JHTTPResponse( code: 564249844,
                        caller: "UpdateUser.execute",
                        relatedURL:request?.url,
                        httpStatusCode: response?.statusCode ?? 0,
                        response: response,
                        result:result.value)

                    // React according to the situation
                    var reactions = Array<Reaction> ()
                    reactions.append(Reaction.track(result: result.value, context: context)) // Tracking

                    if result.isFailure {
                        let m = NSLocalizedString("update  of user",
                            comment: "update of user failure description")
                        let failureReaction =  Reaction.dispatchAdaptiveMessage(
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
										acknowledgment.operationName="UpdateUser"
										acknowledgment.triggerIndex=index.intValue
										acknowledgment.latency=timeline.latency
										acknowledgment.requestDuration=timeline.requestDuration
										acknowledgment.serializationDuration=timeline.serializationDuration
										acknowledgment.totalDuration=timeline.totalDuration
										acknowledgment.uids=[user.UID]
										document.record(acknowledgment)
										document.report(acknowledgment) // Acknowlegments are also metrics
                                    }
                                }
                                success(context)
                            }else{
                                // Bartlby does not currenlty discriminate status codes 100 & 101
                                // and treats any status code >= 300 the same way
                                // because we consider that failures differentiations could be done by the caller.

                                let m=NSLocalizedString("update of user",
                                        comment: "update of user failure description")
                                let failureReaction =  Reaction.dispatchAdaptiveMessage(
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
                    document.perform(reactions, forContext: context)
                })
                }catch{
                    let context = JHTTPResponse( code:2 ,
                    caller: "UpdateUser.execute",
                    relatedURL:nil,
                    httpStatusCode:500,
                    response:nil,
                    result:"{\"message\":\"\(error)}")
                    failure(context)
                }

            }else{
                glog(NSLocalizedString("Document is missing", comment: "Document is missing")+" documentUID =\(documentUID)", file: #file, function: #function, line: #line, category: Default.LOG_CATEGORY, decorative: false)
            }
        }
}
