//
//  Mergeable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 17/12/2016.
//
//

import Foundation


public protocol Mergeable{

    func mergeWith(_ instance: Exposed) throws

}
