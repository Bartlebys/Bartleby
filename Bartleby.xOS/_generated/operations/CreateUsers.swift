//
//  CreateUsers.swift
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

@objc(CreateUsers) public class CreateUsers : JObject,JHTTPCommand{

    // Universal type support
    override public class func typeName() -> String {
        return "CreateUsers"
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

    override public func mapping(map: Map) {
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
		self._users=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),User.classForCoder()]), forKey: "_users")! as! [User]
		self._registryUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "_registryUID")! as NSString)

        self.enableSuperVisionAndCommit()
    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		coder.encodeObject(self._users,forKey:"_users")
		coder.encodeObject(self._registryUID,forKey:"_registryUID")
    }


    override public class func supportsSecureCoding() -> Bool{
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

    - parameter users: the instance
    - parameter registryUID:     the registry or document UID
    */
    static func commit(users:[User], inRegistryWithUID registryUID:String){
        let operationInstance=CreateUsers(users,inRegistryWithUID:registryUID)
        operationInstance.commit()
    }


    func commit(){
        let context=Context(code:3079848263, caller: "CreateUsers.commit")
        if let document = Bartleby.sharedInstance.getDocumentByUID(self._registryUID) {
            // Provision the operation.
            do{
                let ic:OperationsCollectionController = try document.getCollection()
                let operation=self._getOperation()
                operation.counter += 1
                operation.status=Operation.Status.Pending
                operation.creationDate=NSDate()
                let stringIDS=PString.ltrim(self._users.reduce("", combine: { $0+","+$1.UID }),characters:",")
                operation.summary="CreateUsers(\(stringIDS))"
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
                    body: "Operation collection is missing in  CreateUsers",
                    onSelectedIndex: { (selectedIndex) -> () in
                })
            }
        }else{
            // This document is not available there is nothing to do.
            let m=NSLocalizedString("Registry is missing", comment: "Registry is missing")
            Bartleby.sharedInstance.dispatchAdaptiveMessage(context,
                    title: NSLocalizedString("Structural error", comment: "Structural error"),
                    body: "\(m) registryUID =\(self._registryUID) in CreateUsers",
                    onSelectedIndex: { (selectedIndex) -> () in
                    }
            )
        }
    }

    public func push(sucessHandler success:(context:JHTTPResponse)->(),
        failureHandler failure:(context:JHTTPResponse)->()){
        if let document = Bartleby.sharedInstance.getDocumentByUID(self._registryUID) {
            // The unitary operation are not always idempotent
            // so we do not want to push multiple times unintensionnaly.
            // Check BartlebyDocument+Operations.swift to understand Operation status
            let operation=self._getOperation()
            if  operation.canBePushed(){
                // We try to execute
                operation.status=Operation.Status.InProgress
                CreateUsers.execute(self._users,
                    inRegistryWithUID:self._registryUID,
                    sucessHandler: { (context: JHTTPResponse) -> () in
                        document.markAsDistributed(&self._users)
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
                let context=Context(code:1624636093, caller: "CreateUsers.push")
                Bartleby.sharedInstance.dispatchAdaptiveMessage(context,
                    title: NSLocalizedString("Push error", comment: "Push error"),
                    body: "\(NSLocalizedString("Attempt to push an operation with status \"",comment:"Attempt to push an operation with status =="))\(operation.status)\"",
                    onSelectedIndex: { (selectedIndex) -> () in
                })
            }
        }
    }

    static public func execute(users:[User],
            inRegistryWithUID registryUID:String,
            sucessHandler success:(context:JHTTPResponse)->(),
            failureHandler failure:(context:JHTTPResponse)->()){
            if let document = Bartleby.sharedInstance.getDocumentByUID(registryUID) {
                let pathURL = document.baseURL.URLByAppendingPathComponent("users")
                var parameters=Dictionary<String, AnyObject>()
                var collection=[Dictionary<String, AnyObject>]()

                for user in users{
                    let serializedInstance=Mapper<User>().toJSON(user)
                    collection.append(serializedInstance)
                }
                parameters["users"]=collection
                let urlRequest=HTTPManager.mutableRequestWithToken(inRegistryWithUID:document.UID,withActionName:"CreateUsers" ,forMethod:"POST", and: pathURL)
                let r:Request=request(ParameterEncoding.JSON.encode(urlRequest, parameters: parameters).0)
                r.responseJSON{ response in

                    // Store the response
                    let request=response.request
                    let result=response.result
                    let response=response.response

                    // Bartleby consignation
                    let context = JHTTPResponse( code: 3208994135,
                        caller: "CreateUsers.execute",
                        relatedURL:request?.URL,
                        httpStatusCode: response?.statusCode ?? 0,
                        response: response,
                        result:result.value)

                    // React according to the situation
                    var reactions = Array<Bartleby.Reaction> ()
                    reactions.append(Bartleby.Reaction.Track(result: result.value, context: context)) // Tracking

                    if result.isFailure {
                        let m = NSLocalizedString("creation  of users",
                            comment: "creation of users failure description")
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

                                let m=NSLocalizedString("creation of users",
                                        comment: "creation of users failure description")
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
                    caller: "CreateUsers.execute",
                    relatedURL:NSURL(),
                    httpStatusCode:417,
                    response:nil,
                    result:"{\"message\":\"Unexisting document with registryUID \(registryUID)\"}")
                    failure(context:context)
            }
        }
}
