//
//  DeleteUser.swift
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

@objc(DeleteUser) public class DeleteUser : BartlebyObject,JHTTPCommand{

    // Universal type support
    override open class func typeName() -> String {
        return "DeleteUser"
    }

    fileprivate var _userId:String = String()

    fileprivate var _registryUID:String=Default.NO_UID

    required public convenience init(){
        self.init(String(), fromRegistryWithUID:Default.NO_UID)
    }




    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["_userId","_registryUID"])
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

            case "_userId":
                if let casted=value as? String{
                    self._userId=casted
                }
            case "_registryUID":
                if let casted=value as? String{
                    self._registryUID=casted
                }
            default:
                throw ObjectExpositionError.UnknownKey(key: key)
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

            case "_userId":
               return self._userId
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
			self._userId <- ( map["_userId"] )
			self._registryUID <- ( map["_registryUID"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {super.init(coder: decoder)
        self.silentGroupedChanges {
			self._userId=String(describing: decoder.decodeObject(of: NSString.self, forKey: "_userId")! as NSString)
			self._registryUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "_registryUID")! as NSString)
        }
    }

    override open func encode(with coder: NSCoder) {super.encode(with:coder)
		coder.encode(self._userId,forKey:"_userId")
		coder.encode(self._registryUID,forKey:"_registryUID")
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }



    /**
    This is the designated constructor.

    - parameter userId: the userId concerned the operation
    - parameter registryUID the registry or document UID

    */
    init (_ userId:String=String(), fromRegistryWithUID registryUID:String) {
        self._userId=userId
        self._registryUID=registryUID
        super.init()
    }

    /**
     Returns an operation with self.UID as commandUID

     - returns: return the operation
     */
    fileprivate func _getOperation()->PushOperation{
        if let document = Bartleby.sharedInstance.getDocumentByUID(self._registryUID) {
            if let ic:PushOperationsCollectionController = try? document.getCollection(){
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

    - parameter userId: the instance
    - parameter registryUID:     the registry or document UID
    */
    static func commit(_ userId:String, fromRegistryWithUID registryUID:String){
        let operationInstance=DeleteUser(userId,fromRegistryWithUID:registryUID)
        operationInstance.commit()
    }


    func commit(){
        let context=Context(code:3979490154, caller: "DeleteUser.commit")
        if let document = Bartleby.sharedInstance.getDocumentByUID(self._registryUID) {
            // Provision the operation.
            do{
                let ic:PushOperationsCollectionController = try document.getCollection()
                let operation=self._getOperation()
                operation.counter += 1
                operation.status=PushOperation.Status.pending
                operation.creationDate=Date()
                operation.summary="DeleteUser(\(self._userId))"
                if let currentUser=document.registryMetadata.currentUser{
                    operation.creatorUID=currentUser.UID
                    self.creatorUID=currentUser.UID
                }
                operation.toDictionary=self.dictionaryRepresentation()
                operation.enableSupervision()
                ic.add(operation, commit:false)
            }catch{
                Bartleby.sharedInstance.dispatchAdaptiveMessage(context,
                    title: "Structural Error",
                    body: "Operation collection is missing in  DeleteUser",
                    onSelectedIndex: { (selectedIndex) -> () in
                })
            }
        }else{
            // This document is not available there is nothing to do.
            let m=NSLocalizedString("Registry is missing", comment: "Registry is missing")
            Bartleby.sharedInstance.dispatchAdaptiveMessage(context,
                    title: NSLocalizedString("Structural error", comment: "Structural error"),
                    body: "\(m) registryUID =\(self._registryUID) in DeleteUser",
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
            DeleteUser.execute(self._userId,
                fromRegistryWithUID:self._registryUID,
                sucessHandler: { (context: JHTTPResponse) -> () in
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
            let context=Context(code:1196847002, caller: "DeleteUser.push")
            Bartleby.sharedInstance.dispatchAdaptiveMessage(context,
                title: NSLocalizedString("Push error", comment: "Push error"),
                body: "\(NSLocalizedString("Attempt to push an operation with status \"",comment:"Attempt to push an operation with status =="))\(operation.status)\"" + "\n\(#file)\n\(#function)",
                onSelectedIndex: { (selectedIndex) -> () in
            })
        }
    }

    static open func execute(_ userId:String,
            fromRegistryWithUID registryUID:String,
            sucessHandler success: @escaping(_ context:JHTTPResponse)->(),
            failureHandler failure: @escaping(_ context:JHTTPResponse)->()){
            if let document = Bartleby.sharedInstance.getDocumentByUID(registryUID) {
                let pathURL = document.baseURL.appendingPathComponent("user")
                var parameters=Dictionary<String, Any>()
                parameters["userId"]=userId
                let urlRequest=HTTPManager.requestWithToken(inRegistryWithUID:document.UID,withActionName:"DeleteUser" ,forMethod:"DELETE", and: pathURL)
                do {
                    let r=try JSONEncoding().encode(urlRequest,with:parameters)
                    request(r).validate().responseJSON(completionHandler: { (response) in

                    // Store the response
                    let request=response.request
                    let result=response.result
                    let response=response.response

                    // Bartleby consignation
                    let context = JHTTPResponse( code: 4206928336,
                        caller: "DeleteUser.execute",
                        relatedURL:request?.url,
                        httpStatusCode: response?.statusCode ?? 0,
                        response: response,
                        result:result.value)

                    // React according to the situation
                    var reactions = Array<Bartleby.Reaction> ()
                    reactions.append(Bartleby.Reaction.track(result: result.value, context: context)) // Tracking

                    if result.isFailure {
                        let m = NSLocalizedString("deleteById  of user",
                            comment: "deleteById of user failure description")
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
                                        document.acknowledgeOwnedTriggerIndex(index.intValue)
                                    }
                                }
                                success(context)
                            }else{
                                // Bartlby does not currenlty discriminate status codes 100 & 101
                                // and treats any status code >= 300 the same way
                                // because we consider that failures differentiations could be done by the caller.

                                let m=NSLocalizedString("deleteById of user",
                                        comment: "deleteById of user failure description")
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
                    caller: "DeleteUser.execute",
                    relatedURL:nil,
                    httpStatusCode:500,
                    response:nil,
                    result:"{\"message\":\"\(error)}")
                    failure(context)
                }

            }else{
                let context = JHTTPResponse( code:1 ,
                    caller: "DeleteUser.execute",
                    relatedURL:nil,
                    httpStatusCode:417,
                    response:nil,
                    result:"{\"message\":\"Unexisting document with registryUID \(registryUID)\"}")
                    failure(context)
            }
        }
}
