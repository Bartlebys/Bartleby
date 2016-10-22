//
//  JData+Conveniences.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 16/08/2016.
//
//

import Foundation

extension JData{

    public convenience init(from: Data?) {
        self.init()
        self.data=from
    }
    
}
