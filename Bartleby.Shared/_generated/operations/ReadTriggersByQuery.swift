//
//  ReadTriggersByQuery.swift
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
@objc(ReadTriggersByQueryParameters) public class ReadTriggersByQueryParameters : JObject {
	
	// Universal type support
	override public class func typeName() -> String {
		 return "ReadTriggersByQueryParameters"
	}
	// 
	public var result_fields:[String]?
	// the sort (MONGO DB)
	public var sort:[String:AnyObject]?
	// the query (MONGO DB)
	public var query:[String:AnyObject]?

    required public init(){
        super.init()
    }


    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
        self.lockAutoCommitObserver()
		self.result_fields <- ( map["result_fields"] )
		self.sort <- ( map["sort"] )
		self.query <- ( map["query"] )
        self.unlockAutoCommitObserver()
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.lockAutoCommitObserver()
		self.result_fields=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),NSString.self]), forKey: "result_fields") as? [String]
		self.sort=decoder.decodeObjectOfClasses(NSSet(array: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()]), forKey: "sort")as? [String:AnyObject]
		self.query=decoder.decodeObjectOfClasses(NSSet(array: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()]), forKey: "query")as? [String:AnyObject]
        self.unlockAutoCommitObserver()
    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		if let result_fields = self.result_fields {
			coder.encodeObject(result_fields,forKey:"result_fields")
		}
		if let sort = self.sort {
			coder.encodeObject(sort,forKey:"sort")
		}
		if let query = self.query {
			coder.encodeObject(query,forKey:"query")
		}
    }


    override public class func supportsSecureCoding() -> Bool{
        return true
    }

}



@objc(ReadTriggersByQuery) public class ReadTriggersByQuery : JObject{

    // Universal type support
    override public class func typeName() -> String {
           return "ReadTriggersByQuery"
    }


    public static func execute(fromDataSpace spaceUID:String,
						parameters:ReadTriggersByQueryParameters,
						sucessHandler success:(triggers:[Trigger])->(),
						failureHandler failure:(context:JHTTPResponse)->()){
	
				    let baseURL=Bartleby.sharedInstance.getCollaborationURLForSpaceUID(spaceUID)
				    let pathURL=baseURL.URLByAppendingPathComponent("triggersByQuery")
				    let dictionary:Dictionary<String, AnyObject>?=Mapper().toJSON(parameters)
				    let urlRequest=HTTPManager.mutableRequestWithToken(inDataSpace:spaceUID,withActionName:"ReadTriggersByQuery" ,forMethod:"POST", and: pathURL)
				    let r:Request=request(ParameterEncoding.JSON.encode(urlRequest, parameters: dictionary).0)
				    r.responseJSON{ response in
					    let request=response.request
				        let result=response.result
				        let response=response.response
				        // Bartleby consignation
				        let context = JHTTPResponse( code: 1592798154,
				            caller: "ReadTriggersByQuery.execute",
				            relatedURL:request?.URL,
				            httpStatusCode: response?.statusCode ?? 0,
				            response: response,
				            result:result.value)
				        // React according to the situation
				        var reactions = Array<Bartleby.Reaction> ()
				        reactions.append(Bartleby.Reaction.Track(result: result.value, context: context)) // Tracking
				        if result.isFailure {
				           let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
				                context: context,
				                title: NSLocalizedString("Unsuccessfull attempt",comment: "Unsuccessfull attempt"),
				                body:NSLocalizedString("Explicit Failure",comment: "Explicit Failure"),
				                trigger:{ (selectedIndex) -> () in
				            })
				            reactions.append(failureReaction)
				            failure(context:context)
				        }else{
				            if let statusCode=response?.statusCode {
				                if 200...299 ~= statusCode {
									if let instance = Mapper <Trigger>().mapArray(result.value){					    
									    success(triggers: instance)
									  }else{
									   let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
									        context: context,
									        title: NSLocalizedString("Deserialization issue",
									            comment: "Deserialization issue"),
									        body:"(result.value)",
									        trigger:{ (selectedIndex) -> () in
									    })
									   reactions.append(failureReaction)
									   failure(context:context)
									}
				            }else{
				                // Bartlby does not currenlty discriminate status codes 100 & 101
				                // and treats any status code >= 300 the same way
				                // because we consider that failures differentiations could be done by the caller.
				                let failureReaction =  Bartleby.Reaction.DispatchAdaptiveMessage(
				                    context: context,
				                    title: NSLocalizedString("Unsuccessfull attempt",comment: "Unsuccessfull attempt"),
				                    body:NSLocalizedString("Implicit Failure",comment: "Implicit Failure"),
				                    trigger:{ (selectedIndex) -> () in
				                })
				               reactions.append(failureReaction)
				               failure(context:context)
				            }
				        }
				     }
				     //Let s react according to the context.
				     Bartleby.sharedInstance.perform(reactions, forContext: context)
				  }
				}

}
