//
//  ReadUsersByIds.swift
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
@objc(ReadUsersByIdsParameters) public class ReadUsersByIdsParameters : JObject {
	
	// Universal type support
	override open class func typeName() -> String {
		 return "ReadUsersByIdsParameters"
	}
	// 
	public var ids:[String]?
	// 
	public var result_fields:[String]?
	// the sort (MONGO DB)
	public var sort:[String:Any]?

    required public init(){
        super.init()
    }


    // MARK: Mappable

    required public init?(_ map: Map) {
        super.init(map)
    }

    override open func mapping(_ map: Map) {
        super.mapping(map)
        self.silentGroupedChanges {
			self.ids <- ( map["ids"] )
			self.result_fields <- ( map["result_fields"] )
			self.sort <- ( map["sort"] )
        }
    }


    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.silentGroupedChanges {
			self.ids=decoder.decodeObject(of: [NSString.self], forKey: "ids") as? [String]
			self.result_fields=decoder.decodeObject(of: [NSString.self], forKey: "result_fields") as? [String]
			self.sort=decoder.decodeObject(of: [NSDictionary.classForCoder(),NSString.classForCoder(),NSNumber.classForCoder(),NSObject.classForCoder(),NSSet.classForCoder()], forKey: "sort")as? [String:Any]
        }
    }

    override open func encode(with coder: NSCoder) {
        super.encode(with:coder)
		if let ids = self.ids {
			coder.encode(ids,forKey:"ids")
		}
		if let result_fields = self.result_fields {
			coder.encode(result_fields,forKey:"result_fields")
		}
		if let sort = self.sort {
			coder.encode(sort,forKey:"sort")
		}
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }

}



@objc(ReadUsersByIds) open class ReadUsersByIds : JObject{

    // Universal type support
    override open class func typeName() -> String {
           return "ReadUsersByIds"
    }


    public static func execute(fromRegistryWithUID registryUID:String,
						parameters:ReadUsersByIdsParameters,
						sucessHandler success:@escaping(_ users:[User])->(),
						failureHandler failure:@escaping(_ context:JHTTPResponse)->()){
	

        if let document = Bartleby.sharedInstance.getDocumentByUID(registryUID) {
            let pathURL=document.baseURL.appendingPathComponent("users")
            let dictionary:Dictionary<String, Any>?=Mapper().toJSON(parameters)
            let urlRequest=HTTPManager.requestWithToken(inRegistryWithUID:document.UID,withActionName:"ReadUsersByIds" ,forMethod:"GET", and: pathURL)
            
            do {
                let r=try URLEncoding().encode(urlRequest,with:dictionary)
                request(r).responseJSON(completionHandler: { (response) in
                  
                    let request=response.request
                    let result=response.result
                    let response=response.response
            
                    // Bartleby consignation
            
                    let context = JHTTPResponse( code: 745776284,
                        caller: "ReadUsersByIds.execute",
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
            					if let instance = Mapper <User>().mapArray(result.value){					    
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
                caller: "ReadUsersByIds.execute",
                relatedURL:nil,
                httpStatusCode: 417,
                response: nil,
                result:"{\"message\":\"Unexisting document with registryUID \(registryUID)\"}")
         failure(context)
       }
    }
}
