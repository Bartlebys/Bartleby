//
//  CreatePermissions.swift
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

@objc(CreatePermissions) public class CreatePermissions : JObject,JHTTPCommand{

    // Universal type support
    override public class func typeName() -> String {
        return "CreatePermissions"
    }

    private var _permissions:[Permission] = [Permission]()

    private var _registryUID:String=Default.NO_UID

    required public convenience init(){
        self.init([Permission](), inRegistryWithUID:Default.NO_UID)
    }





    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
        self.disableSupervisionAndCommit()
		self._permissions <- ( map["_permissions"] )
		self._registryUID <- ( map["_registryUID"] )
        self.enableSuperVisionAndCommit()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.disableSupervisionAndCommit()
		self._permissions=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),Permission.classForCoder()]), forKey: "_permissions")! as! [Permission]
		self._registryUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "_registryUID")! as NSString)

        self.enableSuperVisionAndCommit()
    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		coder.encodeObject(self._permissions,forKey:"_permissions")
		coder.encodeObject(self._registryUID,forKey:"_registryUID")
    }


    override public class func supportsSecureCoding() -> Bool{
        return true
    }



    /**
    This is the designated constructor.

    - parameter permissions: the permissions concerned the operation
    - parameter registryUID the registry or document UID

    */
    init (_ permissions:[Permission]=[Permission](), inRegistryWithUID registryUID:String) {
        self._permissions=permissions
        self._registryUID=registryUID
        super.init()
    }

    /**
     Returns an operation with self.UID as commandUID

     - returns: return the operation
     */
    private func _getOperation()->Operation{
        if let document = Bartleby.sharedInstance.getDocumentByUID(self._registryUID) {
            if let ic:OperationsCollectionController = try? document.getCollection(){
                let operations=ic.filter({ (operation) -> Bool in
                    return operation.commandUID==self.UID
                })
                if let operation=operations.first {
                    return operation
                }}
        }
        let operation=Operation()
        operation.disableSupervision()
        operation.commandUID=self.UID
        operation.defineUID()
        return operation
    }


    /**
    Creates the operation and proceeds to commit

    - parameter permissions: the instance
    - parameter registryUID:     the registry or document UID
    */
    static func commit(permissions:[Permission], inRegistryWithUID registryUID:String){
        let operationInstance=CreatePermissions(permissions,inRegistryWithUID:registryUID)
        operationInstance.commit()
    }


    func commit(){
        let context=Context(code:1227301030, caller: "CreatePermissions.commit")
        if let document = Bartleby.sharedInstance.getDocumentByUID(self._registryUID) {
            // Provision the operation.
            do{
                let ic:OperationsCollectionController = try document.getCollection()
                let operation=self._getOperation()
                operation.counter += 1
                operation.status=Operation.Status.Pending
                operation.creationDate=NSDate()
                let stringIDS=PString.ltrim(self._permissions.reduce("", combine: { $0+","+$1.UID }),characters:",")
                operation.summary="CreatePermissions(\(stringIDS))"
                if let currentUser=document.registryMetadata.currentUser{
                    operation.creatorUID=currentUser.UID
                    self.creatorUID=currentUser.UID
                }
                for item in self._permissions{
                    item.committed=true
                }
                operation.toDictionary=self.dictionaryRepresentation()
                operation.enableSupervision()
                ic.add(operation, commit:false)
            }catch{
                Bartleby.sharedInstance.dispatchAdaptiveMessage(context,
                    title: "Structural Error",
                    body: "Operation collection is missing in  CreatePermissions",
                    onSelectedIndex: { (selectedIndex) -> () in
                })
            }
        }else{
            // This document is not available there is nothing to do.
            let m=NSLocalizedString("Registry is missing", comment: "Registry is missing")
            Bartleby.sharedInstance.dispatchAdaptiveMessage(context,
                    title: NSLocalizedString("Structural error", comment: "Structural error"),
                    body: "\(m) registryUID =\(self._registryUID) in CreatePermissions",
                    onSelectedIndex: { (selectedIndex) -> () in
                    }
            )
        }
    }

    public func push(sucessHandler success:(context:JHTTPResponse)->(),
        failureHandler failure:(context:JHTTPResponse)->()){
        // The unitary operation are not always idempotent
        // so we do not want to push multiple times unintensionnaly.
        // Check BartlebyDocument+Operations.swift to understand Operation status
        let operation=self._getOperation()
        if  operation.canBePushed(){
            // We try to execute
            operation.status=Operation.Status.InProgress
            CreatePermissions.execute(self._permissions,
                inRegistryWithUID:self._registryUID,
                sucessHandler: { (context: JHTTPResponse) -> () in
                    for item in self._permissions{
                        item.distributed=true
                    }
                    operation.counter=operation.counter+1
                    operation.status=Operation.Status.Completed
                    operation.responseDictionary=Mapper<JHTTPResponse>().toJSON(context)
                    operation.lastInvocationDate=NSDate()
                    let completion=Completion.successStateFromJHTTPResponse(context)
                    completion.setResult(context)
                    operation.completionState=completion
                    success(context:context)
                },
                failureHandler: {(context: JHTTPResponse) -> () in
                    operation.counter=operation.counter+1
                    operation.status=Operation.Status.Completed
                    operation.responseDictionary=Mapper<JHTTPResponse>().toJSON(context)
                    operation.lastInvocationDate=NSDate()
                    let completion=Completion.failureStateFromJHTTPResponse(context)
                    completion.setResult(context)
                    operation.completionState=completion
                    failure(context:context)
                }
            )
        }else{
            // This document is not available there is nothing to do.
            let context=Context(code:4055740771, caller: "CreatePermissions.push")
            Bartleby.sharedInstance.dispatchAdaptiveMessage(context,
                title: NSLocalizedString("Push error", comment: "Push error"),
                body: "\(NSLocalizedString("Attempt to push an operation with status \"",comment:"Attempt to push an operation with status =="))\(operation.status)\"",
                onSelectedIndex: { (selectedIndex) -> () in
            })
        }
    }

    static public func execute(permissions:[Permission],
            inRegistryWithUID registryUID:String,
            sucessHandler success:(context:JHTTPResponse)->(),
            failureHandler failure:(context:JHTTPResponse)->()){
            if let document = Bartleby.sharedInstance.getDocumentByUID(registryUID) {
                let pathURL = document.baseURL.URLByAppendingPathComponent("permissions")
                var parameters=Dictionary<String, AnyObject>()
                var collection=[Dictionary<String, AnyObject>]()

                for permission in permissions{
                    let serializedInstance=Mapper<Permission>().toJSON(permission)
                    collection.append(serializedInstance)
                }
                parameters["permissions"]=collection
                let urlRequest=HTTPManager.mutableRequestWithToken(inRegistryWithUID:document.UID,withActionName:"CreatePermissions" ,forMethod:"POST", and: pathURL)
                let r:Request=request(ParameterEncoding.JSON.encode(urlRequest, parameters: parameters).0)
                r.responseJSON{ response in

                    // Store the response
                    let request=response.request
                    let result=response.result
                    let response=response.response

                    // Bartleby consignation
                    let context = JHTTPResponse( code: 1756772952,
                        caller: "CreatePermissions.execute",
                        relatedURL:request?.URL,
                        httpStatusCode: response?.statusCode ?? 0,
                        response: response,
                        result:result.value)

                    // React according to the situation
                    var reactions = Array<Bartleby.Reaction> ()
                    reactions.append(Bartleby.Reaction.Track(result: result.value, context: context)) // Tracking

                    if result.isFailure {
                        let m = NSLocalizedString("creation  of permissions",
                            comment: "creation of permissions failure description")
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

                                let m=NSLocalizedString("creation of permissions",
                                        comment: "creation of permissions failure description")
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
                    caller: "CreatePermissions.execute",
                    relatedURL:NSURL(),
                    httpStatusCode:417,
                    response:nil,
                    result:"{\"message\":\"Unexisting document with registryUID \(registryUID)\"}")
                    failure(context:context)
            }
        }
}
