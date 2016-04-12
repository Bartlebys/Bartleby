//
//  Alias+Facilities.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 30/03/2016.
//
//

import Foundation

public extension Alias{
    
    public convenience init(withInstanceUID iUID:String){
        self.init()
        self.iUID=iUID
    }
   
}