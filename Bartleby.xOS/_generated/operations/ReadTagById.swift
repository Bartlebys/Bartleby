
//
//  ReadTagById.swift
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
#endif

@objc(ReadTagById) open class ReadTagById : ManagedModel{

    // Universal type support
    override open class func typeName() -> String {
           return "ReadTagById"
    }


    public static func execute(from documentUID:String,
						tagId:String,
						sucessHandler success:@escaping(_ tag:Tag)->(),
						failureHandler failure:@escaping(_ context:HTTPContext)->()){
	
        if let document = Bartleby.sharedInstance.getDocumentByUID(documentUID) {
            let pathURL=document.baseURL.appendingPathComponent("tag/\(tagId)")
            let dictionary:[String:Any]=[String:Any]()
            let urlRequest=HTTPManager.requestWithToken(inDocumentWithUID:document.UID,withActionName:"ReadTagById" ,forMethod:"GET", and: pathURL)
            
            do {
                let r=try URLEncoding().encode(urlRequest,with:dictionary)
                request(r).responseData(completionHandler: { (response) in
                  
                    let request=response.request
                    let result=response.result
                    let timeline=response.timeline
                    let statusCode=response.response?.statusCode ?? 0
                    
                    let context = HTTPContext( code: 1566247417,
                        caller: "ReadTagById.execute",
                        relatedURL:request?.url,
                        httpStatusCode: statusCode)
                        
                    if let request=request{
                        context.request=HTTPRequest(urlRequest: request)
                    }

                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        context.responseString=utf8Text
                    }

					let metrics=Metrics()
					metrics.httpContext=context
					metrics.operationName="ReadTagById"
					metrics.latency=timeline.latency
					metrics.requestDuration=timeline.requestDuration
					metrics.serializationDuration=timeline.serializationDuration
					metrics.totalDuration=timeline.totalDuration
					document.report(metrics)

                    // React according to the situation
                    var reactions = Array<Reaction> ()
            
                    if result.isFailure {
                       let failureReaction =  Reaction.dispatchAdaptiveMessage(
                            context: context,
                            title: NSLocalizedString("Unsuccessfull attempt",comment: "Unsuccessfull attempt"),
                            body:"\(String(describing: result.value))\n\(#file)\n\(#function)\nhttp Status code: (\(statusCode))",
                            transmit:{ (selectedIndex) -> () in
                        })
                        reactions.append(failureReaction)
                        failure(context)
            
                    }else{
                          if 200...299 ~= statusCode {
	                       do{
	                            if let data = response.data{
	                                let instance = try JSON.decoder.decode(Tag.self,from:data)
	                                success(instance)
	                              }else{
	                                throw BartlebyOperationError.dataNotFound
	                              }
	                            }catch{
	                                let failureReaction =  Reaction.dispatchAdaptiveMessage(
	                                    context: context,
	                                    title:"\(error)",
	                                    body: "\(String(describing: result.value))\n\(#file)\n\(#function)\nhttp Status code: (\(statusCode))",
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
                                body:"\(String(describing: result.value))\n\(#file)\n\(#function)\nhttp Status code: (\(statusCode))",
                                transmit:{ (selectedIndex) -> () in
                            })
                           reactions.append(failureReaction)
                           failure(context)
                        }
                        
                 }
                 //Let s react according to the context.
                 document.perform(reactions, forContext: context)
            })
        }catch{
                let context = HTTPContext( code:2 ,
                caller: "ReadTagById.execute",
                relatedURL:nil,
                httpStatusCode:500)
                failure(context)
        }
      }else{
         let context = HTTPContext( code: 1,
                caller: "ReadTagById.execute",
                relatedURL:nil,
                httpStatusCode: 417)
         failure(context)
       }
    }
}
