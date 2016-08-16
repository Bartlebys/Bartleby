
//
//  JString+Conveniences.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 16/08/2016.
//
//

import Foundation

extension JString{

    public convenience init(from: String?) {
        self.init()
        self.string=from
    }

}