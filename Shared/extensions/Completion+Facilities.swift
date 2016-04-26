//
//  Completion+Facilities.swift
//  bsync
//
//  Created by Martin Delille on 26/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

public extension Completion {
    public convenience init(success: Bool, message: String = "", statusCode: Int = 0){
        self.init()
        self.success = success
        self.message = message
        self.statusCode = statusCode
    }
    
}