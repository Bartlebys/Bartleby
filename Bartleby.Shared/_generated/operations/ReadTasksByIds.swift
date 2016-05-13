//
//  ReadTasksByIds.swift
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
@objc(ReadTasksByIdsParameters) public class ReadTasksByIdsParameters : JObject {
	
	// Universal type support
	override public class func typeName() -> String {
		 return "ReadTasksByIdsParameters"
	}
	// 
	public var ids:[String]?
	// 
	public var result_fields:[String]?
	// the sort (MONGO DB)
	public var sort:Dictionary<String, AnyObject>?

    required public init(){
        super.init()
    }


    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override public func mapping(map: Map) {
        super.mapping(map)
		self.ids <- map["ids"]
		self.result_fields <- map["result_fields"]
		self.sort <- map["sort"]
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
		self.ids=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),NSString.self]), forKey: "ids") as? [String]
		self.result_fields=decoder.decodeObjectOfClasses(NSSet(array: [NSArray.classForCoder(),NSString.self]), forKey: "result_fields") as? [String]
		self.sort=decoder.decodeObjectOfClasses(NSSet(array: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()]), forKey: "sort")as? Dictionary<String, AnyObject>

    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
		if let ids = self.ids {
			coder.encodeObject(ids,forKey:"ids")
		}
		if let result_fields = self.result_fields {
			coder.encodeObject(result_fields,forKey:"result_fields")
		}
		if let sort = self.sort {
			coder.encodeObject(sort,forKey:"sort")
		}
    }


    override public class func supportsSecureCoding() -> Bool{
        return true
    }

}



@objc(ReadTasksByIds) public class ReadTasksByIds : JObject{

    // Universal type support
    override public class func typeName() -> String {
           return "ReadTasksByIds"
    }


    public static func execute(fromDataSpace spaceUID:String,
						parameters:ReadTasksByIdsParameters,
						sucessHandler success:(tasks:[Task])->(),
						failureHandler failure:(context:JHTTPResponse)->()){
	
				    let baseURL=Bartleby.sharedInstance.getCollaborationURLForSpaceUID(spaceUID)
				    let pathURL=baseURL.URLByAppendingPathComponent("tasks")
				    let dictionary:Dictionary<String, AnyObject>?=Mapper().toJSON(parameters)
				    let urlRequest=HTTPManager.mutableRequestWithToken(inDataSpace:spaceUID,withActionName:"ReadTasksByIds" ,forMethod:"GET", and: pathURL)
				    let r:Request=request(ParameterEncoding.URL.encode(urlRequest, parameters: dictionary).0)
				    r.responseJSON{ response in
					    let request=response.request
				        let result=response.result
				        let response=response.response
				        // Bartleby consignation
				        let context = JHTTPResponse( code: 152388836,
				            caller: "ReadTasksByIds.execute",
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
									if let instance = Mapper <Task>().mapArray(result.value){					    
									    success(tasks: instance)
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
