//
//  BartlebyObject+Log.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation



extension BartlebyObject{

    /**
     Print indirection with contextual informations.

     - parameter message: the message
     - parameter file:  the file
     - parameter line:  the line
     - parameter function : the function name
     - parameter category: a categorizer string
     - parameter decorative: if set to true only the message will be displayed.
     */
    open func log(_ message: Any, file: String, function: String, line: Int, category: String,decorative:Bool=false) {
        self.document?.log(message, file: file, function: function, line: line, category: category, decorative: decorative)
    }
}
