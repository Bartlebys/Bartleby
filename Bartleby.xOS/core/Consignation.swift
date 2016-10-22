//
//  Reporter.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 16/09/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation


// MARK: -





/// A context that describes an HTTP call

public struct HTTPContext: ConsignableHTTPContext {

    // A developer set code to provide filtering
    public var code: UInt=UInt.max

    // A descriptive string for developper to identify the calling context
    public var caller: String=Default.NO_NAME

    // Supplementary infos for developpers
    public var infos: Any?

    // The related url
    public var relatedURL: URL?

    // The http status code
    public var httpStatusCode: Int?

    // The response
    public var response: Any?

    // The result
    public var result: Any?

    init(code: UInt!, caller: String!, relatedURL: URL?, httpStatusCode: Int?, response: Any?, result: Any?) {
        self.code=code
        self.caller=caller
        self.relatedURL=relatedURL
        self.httpStatusCode=httpStatusCode
        self.response=response
        self.result=result
    }
}



/// A Base class for consignable contexts
public protocol Consignable {

    // A developer set code to provide filtering
    var code: UInt { get set }

    // A descriptive string for developper to identify the calling context
    var caller: String { get  set }
    
}

public protocol ConsignableHTTPContext: Consignable {

    // The related url
    var relatedURL: URL? { get set }

    // The http status code
    var httpStatusCode: Int? { get set }

    // The response
    var response: Any? { get set }

}





// MARK: - Consignation Protocol

public protocol Consignation {

    /**
    Present an interactive message.

    - parameter title:           title
    - parameter body:            body
    - parameter onSelectedIndex: call back on interaction

    - returns: nil
    */
    func presentInteractiveMessage(_ title: String, body: String, onSelectedIndex:@escaping(_ selectedIndex: UInt)->())->()

    /**
    Presents a message that will be displayed for a limited time

    - parameter title: title
    - parameter body:  body

    - returns: nil
    */
    func presentVolatileMessage(_ title: String, body: String)->()

    /**
    Logs a message

    - parameter title: title
    - parameter body:  body

    - returns: nil
    */
    func putMessageInLogs(_ title: String, body: String)->()

}

// MARK: - AdaptiveConsignation Protocol


public protocol AdaptiveConsignation {
    /**
    Handle an adaptive message call that can variate according to the context

    - parameter context:         the calling contect
    - parameter title:           title
    - parameter body:            body
    - parameter onSelectedIndex: call back on optionnal interaction

    - returns: nil
    */
    func dispatchAdaptiveMessage(_ context: Consignable, title: String, body: String, onSelectedIndex:@escaping(_ selectedIndex: UInt)->())->()

}

// MARK: - ConcreteConsignee Protocol

public protocol ConcreteConsignee {

    // You can perform multiple reaction
    // var reactions = Array<Reaction> ()
    func perform(_ reaction: Reaction, forContext: Consignable)

    // You can perform multiple reaction
    // var reactions = Array<Consignee.Reaction> ()

    func perform(_ reactions: [Reaction], forContext: Consignable)

}


// MARK: - ConcreteTracker Protocol

public protocol ConcreteTracker {

    // Tracks and possibibly records the results with title and body annotations
    func track(_ result: Any?, context: Consignable)

}




