//
//  CreateUser.swift
//  Bartleby
//
// THIS FILE AS BEEN GENERATED BY BARTLEBYFLEXIONS for benoit@pereira-da-silva.com
// DO NOT MODIFY THIS FILE YOUR MODIFICATIONS WOULD BE ERASED ON NEXT GENERATION!
// WE TRY TO GENERATE ANY REPETITIVE CODE AND TO IMPROVE THE QUALITY ITERATIVELY
//
// Copyright (c) 2015  Chaosmos | https://chaosmos.fr  All rights reserved.
//
import Foundation
#if !USE_EMBEDDED_MODULES
import Alamofire
import ObjectMapper
#endif
@objc(CreateUser) public class CreateUser : BaseObject,JHTTPCommand{

    private var _user:User = User()

    private var _spaceUID:String=Default.NO_UID

    private var _observationUID:String=Default.NOT_OBSERVABLE

    private var _operation:Operation=Operation()

    required public convenience init(){
        self.init(User(), inDataSpace:Default.NO_UID,observableBy:Default.NOT_OBSERVABLE)
    }


    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
        mapping(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
		_user <- map["_user"]
		_spaceUID <- map["_spaceUID"]
		_operation.status <- map["_operation.status"]
		_operation.counter <- map["_operation.counter"]
		_operation.creationDate <- (map["_operation.creationDate"],ISO8601DateTransform())
		_operation.baseUrl <- (map["_operation.baseUrl"],URLTransform())
		_observationUID <- map["_observationUID"]
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
		_user=decoder.decodeObjectOfClass(User.self, forKey: "_user")! 
		_spaceUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "_spaceUID")! as NSString)
		_operation.status=Operation.Status(rawValue:String(decoder.decodeObjectOfClass(NSString.self, forKey: "_operation.status")! as NSString))! 
		_operation.counter=decoder.decodeIntegerForKey("_operation.counter") 
		_operation.creationDate=decoder.decodeObjectOfClass(NSDate.self, forKey:"_operation.creationDate") as NSDate?
		_operation.baseUrl=decoder.decodeObjectOfClass(NSURL.self, forKey:"_operation.baseUrl") as NSURL?
		_observationUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "_observationUID")! as NSString)

    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		coder.encodeObject(_user,forKey:"_user")
		coder.encodeObject(_spaceUID,forKey:"_spaceUID")
		coder.encodeObject(_operation.status.rawValue ,forKey:"_operation.status")
		if let _operation_counter = self._operation.counter {
			coder.encodeInteger(_operation_counter,forKey:"_operation.counter")
		}
		if let _operation_creationDate = self._operation.creationDate {
			coder.encodeObject(_operation_creationDate,forKey:"_operation.creationDate")
		}
		if let _operation_baseUrl = self._operation.baseUrl {
			coder.encodeObject(_operation_baseUrl,forKey:"_operation.baseUrl")
		}
		coder.encodeObject(_observationUID,forKey:"_observationUID")
    }


    override public class func supportsSecureCoding() -> Bool{
        return true
    }



    /**
    This is the designated constructor.

    - parameter user: the user concerned the operation
    - parameter spaceUID the space UID
    - parameter oID: If you want to support distributed execution this action will be propagated to subscribers by this UID

    */
    init (_ user:User=User(), inDataSpace spaceUID:String,observableBy observationUID:String=Default.NOT_OBSERVABLE) {
        self._user=user
        self._spaceUID=spaceUID
        self._observationUID=observationUID
        super.init()
    }

    /**
    Creates the operation and proceeds to commit

    - parameter user: the instance
    - parameter spaceUID:     the space UID
    - parameter oID:     the observable UID
    */
    static func commit(user:User, inDataSpace spaceUID:String,observableBy observationUID:String){
        let operationInstance=CreateUser(user,inDataSpace:spaceUID,observableBy:observationUID)
        operationInstance.commit()
    }


    func commit(){
        let context=Context(code:3114275262, caller: "CreateUser.commit")
        if let registry = Bartleby.sharedInstance.getRegistryByUID(self._spaceUID) {
            //if registry.upsert(self._user){                // Prepare the operation
                self._operation.counter=0
                self._operation.status=Operation.Status.Pending
                self._operation.baseUrl=registry.registryMetadata.collaborationServerURL
                self._operation.creationDate=NSDate()

                // Provision the operation.
                do{
                    let ic:OperationsCollectionController = try registry.getCollection()
                    ic.add(self._operation)
                }catch{
                    Bartleby.sharedInstance.dispatchAdaptiveMessage(context,
                    title: "Structural Error",
                    body: "Operation collection is missing",
                    onSelectedIndex: { (selectedIndex) -> () in
                    })
                }
                // The status will mark Operation.hasChanged as true
                self._operation.data=self.dictionaryRepresentation()
        
                self._user.committed=true
        }else{
            // This registry is not available there is nothing to do.
            let m=NSLocalizedString("Registry is missing", comment: "Registry is missing")
            Bartleby.sharedInstance.dispatchAdaptiveMessage(context,
                    title: NSLocalizedString("Structural error", comment: "Structural error"),
                    body: "\(m) spaceUID=\(self._spaceUID)",
                    onSelectedIndex: { (selectedIndex) -> () in
                    }
            )
        }
    }

    public func push(sucessHandler success:(context:HTTPResponse)->(),
        failureHandler failure:(context:HTTPResponse)->()){
        if let registry = Bartleby.sharedInstance.getRegistryByUID(self._spaceUID) {
            // The unitary operation are not always idempotent
            // so we do not want to push multiple times unintensionnaly.
            if  self._operation.status==Operation.Status.Pending ||
                self._operation.status==Operation.Status.Unsucessful {
                // We try to execute
                self._operation.status=Operation.Status.InProgress
                CreateUser.execute(self._user,
                    inDataSpace:self._spaceUID,
                    sucessHandler: { (context: JHTTPResponse) -> () in
                        registry.markAsDistributed(&self._user)
                        self._operation.counter=self._operation.counter!+1
                        self._operation.status=Operation.Status.Successful
                        self._operation.responseData=Mapper<JHTTPResponse>().toJSON(context)
                        self._operation.lastInvocationDate=NSDate()
                        success(context:context)
                    },
                    failureHandler: {(context: JHTTPResponse) -> () in
                        self._operation.counter=self._operation.counter!+1
                        self._operation.status=Operation.Status.Unsucessful
                        self._operation.responseData=Mapper<JHTTPResponse>().toJSON(context)
                        self._operation.lastInvocationDate=NSDate()
                        failure(context:context)
                    }
                )
            }else{
                // This registry is not available there is nothing to do.
                let context=Context(code:1539033019, caller: "CreateUser.push")
                Bartleby.sharedInstance.dispatchAdaptiveMessage(context,
                    title: NSLocalizedString("Push error", comment: "Push error"),
                    body: "\(NSLocalizedString("Attempt to push an operation with status ==",comment:"Attempt to push an operation with status =="))\(self._operation.status))",
                    onSelectedIndex: { (selectedIndex) -> () in
                })
            }
        }
    }

    static public func execute(user:User,
inDataSpace spaceUID:String,
            sucessHandler success:(context:JHTTPResponse)->(),
            failureHandler failure:(context:JHTTPResponse)->()){
                let baseURL=Bartleby.sharedInstance.getCollaborationURLForSpaceUID(spaceUID)
                let pathURL=baseURL.URLByAppendingPathComponent("/user")
                var parameters=Dictionary<String, AnyObject>()
                parameters["user"]=Mapper<User>().toJSON(user)
                let urlRequest=HTTPManager.mutableRequestWithToken(inDataSpace:spaceUID,withActionName:"CreateUser" ,forMethod:"POST", and: pathURL)
                let r:Request=request(ParameterEncoding.JSON.encode(urlRequest, parameters: parameters).0)
                r.responseString{ response in
                    // Store the response
                    let request=response.request
                    let result=response.result
                    let response=response.response

                    // Bartleby consignation

                    let context = JHTTPResponse( code: 2066359615,
                        caller: "CreateUser.execute",
                        relatedURL:request?.URL,
                        httpStatusCode: response?.statusCode ?? 0,
                        response: response,
                        result:result.value)

                    // React according to the situation
                    var reactions = Array<Bartleby.Reaction> ()
                    reactions.append(Bartleby.Reaction.Track(result: result.value, context: context)) // Tracking

                    if result.isFailure {
                        let m = NSLocalizedString("creation  of user",
                            comment: "creation of user failure description")
                        let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
                            context: context,
                            title: NSLocalizedString("Unsuccessfull attempt result.isFailure is true",
                            comment: "Unsuccessfull attempt"),
                            body:"\(m) \n \(response)" ,
                            trigger:{ (selectedIndex) -> () in
                        })
                        reactions.append(failureReaction)
                        failure(context:context)
                    }else{
                        if let statusCode=response?.statusCode {
                            if 200...299 ~= statusCode {
                                success(context:context)
                            }else{
                                // Bartlby does not currenlty discriminate status codes 100 & 101
                                // and treats any status code >= 300 the same way
                                // because we consider that failures differentiations could be done by the caller.

                                let m=NSLocalizedString("creation of user",
                                        comment: "creation of user failure description")
                                let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
                                    context: context,
                                    title: NSLocalizedString("Unsuccessfull attempt",
                                    comment: "Unsuccessfull attempt"),
                                    body: "\(m) \n \(response)",
                                    trigger:{ (selectedIndex) -> () in
                                    })
                                reactions.append(failureReaction)
                                failure(context:context)
                            }
                        }
                     }
                    //Let's react according to the context.
                    Bartleby.sharedInstance.perform(reactions, forContext: context)
                }
            }
}
