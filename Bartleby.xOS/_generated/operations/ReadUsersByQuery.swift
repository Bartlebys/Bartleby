
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
#endif
@objc public class ReadUsersByQueryParameters : ManagedModel {
		// Universal type support
	override open class func typeName() -> String {
		 return "ReadUsersByQueryParameters"
	}
	// 
	public var result_fields:[String]?
	// the sort (MONGO DB)
	public var sort:[String:Int] = [String:Int]()
	// the query (MONGO DB)
	public var query:[String:String] = [String:String]()

    required public init(){
        super.init()
    }

    // MARK: - Exposed (Bartleby's KVC like generative implementation)

    /// Return all the exposed instance variables keys. (Exposed == public and modifiable).
    override  open var exposedKeys:[String] {
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
    override  open func setExposedValue(_ value:Any?, forKey key: String) throws {
        switch key {
            case "result_fields":
                if let casted=value as? [String]{
                    self.result_fields=casted
                }
            case "sort":
                if let casted=value as? [String:Int]{
                    self.sort=casted
                }
            case "query":
                if let casted=value as? [String:String]{
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
    override  open func getExposedValueForKey(_ key:String) throws -> Any?{
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
    // MARK: - Codable


    public enum CodingKeys: String,CodingKey{
		case result_fields
		case sort
		case query
    }

    required public init(from decoder: Decoder) throws{
		try super.init(from: decoder)
        try self.quietThrowingChanges {
			let values = try decoder.container(keyedBy: CodingKeys.self)
			self.result_fields = try values.decodeIfPresent([String].self,forKey:.result_fields)
			self.sort = try values.decode([String:Int].self,forKey:.sort)
			self.query = try values.decode([String:String].self,forKey:.query)
        }
    }

    override open func encode(to encoder: Encoder) throws {
		try super.encode(to:encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(self.result_fields,forKey:.result_fields)
		try container.encode(self.sort,forKey:.sort)
		try container.encode(self.query,forKey:.query)
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
            let dictionary:[String:Any]? = parameters.dictionaryRepresentation()
            let urlRequest=HTTPManager.requestWithToken(inDocumentWithUID:document.UID,withActionName:"ReadUsersByQuery" ,forMethod:"GET", and: pathURL)
            
            do {
                let r=try URLEncoding().encode(urlRequest,with:dictionary)
                request(r).responseData(completionHandler: { (response) in
                  
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
                            body:"\(String(describing: result.value))\n\(#file)\n\(#function)\nhttp Status code: (\(statusCode))",
                            transmit:{ (selectedIndex) -> () in
                        })
                        reactions.append(failureReaction)
                        failure(context)
            
                    }else{
                          if 200...299 ~= statusCode {
	                        do{
	                            if let data = response.data{
	                                let instance = try JSON.decoder.decode([User].self,from:data)
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
