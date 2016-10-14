//
//  ReadUsersByQuery.swift
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
@objc(ReadUsersByQueryParameters) public class ReadUsersByQueryParameters : JObject {
	
	// Universal type support
	override open class func typeName() -> String {
		 return "ReadUsersByQueryParameters"
	}
	// 
	public var result_fields:[String]?
	// the sort (MONGO DB)
	public var sort:[String:Any]?
	// the query (MONGO DB)
	public var query:[String:Any]?

    required public init(){
        super.init()
    }

    // MARK: Mappable

    required public init?(map: Map) {
        super.init(map:map)
    }

    override open func mapping(map: Map) {
        super.mapping(map: map)
        self.silentGroupedChanges {
			self.result_fields <- ( map["result_fields"] )
			self.sort <- ( map["sort"] )
			self.query <- ( map["query"] )
        }
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self.result_fields=decoder.decodeObject(of: [NSArray.classForCoder(),NSString.self], forKey: "result_fields") as? [String]
			self.sort=decoder.decodeObject(of: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()], forKey: "sort")as? [String:Any]
			self.query=decoder.decodeObject(of: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()], forKey: "query")as? [String:Any]
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		if let result_fields = self.result_fields {
			coder.encode(result_fields,forKey:"result_fields")
		}
		if let sort = self.sort {
			coder.encode(sort,forKey:"sort")
		}
		if let query = self.query {
			coder.encode(query,forKey:"query")
		}
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }

}



@objc(ReadUsersByQuery) open class ReadUsersByQuery : JObject{

    // Universal type support
    override open class func typeName() -> String {
           return "ReadUsersByQuery"
    }


    public static func execute(fromRegistryWithUID registryUID:String,
						parameters:ReadUsersByQueryParameters,
						sucessHandler success:@escaping(_ users:[User])->(),
						failureHandler failure:@escaping(_ context:JHTTPResponse)->()){
	

        if let document = Bartleby.sharedInstance.getDocumentByUID(registryUID) {
            let pathURL=document.baseURL.appendingPathComponent("usersByQuery")
            let dictionary:Dictionary<String, Any>?=Mapper().toJSON(parameters)
            let urlRequest=HTTPManager.requestWithToken(inRegistryWithUID:document.UID,withActionName:"ReadUsersByQuery" ,forMethod:"GET", and: pathURL)
            
            do {
                let r=try URLEncoding().encode(urlRequest,with:dictionary)
                request(r).responseString(completionHandler: { (response) in
                  
                    let request=response.request
                    let result=response.result
                    let response=response.response
            
                    // Bartleby consignation
            
                    let context = JHTTPResponse( code: 3654843900,
                        caller: "ReadUsersByQuery.execute",
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
                            body:NSLocalizedString("Explicit Failure in ",comment: "Explicit Failure in ") + "\n\(#file)\n\(#function)\nhttp Status code: (\(response?.statusCode ?? 0))",
                            transmit:{ (selectedIndex) -> () in
                        })
                        reactions.append(failureReaction)
                        failure(context)
            
                    }else{
                        if let statusCode=response?.statusCode {
                              if 200...299 ~= statusCode {
	                            if let string=result.value{
	                                if let instance = Mapper <User>().mapArray(JSONString:string){
	                                    success(instance)
	                                }else{
	                                    let failureReaction =  Bartleby.Reaction.dispatchAdaptiveMessage(
	                                        context: context,
	                                        title: NSLocalizedString("Deserialization issue",
	                                        comment: "Deserialization issue"),
	                                        body:"(result.value)" + "\n\(#file)\n\(#function)\nhttp Status code: (\(response?.statusCode ?? 0))",
	                                        transmit:{ (selectedIndex) -> () in
	                                    })
	                                    reactions.append(failureReaction)
	                                    failure(context)
	                                }
	                            }else{
	                                let failureReaction =  Bartleby.Reaction.dispatchAdaptiveMessage(
	                                    context: context,
	                                    title: NSLocalizedString("No String Deserialization issue",
	                                                             comment: "No String Deserialization issue"),
	                                    body: "\n\(#file)\n\(#function)\nhttp Status code: (\(response?.statusCode ?? 0))",
	                                    transmit: { (selectedIndex) -> () in
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
                                    body:NSLocalizedString("Implicit Failure",comment: "Implicit Failure") + "\n\(#file)\n\(#function)\nhttp Status code: (\(response?.statusCode ?? 0))",
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
                caller: "ReadUsersByQuery.execute",
                relatedURL:nil,
                httpStatusCode: 417,
                response: nil,
                result:"{\"message\":\"Unexisting document with registryUID \(registryUID)\"}")
         failure(context)
       }
    }
}
