//
//  ReadUserById.swift
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



@objc(ReadUserById) public class ReadUserById : JObject{

    // Universal type support
    override public class func typeName() -> String {
           return "ReadUserById"
    }


    public static func execute(fromRegistryWithUID registryUID:String,
						userId:String,
						sucessHandler success:@escaping(_ user:User)->(),
						failureHandler failure:@escaping(_ context:JHTTPResponse)->()){
	

        if let document = Bartleby.sharedInstance.getDocumentByUID(registryUID) {
            let pathURL=document.baseURL.appendingPathComponent("user/\(userId)")
            let dictionary:Dictionary<String, Any>=[:]
            let urlRequest=HTTPManager.requestWithToken(inRegistryWithUID:document.UID,withActionName:"ReadUserById" ,forMethod:"GET", and: pathURL)
            
            do {
                let r=try JSONEncoding().encode(urlRequest,with:dictionary)
                request(r).validate().responseJSON(completionHandler: { (response) in
                    
                    let request=response.request
                    let result=response.result
                    let response=response.response
            
                    // Bartleby consignation
            
                    let context = JHTTPResponse( code: 2944929622,
                        caller: "ReadUserById.execute",
                        relatedURL:request?.url,
                        httpStatusCode: response?.statusCode ?? 0,
                        response: response,
                        result:result.value)
            
                    // React according to the situation
                    var reactions = Array<Bartleby.Reaction> ()
                    reactions.append(Bartleby.Reaction.track(result: result.value, context: context)) // Tracking
            
                    if result.isFailure {
                       let failureReaction =  Bartleby.Reaction.dispatchAdaptiveMessage(
                            context: context,
                            title: NSLocalizedString("Unsuccessfull attempt",comment: "Unsuccessfull attempt"),
                            body:NSLocalizedString("Explicit Failure",comment: "Explicit Failure"),
                            transmit:{ (selectedIndex) -> () in
                        })
                        reactions.append(failureReaction)
                        failure(context)
            
                    }else{
                        if let statusCode=response?.statusCode {
                            if 200...299 ~= statusCode {
            					if let instance = Mapper <User>().map(result.value){					    
					    success(instance)
					  }else{
					   let failureReaction =  Bartleby.Reaction.dispatchAdaptiveMessage(
					        context: context,
					        title: NSLocalizedString("Deserialization issue",
					            comment: "Deserialization issue"),
					        body:"(result.value)",
					        transmit:{ (selectedIndex) -> () in
					    })
					   reactions.append(failureReaction)
					   failure(context)
					}

                        }else{
                            // Bartlby does not currenlty discriminate status codes 100 & 101
                            // and treats any status code >= 300 the same way
                            // because we consider that failures differentiations could be done by the caller.
                            let failureReaction =  Bartleby.Reaction.dispatchAdaptiveMessage(
                                context: context,
                                title: NSLocalizedString("Unsuccessfull attempt",comment: "Unsuccessfull attempt"),
                                body:NSLocalizedString("Implicit Failure",comment: "Implicit Failure"),
                                transmit:{ (selectedIndex) -> () in
                            })
                           reactions.append(failureReaction)
                           failure(context)
                        }
                    }
                 }
            
                 //Let s react according to the context.
                 Bartleby.sharedInstance.perform(reactions, forContext: context)
            })
        }catch{
                let context = JHTTPResponse( code:2 ,
                caller: "<?php echo$baseClassName ?>.execute",
                relatedURL:nil,
                httpStatusCode:500,
                response:nil,
                result:"{\"message\":\"\(error)}")
                failure(context)
        }
      }else{
         let context = JHTTPResponse( code: 1,
                caller: "ReadUserById.execute",
                relatedURL:nil,
                httpStatusCode: 417,
                response: nil,
                result:"{\"message\":\"Unexisting document with registryUID \(registryUID)\"}")
         failure(context)
       }
    }
}
