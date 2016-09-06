//
//  DeletePermissions.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for b@bartlebys.org
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
//
// Copyright (c) 2016  Bartleby's | https://bartlebys.org  All rights reserved.
//
import Foundation
#if !USE_EMBEDDED_MODULES
import Alamofire
import ObjectMapper
#endif

@objc(DeletePermissions) public class DeletePermissions : JObject,JHTTPCommand{

    // Universal type support
    override public class func typeName() -> String {
        return "DeletePermissions"
    }

    private var _ids:[String] = [String]()

    // The registry UID
    private var _registryUID:String=Default.NO_UID

    // The operation
    private var _operation:Operation=Operation()

    required public convenience init(){
        self.init([String](), fromRegistryWithUID:Default.NO_UID)
    }


    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
        self.disableSupervisionAndCommit()
		self._ids <- ( map["_ids"] )
		self._registryUID <- ( map["_registryUID"] )
		self._operation.registryUID <- ( map["_operation.registryUID"] )
		self._operation.creatorUID <- ( map["_operation.creatorUID"] )
		self._operation.status <- ( map["_operation.status"] )
		self._operation.counter <- ( map["_operation.counter"] )
		self._operation.creationDate <- ( map["_operation.creationDate"], ISO8601DateTransform() )
        self.enableSuperVisionAndCommit()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.disableSupervisionAndCommit()
		self._ids=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),NSString.self]), forKey: "_ids")! as! [String]
		self._registryUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "_registryUID")! as NSString)
		self._operation.registryUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "_operation.registryUID")! as NSString)
		self._operation.creatorUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "_operation.creatorUID")! as NSString)
		self._operation.status=Operation.Status(rawValue:String(decoder.decodeObjectOfClass(NSString.self, forKey: "_operation.status")! as NSString))! 
		self._operation.counter=decoder.decodeIntegerForKey("_operation.counter") 
		self._operation.creationDate=decoder.decodeObjectOfClass(NSDate.self, forKey:"_operation.creationDate") as NSDate?

        self.enableSuperVisionAndCommit()
    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		coder.encodeObject(self._ids,forKey:"_ids")
		coder.encodeObject(self._registryUID,forKey:"_registryUID")
		coder.encodeObject(self._operation.registryUID,forKey:"_operation.registryUID")
		coder.encodeObject(self._operation.creatorUID,forKey:"_operation.creatorUID")
		coder.encodeObject(self._operation.status.rawValue ,forKey:"_operation.status")
		coder.encodeInteger(self._operation.counter,forKey:"_operation.counter")
		if let _operation_creationDate = self._operation.creationDate {
			coder.encodeObject(_operation_creationDate,forKey:"_operation.creationDate")
		}
    }


    override public class func supportsSecureCoding() -> Bool{
        return true
    }



    /**
    This is the designated constructor.

    - parameter ids: the ids concerned the operation
    - parameter registryUID the registry or document UID

    */
    init (_ ids:[String]=[String](), fromRegistryWithUID registryUID:String) {
        self._ids=ids
        self._registryUID=registryUID
        super.init()
    }

    /**
    Creates the operation and proceeds to commit

    - parameter ids: the instance
    - parameter registryUID:     the registry or document UID
    */
    static func commit(ids:[String], fromRegistryWithUID registryUID:String){
        let operationInstance=DeletePermissions(ids,fromRegistryWithUID:registryUID)
        operationInstance.commit()
    }


    func commit(){
        let context=Context(code:3009826632, caller: "DeletePermissions.commit")
        if let document = Bartleby.sharedInstance.getDocumentByUID(self._registryUID) {
                // Do not track changes
                self._operation.disableSupervision()
                // Prepare the operation serialization
                self.defineUID()
                self._operation.defineUID()
                self._operation.counter=0
                self._operation.status=Operation.Status.Pending
                self._operation.creationDate=NSDate()
                self._operation.registryUID=self._registryUID
                let stringIDS=PString.ltrim(self._ids.reduce("", combine: { $0+","+$1 }),characters:",")
                self._operation.summary="DeletePermissions(\(stringIDS))"

                if let currentUser=document.registryMetadata.currentUser{
                    self._operation.creatorUID=currentUser.UID
                    self.creatorUID=currentUser.UID
                }

                // Provision the operation.
                do{
                    let ic:OperationsCollectionController = try document.getCollection()
                    ic.add(self._operation, commit:false)
                }catch{
                    Bartleby.sharedInstance.dispatchAdaptiveMessage(context,
                    title: "Structural Error",
                    body: "Operation collection is missing in DeletePermissions",
                    onSelectedIndex: { (selectedIndex) -> () in
                    })
                }
                self._operation.toDictionary=self.dictionaryRepresentation()
                }else{
            // This document is not available there is nothing to do.
            let m=NSLocalizedString("Registry is missing", comment: "Registry is missing")
            Bartleby.sharedInstance.dispatchAdaptiveMessage(context,
                    title: NSLocalizedString("Structural error", comment: "Structural error"),
                    body: "\(m) registryUID =\(self._registryUID) in DeletePermissions",
                    onSelectedIndex: { (selectedIndex) -> () in
                    }
            )
        }
    }

    public func push(sucessHandler success:(context:JHTTPResponse)->(),
        failureHandler failure:(context:JHTTPResponse)->()){
        if let _ = Bartleby.sharedInstance.getDocumentByUID(self._registryUID) {
            // The unitary operation are not always idempotent
            // so we do not want to push multiple times unintensionnaly.
            // Check BartlebyDocument+Operations.swift to understand Operation status
            if  self._operation.canBePushed(){
                // We try to execute
                self._operation.status=Operation.Status.InProgress
                DeletePermissions.execute(self._ids,
                    fromRegistryWithUID:self._registryUID,
                    sucessHandler: { (context: JHTTPResponse) -> () in
                                                self._operation.counter=self._operation.counter+1
                        self._operation.status=Operation.Status.Completed
                        self._operation.responseDictionary=Mapper<JHTTPResponse>().toJSON(context)
                        self._operation.lastInvocationDate=NSDate()
                        let completion=Completion.successStateFromJHTTPResponse(context)
                        completion.setResult(context)
                        self._operation.completionState=completion
                        success(context:context)
                    },
                    failureHandler: {(context: JHTTPResponse) -> () in
                        self._operation.counter=self._operation.counter+1
                        self._operation.status=Operation.Status.Completed
                        self._operation.responseDictionary=Mapper<JHTTPResponse>().toJSON(context)
                        self._operation.lastInvocationDate=NSDate()
                        let completion=Completion.failureStateFromJHTTPResponse(context)
                        completion.setResult(context)
                        self._operation.completionState=completion
                        failure(context:context)
                    }
                )
            }else{
                // This document is not available there is nothing to do.
                let context=Context(code:2813590401, caller: "DeletePermissions.push")
                Bartleby.sharedInstance.dispatchAdaptiveMessage(context,
                    title: NSLocalizedString("Push error", comment: "Push error"),
                    body: "\(NSLocalizedString("Attempt to push an operation with status ==\(self._operation.status))",comment:"Attempt to push an operation with status =="))\(self._operation.status))",
                    onSelectedIndex: { (selectedIndex) -> () in
                })
            }
        }
    }

    static public func execute(ids:[String],
            fromRegistryWithUID registryUID:String,
            sucessHandler success:(context:JHTTPResponse)->(),
            failureHandler failure:(context:JHTTPResponse)->()){
            if let document = Bartleby.sharedInstance.getDocumentByUID(registryUID) {
                let pathURL = document.baseURL.URLByAppendingPathComponent("permissions")
                var parameters=Dictionary<String, AnyObject>()
                parameters["ids"]=ids
                let urlRequest=HTTPManager.mutableRequestWithToken(inRegistryWithUID:document.UID,withActionName:"DeletePermissions" ,forMethod:"DELETE", and: pathURL)
                let r:Request=request(ParameterEncoding.JSON.encode(urlRequest, parameters: parameters).0)
                r.responseJSON{ response in

                    // Store the response
                    let request=response.request
                    let result=response.result
                    let response=response.response

                    // Bartleby consignation
                    let context = JHTTPResponse( code: 805221448,
                        caller: "DeletePermissions.execute",
                        relatedURL:request?.URL,
                        httpStatusCode: response?.statusCode ?? 0,
                        response: response,
                        result:result.value)

                    // React according to the situation
                    var reactions = Array<Bartleby.Reaction> ()
                    reactions.append(Bartleby.Reaction.Track(result: result.value, context: context)) // Tracking

                    if result.isFailure {
                        let m = NSLocalizedString("deleteByIds  of permissions",
                            comment: "deleteByIds of permissions failure description")
                        let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
                            context: context,
                            title: NSLocalizedString("Unsuccessfull attempt result.isFailure is true",
                            comment: "Unsuccessfull attempt"),
                            body:"\(m) \n \(response)" ,
                            transmit:{ (selectedIndex) -> () in
                        })
                        reactions.append(failureReaction)
                        failure(context:context)
                    }else{
                        if let statusCode=response?.statusCode {
                            if 200...299 ~= statusCode {
                                // Acknowledge the trigger and log QA issue
                                if let dictionary = result.value as? Dictionary< String,AnyObject > {
                                    if let index=dictionary["triggerIndex"] as? NSNumber{
                                        document.acknowledgeOwnedTriggerIndex(index.integerValue)
                                    }else{
                                        bprint("QA Trigger index is missing \(context)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger))
                                    }
                                }else{
                                    bprint("QA Trigger index dictionary is missing \(context)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger))
                                }
                                success(context:context)
                            }else{
                                // Bartlby does not currenlty discriminate status codes 100 & 101
                                // and treats any status code >= 300 the same way
                                // because we consider that failures differentiations could be done by the caller.

                                let m=NSLocalizedString("deleteByIds of permissions",
                                        comment: "deleteByIds of permissions failure description")
                                let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
                                    context: context,
                                    title: NSLocalizedString("Unsuccessfull attempt",
                                    comment: "Unsuccessfull attempt"),
                                    body: "\(m) \n \(response)",
                                    transmit:{ (selectedIndex) -> () in
                                    })
                                reactions.append(failureReaction)
                                failure(context:context)
                            }
                        }
                     }
                    //Let's react according to the context.
                    Bartleby.sharedInstance.perform(reactions, forContext: context)
                }
            }else{
                let context = JHTTPResponse( code:1 ,
                    caller: "DeletePermissions.execute",
                    relatedURL:NSURL(),
                    httpStatusCode:417,
                    response:nil,
                    result:"{\"message\":\"Unexisting document with registryUID \(registryUID)\"}")
                    failure(context:context)
            }
        }
}
