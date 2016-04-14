//
//  SerializableInvocationSampleInvalid.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 08/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation
import ObjectMapper
import BartlebyKit


@objc(PrintMessageSampleArgumentsInvalid) class PrintMessageSampleArgumentsInvalid : BaseObject {
    
    //
    var message:String=""
    
    required init(){
        super.init()
    }
    // MARK: Mappable
    
    required init?(_ map: Map) {
        super.init(map)
        mapping(map)
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        message <- map["message"]
    }
    
}
