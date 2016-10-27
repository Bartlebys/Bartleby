//
//  Reaction.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 22/10/2016.
//
//

import Foundation

public enum Reaction {

    // No reaction
    case nothing

    // Adaptive Message
    // The final behaviour is determined by the Consignee but
    // When the reaction will be completed the transmit will be called
    case dispatchAdaptiveMessage(context:Consignable, title:String, body:String, transmit:(_ selectedIndex:UInt)->())

    //Explicit calls

    // Explicit interactive message
    case presentInteractiveMessage(title:String, body:String, transmit:(_ selectedIndex:UInt)->())

    // Explicit volatile message
    case presentVolatileMessage(title:String, body:String)

    // Explicit message logging
    case putMessageInLogs(title:String, body:String)

    // TRACKING

    // Tracks and possibly records the result for future inspection
    case track(result:Any?, context:Consignable)
    
}
