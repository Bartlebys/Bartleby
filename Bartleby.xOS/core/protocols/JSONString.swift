//
//  JSONString.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 20/07/2016.
//
//

import Foundation

public protocol JSONString: CustomStringConvertible {
    func toJSONString(_ prettyPrint: Bool) -> String
}
