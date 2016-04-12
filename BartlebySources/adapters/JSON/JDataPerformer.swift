//
//  JDataPerformer.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 08/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

extension NSData{
    
    func executeSerializedInvocation(responseClosure:()->InvocationResponse){
        if let dsi = JSerializer.deserialize(self) as? RespondingInvocation {
            dsi.invoke(responseClosure)
        }else{
            Bartleby.bprint("NSData Failure executeSerializedInvocation with a responseClosure")
        }
    }
    
    public func executeSerializedInvocation()->()  {
        if let dsi = JSerializer.deserialize(self) as? SerializableInvocation {
            dsi.invoke()
        }else{
            Bartleby.bprint("NSData Failure during Deserialization")
        }
    }
    

}