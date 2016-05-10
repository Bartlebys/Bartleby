//
//  ReadLockerById.swift
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



public class ReadLockerById : JObject{

    // Universal type support
    override public class func typeName() -> String {
           return "ReadLockerById"
    }


    public static func execute(fromDataSpace spaceUID:String,
						lockerId:String,
						sucessHandler success:(locker:Locker)->(),
						failureHandler failure:(context:JHTTPResponse)->()){
	
				    let baseURL=Bartleby.sharedInstance.getCollaborationURLForSpaceUID(spaceUID)
				    let pathURL=baseURL.URLByAppendingPathComponent("locker/\(lockerId)")
				    let dictionary:Dictionary<String, AnyObject>=[:]
				    let urlRequest=HTTPManager.mutableRequestWithToken(inDataSpace:spaceUID,withActionName:"ReadLockerById" ,forMethod:"GET", and: pathURL)
				    let r:Request=request(ParameterEncoding.URL.encode(urlRequest, parameters: dictionary).0)
				    r.responseJSON{ response in
					    let request=response.request
				        let result=response.result
				        let response=response.response
				        // Bartleby consignation
				        let context = JHTTPResponse( code: 1560507225,
				            caller: "ReadLockerById.execute",
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
									if let instance = Mapper <Locker>().map(result.value){					    
									    success(locker: instance)
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
