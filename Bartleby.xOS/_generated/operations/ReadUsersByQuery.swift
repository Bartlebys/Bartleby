
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
@objc(ReadUsersByQueryParameters) public class ReadUsersByQueryParameters : ManagedModel {
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

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override open var exposedKeys:[String] {
        var exposed=super.exposedKeys
        exposed.append(contentsOf:["result_fields","sort","query"])
        return exposed
    }


    /// Set the value of the given key
    ///
    /// - parameter value: the value
    /// - parameter key:   the key
    ///
    /// - throws: throws an Exception when the key is not exposed
    override open func setExposedValue(_ value:Any?, forKey key: String) throws {
        switch key {
            case "result_fields":
                if let casted=value as? [String]{
                    self.result_fields=casted
                }
            case "sort":
                if let casted=value as? [String:Any]{
                    self.sort=casted
                }
            case "query":
                if let casted=value as? [String:Any]{
                    self.query=casted
                }
            default:
                return try super.setExposedValue(value, forKey: key)
        }
    }


    /// Returns the value of an exposed key.
    ///
    /// - parameter key: the key
    ///
    /// - throws: throws Exception when the key is not exposed
    ///
    /// - returns: returns the value
    override open func getExposedValueForKey(_ key:String) throws -> Any?{
        switch key {
            case "result_fields":
               return self.result_fields
            case "sort":
               return self.sort
            case "query":
               return self.query
            default:
                return try super.getExposedValueForKey(key)
        }
    }
    // MARK: - Mappable

    required public init?(map: Map) {
        super.init(map:map)
    }

    override open func mapping(map: Map) {
        super.mapping(map: map)
        self.quietChanges {
			self.result_fields <- ( map["result_fields"] )
			self.sort <- ( map["sort"] )
			self.query <- ( map["query"] )
        }
    }


    // MARK: - NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.quietChanges {
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

@objc(ReadUsersByQuery) open class ReadUsersByQuery : ManagedModel{

    // Universal type support
    override open class func typeName() -> String {
           return "ReadUsersByQuery"
    }


    public static func execute(from documentUID:String,
						parameters:ReadUsersByQueryParameters,
						sucessHandler success:@escaping(_ users:[User])->(),
						failureHandler failure:@escaping(_ context:HTTPContext)->()){
	
        if let document = Bartleby.sharedInstance.getDocumentByUID(documentUID) {
            let pathURL=document.baseURL.appendingPathComponent("usersByQuery")
            let dictionary:Dictionary<String, Any>?=Mapper().toJSON(parameters)
            let urlRequest=HTTPManager.requestWithToken(inDocumentWithUID:document.UID,withActionName:"ReadUsersByQuery" ,forMethod:"GET", and: pathURL)
            
            do {
                let r=try URLEncoding().encode(urlRequest,with:dictionary)
                request(r).responseString(completionHandler: { (response) in
                  
                    let request=response.request
                    let result=response.result
                    let timeline=response.timeline
                    let statusCode=response.response?.statusCode ?? 0
                    
                    let context = HTTPContext( code: 3654843900,
                        caller: "ReadUsersByQuery.execute",
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
					metrics.operationName="ReadUsersByQuery"
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
                            body:"\(result.value)\n\(#file)\n\(#function)\nhttp Status code: (\(statusCode))",
                            transmit:{ (selectedIndex) -> () in
                        })
                        reactions.append(failureReaction)
                        failure(context)
            
                    }else{
                          if 200...299 ~= statusCode {
	                            if let string=result.value{
	                                if let instance = Mapper <User>().mapArray(JSONString:string){
	                                    success(instance)
	                                }else{
	                                    let failureReaction =  Reaction.dispatchAdaptiveMessage(
	                                        context: context,
	                                        title: NSLocalizedString("Deserialization issue",
	                                        comment: "Deserialization issue"),
	                                        body:"\(result.value)\n\(#file)\n\(#function)\nhttp Status code: (\(statusCode))",
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
	                                    body: "\(result.value)\n\(#file)\n\(#function)\nhttp Status code: (\(statusCode))",
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
                                body:"\(result.value)\n\(#file)\n\(#function)\nhttp Status code: (\(statusCode))",
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
                caller: "ReadUsersByQuery.execute",
                relatedURL:nil,
                httpStatusCode:500)
                failure(context)
        }
      }else{
         let context = HTTPContext( code: 1,
                caller: "ReadUsersByQuery.execute",
                relatedURL:nil,
                httpStatusCode: 417)
         failure(context)
       }
    }
}
