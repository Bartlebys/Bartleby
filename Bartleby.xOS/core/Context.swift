//
//  Context.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 22/10/2016.
//
//

import Foundation

public struct Context: Consignable {
    // A developer set code to provide filtering
    public var code: Int = Default.MAX_INT

    // A descriptive string for developper to identify the calling context
    public var caller: String = Default.NO_NAME

    public var message: String = Default.NO_MESSAGE

    public init(code: Int!, caller: String!) {
        self.code = code
        self.caller = caller
    }

    public init(context: String!) {
        caller = context
    }
}
