//
//  Reporter.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 16/09/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation


// MARK: -

/// A Base class for consignable contexts
public protocol Consignable {
    
    // A developer set code to provide filtering 
    var code:UInt { get set }
    
    // A descriptive string for developper to identify the calling context
    var caller:String { get  set }

}

public struct Context:Consignable {
    
    // A developer set code to provide filtering 
    public var code:UInt=UInt.max
    
    // A descriptive string for developper to identify the calling context
    public var caller:String=Default.NO_NAME
    
    public var message:String=Default.NO_MESSAGE
    
    public init(code:UInt!,caller:String!){
        self.code=code
        self.caller=caller
    }
    
    public init(context:String!){
        self.caller=context
    }
    
    /*
    public var description: String {
        get{
            return "#(\(code)) \(caller)\n"
        }
    }*/
}

public protocol ConsignableHTTPContext:Consignable{
    
    // The related url
    var relatedURL:NSURL! { get set }
    
    // The http status code
    var httpStatusCode:Int! { get set }
    
    // The response
    var response:AnyObject? { get set }
    
}


/// A context that describes an HTTP call

public struct HTTPContext : ConsignableHTTPContext {
    
    // A developer set code to provide filtering 
    public var code:UInt=UInt.max
    
    // A descriptive string for developper to identify the calling context
    public var caller:String=Default.NO_NAME
    
    // Supplementary infos for developpers
    public var infos:AnyObject?
    
    // The related url
    public var relatedURL:NSURL!
    
    // The http status code
    public var httpStatusCode:Int!
    
    // The response
    public var response:AnyObject?
    
    // The result
    public var result:AnyObject?
    
    init(code:UInt!,caller:String!,relatedURL:NSURL?,httpStatusCode:Int?,response:AnyObject?,result:AnyObject=""){
        self.code=code
        self.caller=caller
        self.relatedURL=relatedURL
        self.httpStatusCode=httpStatusCode
        self.response=response
        self.result=result
    }
    
    /*
  public var description: String {
        get{
            let secureCode = (code ?? 0)
            let secureCaller = (caller ?? "Caller-Undefined")
            let secureResponse = (response ?? "No-Response")
            
            return "#(\(secureCode) \(secureCaller)\nURL:\(relatedURL)\nHTTP Status Code:\(httpStatusCode)\n Response:\(secureResponse)"
        }
    }*/
}



// MARK: - Consignation Protocol

protocol Consignation{
    
    /**
    Present an interactive message.
    
    - parameter title:           title
    - parameter body:            body
    - parameter onSelectedIndex: call back on interaction
    
    - returns: nil
    */
    func presentInteractiveMessage(title:String,body:String,onSelectedIndex:(selectedIndex:UInt)->())->()
    
    /**
    Presents a message that will be displayed for a limited time
    
    - parameter title: title
    - parameter body:  body
    
    - returns: nil
    */
    func presentVolatileMessage(title:String,body:String)->()
    
    /**
    Logs a message 
    
    - parameter title: title
    - parameter body:  body
    
    - returns: nil
    */
    func logMessage(title:String,body:String)->()
    
}

// MARK: - AdaptiveConsignation Protocol


protocol AdaptiveConsignation{
    /**
    Handle an adaptive message call that can variate according to the context
    
    - parameter context:         the calling contect
    - parameter title:           title
    - parameter body:            body 
    - parameter onSelectedIndex: call back on optionnal interaction
    
    - returns: nil
    */
    func dispatchAdaptiveMessage(context:Consignable,title:String,body:String,onSelectedIndex:(selectedIndex:UInt)->())->()
    
}

// MARK: - ConcreteConsignee Protocol

protocol ConcreteConsignee {
    
    // You can perform multiple reaction 
    // var reactions = Array<Consignee.Reaction> ()
    func perform(reaction:Consignee.Reaction,forContext:Consignable)
    
    // You can perform multiple reaction 
    // var reactions = Array<Consignee.Reaction> ()
    
    func perform(reactions:[Consignee.Reaction],forContext:Consignable)
    
}


// MARK: - ConcreteTracker Protocol

protocol ConcreteTracker {
    
    // Tracks and possibibly records the results with title and body annotations
    func track(result:AnyObject?,context:Consignable)
    
}




// MARK: - Consignee base class

// to be extende by
// conforming to protocols
// - ConcreteConsignee
// - ConcreteTracker
// - Consignation
// - AdaptiveConsignation (should be ovveriden per app) 
public class AbstractConsignee:NSObject{
    
    /// The display duration of volatile messages
    static public let VOLATILE_DISPLAY_DURATION:Double=3
    
    public enum Reaction{
        
        // No reaction
        case Nothing
        
        // Adaptive Message
        // The final behaviour is determined by the Consignee but
        // When the reaction will be completed the trigger will be called if there is one
        case DispatchAdaptiveMessage(context:Consignable,title:String,body:String,trigger:(selectedIndex:UInt)->())
        
        //Explicit calls 
        
        // Explicit interactive message
        case PresentInteractiveMessage(title:String,body:String,trigger:(selectedIndex:UInt)->())
        
        // Explicit volatile message
        case PresentVolatileMessage(title:String,body:String)
        
        // Explicit message logging
        case LogMessage(title:String,body:String)
        
        // TRACKING
        
        // Tracks and possibly records the result for future inspection
        case Track(result:AnyObject?,context:Consignable)

    }

}


