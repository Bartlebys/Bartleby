//
//  UpdateUsers.swift
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

@objc(UpdateUsers) public class UpdateUsers : JObject,JHTTPCommand{

    // Universal type support
    override public class func typeName() -> String {
        return "UpdateUsers"
    }

    private var _users:[User] = [User]()

    private var _registryUID:String=Default.NO_UID

    required public convenience init(){
        self.init([User](), inRegistryWithUID:Default.NO_UID)
    }





    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override public func mapping(_ map: Map) {
        super.mapping(map)
        self.disableSupervisionAndCommit()
		self._users <- ( map["_users"] )
		self._registryUID <- ( map["_registryUID"] )
        self.enableSuperVisionAndCommit()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.disableSupervisionAndCommit()
		self._users=decoder.decodeObject(of: [User.classForCoder()], forKey: "_users")! as! [User]
		self._registryUID=String(describing: decoder.decodeObject(of: NSString.self, forKey: "_registryUID")! as NSString)
        self.disableSupervisionAndCommit()
    }

    override public func encode(with coder: NSCoder) {
        super.encode(with:coder)
		coder.encode(self._users,forKey:"_users")
		coder.encode(self._registryUID,forKey:"_registryUID")
    }

    override public class var supportsSecureCoding:Bool{
        return true
    }



    /**
    This is the designated constructor.

    - parameter users: the users concerned the operation
    - parameter registryUID the registry or document UID

    */
    init (_ users:[User]=[User](), inRegistryWithUID registryUID:String) {
        self._users=users
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
                let operations=ic.items.filter({ (operation) -> Bool in
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

    - parameter users: the instance
    - parameter registryUID:     the registry or document UID
    */
    static func commit(_ users:[User], inRegistryWithUID registryUID:String){
        let operationInstance=UpdateUsers(users,inRegistryWithUID:registryUID)
        operationInstance.commit()
    }


    func commit(){
        let context=Context(code:3977846924, caller: "UpdateUsers.commit")
        if let document = Bartleby.sharedInstance.getDocumentByUID(self._registryUID) {
            // Provision the operation.
            do{
                let ic:OperationsCollectionController = try document.getCollection()
                let operation=self._getOperation()
                operation.counter += 1
                operation.status=Operation.Status.pending
                operation.creationDate=Date()
                let stringIDS=PString.ltrim(self._users.reduce("", { $0+","+$1.UID }),characters:",")
                operation.summary="UpdateUsers(\(stringIDS))"
                if let currentUser=document.registryMetadata.currentUser{
                    operation.creatorUID=currentUser.UID
                    self.creatorUID=currentUser.UID
                }
                for item in self._users{
                    item.committed=true
                }
                operation.toDictionary=self.dictionaryRepresentation()
                operation.enableSupervision()
                ic.add(operation, commit:false)
            }catch{
                Bartleby.sharedInstance.dispatchAdaptiveMessage(context,
                    title: "Structural Error",
                    body: "Operation collection is missing in  UpdateUsers",
                    onSelectedIndex: { (selectedIndex) -> () in
                })
            }
        }else{
            // This document is not available there is nothing to do.
            let m=NSLocalizedString("Registry is missing", comment: "Registry is missing")
            Bartleby.sharedInstance.dispatchAdaptiveMessage(context,
                    title: NSLocalizedString("Structural error", comment: "Structural error"),
                    body: "\(m) registryUID =\(self._registryUID) in UpdateUsers",
                    onSelectedIndex: { (selectedIndex) -> () in
                    }
            )
        }
    }

    public func push(sucessHandler success:@escaping (_ context:JHTTPResponse)->(),
        failureHandler failure:@escaping (_ context:JHTTPResponse)->()){
        // The unitary operation are not always idempotent
        // so we do not want to push multiple times unintensionnaly.
        // Check BartlebyDocument+Operations.swift to understand Operation status
        let operation=self._getOperation()
        if  operation.canBePushed(){
            // We try to execute
            operation.status=Operation.Status.inProgress
            UpdateUsers.execute(self._users,
                inRegistryWithUID:self._registryUID,
                sucessHandler: { (context: JHTTPResponse) -> () in
                    for item in self._users{
                        item.distributed=true
                    }
                    operation.counter=operation.counter+1
                    operation.status=Operation.Status.completed
                    operation.responseDictionary=Mapper<JHTTPResponse>().toJSON(context)
                    operation.lastInvocationDate=Date()
                    let completion=Completion.successStateFromJHTTPResponse(context)
                    completion.setResult(context)
                    operation.completionState=completion
                    success(context)
                },
                failureHandler: {(context: JHTTPResponse) -> () in
                    operation.counter=operation.counter+1
                    operation.status=Operation.Status.completed
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
            let context=Context(code:3773496608, caller: "UpdateUsers.push")
            Bartleby.sharedInstance.dispatchAdaptiveMessage(context,
                title: NSLocalizedString("Push error", comment: "Push error"),
                body: "\(NSLocalizedString("Attempt to push an operation with status \"",comment:"Attempt to push an operation with status =="))\(operation.status)\"",
                onSelectedIndex: { (selectedIndex) -> () in
            })
        }
    }

    static public func execute(_ users:[User],
            inRegistryWithUID registryUID:String,
            sucessHandler success: @escaping(_ context:JHTTPResponse)->(),
            failureHandler failure: @escaping(_ context:JHTTPResponse)->()){
            if let document = Bartleby.sharedInstance.getDocumentByUID(registryUID) {
                let pathURL = document.baseURL.appendingPathComponent("users")
                var parameters=Dictionary<String, Any>()
                var collection=[Dictionary<String, Any>]()

                for user in users{
                    let serializedInstance=Mapper<User>().toJSON(user)
                    collection.append(serializedInstance)
                }
                parameters["users"]=collection
                let urlRequest=HTTPManager.mutableRequestWithToken(inRegistryWithUID:document.UID,withActionName:"UpdateUsers" ,forMethod:"PUT", and: pathURL)
                do {
                    let r=try JSONEncoding().encode(urlRequest,with:parameters) // ??? TO BE VALIDATED
                    request(resource:r).validate().responseJSON(completionHandler: { (response) in

                    // Store the response
                    let request=response.request
                    let result=response.result
                    let response=response.response

                    // Bartleby consignation
                    let context = JHTTPResponse( code: 3014249870,
                        caller: "UpdateUsers.execute",
                        relatedURL:request?.url,
                        httpStatusCode: response?.statusCode ?? 0,
                        response: response,
                        result:result.value)

                    // React according to the situation
                    var reactions = Array<Bartleby.Reaction> ()
                    reactions.append(Bartleby.Reaction.track(result: result.value, context: context)) // Tracking

                    if result.isFailure {
                        let m = NSLocalizedString("update  of users",
                            comment: "update of users failure description")
                        let failureReaction =  Bartleby.Reaction.dispatchAdaptiveMessage(
                            context: context,
                            title: NSLocalizedString("Unsuccessfull attempt result.isFailure is true",
                            comment: "Unsuccessfull attempt"),
                            body:"\(m) \n \(response)" ,
                            transmit:{ (selectedIndex) -> () in
                        })
                        reactions.append(failureReaction)
                        failure(context)
                    }else{
                        if let statusCode=response?.statusCode {
                            if 200...299 ~= statusCode {
                                // Acknowledge the trigger and log QA issue
                                if let dictionary = result.value as? Dictionary< String,AnyObject > {
                                    if let index=dictionary["triggerIndex"] as? NSNumber{
                                        document.acknowledgeOwnedTriggerIndex(index.intValue)
                                    }else{
                                        bprint("QA Trigger index is missing \(context)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger.self))
                                    }
                                }else{
                                    bprint("QA Trigger index dictionary is missing \(context)", file: #file, function: #function, line: #line, category:bprintCategoryFor(Trigger.self))
                                }
                                success(context)
                            }else{
                                // Bartlby does not currenlty discriminate status codes 100 & 101
                                // and treats any status code >= 300 the same way
                                // because we consider that failures differentiations could be done by the caller.

                                let m=NSLocalizedString("update of users",
                                        comment: "update of users failure description")
                                let failureReaction =  Bartleby.Reaction.dispatchAdaptiveMessage(
                                    context: context,
                                    title: NSLocalizedString("Unsuccessfull attempt",
                                    comment: "Unsuccessfull attempt"),
                                    body: "\(m) \n \(response)",
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
                    caller: "UpdateUsers.execute",
                    relatedURL:nil,
                    httpStatusCode:500,
                    response:nil,
                    result:"{\"message\":\"\(error)}")
                    failure(context)
                }

            }else{
                let context = JHTTPResponse( code:1 ,
                    caller: "UpdateUsers.execute",
                    relatedURL:nil,
                    httpStatusCode:417,
                    response:nil,
                    result:"{\"message\":\"Unexisting document with registryUID \(registryUID)\"}")
                    failure(context)
            }
        }
}
