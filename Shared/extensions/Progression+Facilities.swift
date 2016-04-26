//
//  Progression+Facilities.swift
//  bsync
//
//  Created by Martin Delille on 26/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation


public extension Progression {
    
    public convenience init(currentTaskIndex: Int, totalTaskCount: Int = 0, currentTaskProgress: Double = 0, message: String = "", data: NSData? = nil){
        self.init()
        self.currentTaskIndex = currentTaskIndex
        self.totalTaskCount = totalTaskCount
        self.currentTaskProgress = currentTaskProgress
        self.message = message
        self.data = data
    }
}