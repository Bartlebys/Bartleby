
//
//  ReadLockerById.swift
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

@objc(ReadLockerById) open class ReadLockerById : BartlebyObject{

    // Universal type support
    override open class func typeName() -> String {
           return "ReadLockerById"
    }


    public static func execute(from documentUID:String,
						lockerId:String,
						sucessHandler success:@escaping(_ locker:Locker)->(),
						failureHandler failure:@escaping(_ context:HTTPContext)->()){
	
        if let document = Bartleby.sharedInstance.getDocumentByUID(documentUID) {
            let pathURL=document.baseURL.appendingPathComponent("locker/\(lockerId)")
            let dictionary:Dictionary<String, Any>=Dictionary<String, Any>()
            let urlRequest=HTTPManager.requestWithToken(inDocumentWithUID:document.UID,withActionName:"ReadLockerById" ,forMethod:"GET", and: pathURL)
            
            do {
                let r=try URLEncoding().encode(urlRequest,with:dictionary)
                request(r).responseString(completionHandler: { (response) in
                  
                    let request=response.request
                    let result=response.result
                    let timeline=response.timeline
                    let data=response.data
                    let response=response.response
                    
                    let context = HTTPContext( code: 1560507225,
                        caller: "ReadLockerById.execute",
                        relatedURL:request?.url,
                        httpStatusCode: response?.statusCode ?? 0,
                        response: response,
                        result:result.value)

					let metrics=Metrics()
					metrics.httpContext=context
					metrics.operationName="ReadLockerById"
					metrics.latency=timeline.latency
					metrics.requestDuration=timeline.requestDuration
					metrics.serializationDuration=timeline.serializationDuration
					metrics.totalDuration=timeline.totalDuration
					document.report(metrics)

                    // React according to the situation
                    var reactions = Array<Reaction> ()
                    reactions.append(Reaction.track(result: result.value, context: context)) // Tracking
            
                    if result.isFailure {
                       let failureReaction =  Reaction.dispatchAdaptiveMessage(
                            context: context,
                            title: NSLocalizedString("Unsuccessfull attempt",comment: "Unsuccessfull attempt"),
                            body:"\(result.value)\n\(#file)\n\(#function)\nhttp Status code: (\(response?.statusCode ?? 0))",
                            transmit:{ (selectedIndex) -> () in
                        })
                        reactions.append(failureReaction)
                        failure(context)
            
                    }else{
                        if let statusCode=response?.statusCode {
                              if 200...299 ~= statusCode {
	                            if let string=result.value{
	                                if let instance = Mapper <Locker>().map(JSONString:string){
	                                    success(instance)
	                                }else{
	                                    let failureReaction =  Reaction.dispatchAdaptiveMessage(
	                                        context: context,
	                                        title: NSLocalizedString("Deserialization issue",
	                                        comment: "Deserialization issue"),
	                                        body:"\(result.value)\n\(#file)\n\(#function)\nhttp Status code: (\(response?.statusCode ?? 0))",
	                                        transmit:{ (selectedIndex) -> () in
	                                    })
	                                    reactions.append(failureReaction)
	                                    failure(context)
	                                }
	                            }else{
	                                let failureReaction =  Reaction.dispatchAdaptiveMessage(
	                                    context: context,
	                                    title: NSLocalizedString("No String Deserialization issue",
	                                                             comment: "No String Deserialization issue"),
	                                    body: "\(result.value)\n\(#file)\n\(#function)\nhttp Status code: (\(response?.statusCode ?? 0))",
	                                    transmit: { (selectedIndex) -> () in
	                                })
	                                reactions.append(failureReaction)
	                                failure(context)
	                            }
                         }else{
                                // Bartlby does not currenlty discriminate status codes 100 & 101
                                // and treats any status code >= 300 the same way
                                // because we consider that failures differentiations could be done by the caller.
                                let failureReaction =  Reaction.dispatchAdaptiveMessage(
                                    context: context,
                                    title: NSLocalizedString("Unsuccessfull attempt",comment: "Unsuccessfull attempt"),
                                    body:"\(result.value)\n\(#file)\n\(#function)\nhttp Status code: (\(response?.statusCode ?? 0))",
                                    transmit:{ (selectedIndex) -> () in
                                })
                               reactions.append(failureReaction)
                               failure(context)
                            }
                        }
                 }
                 //Let s react according to the context.
                 document.perform(reactions, forContext: context)
            })
        }catch{
                let context = HTTPContext( code:2 ,
                caller: "ReadLockerById.execute",
                relatedURL:nil,
                httpStatusCode:500,
                response:nil,
                result:"{\"message\":\"\(error)}")
                failure(context)
        }
      }else{
         let context = HTTPContext( code: 1,
                caller: "ReadLockerById.execute",
                relatedURL:nil,
                httpStatusCode: 417,
                response: nil,
                result:"{\"message\":\"Unexisting document with documentUID \(documentUID)\"}")
         failure(context)
       }
    }
}
