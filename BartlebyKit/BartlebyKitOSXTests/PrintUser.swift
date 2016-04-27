//
//  SerializableInvocationSample.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 08/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation
import ObjectMapper
import BartlebyKit


// MARK: - Using a Task (that s the best approach)

public class PrintUser: Task {
    
    // Initializes with the arguments
    // You MUST IMPLEMENT type safety
    // and throw SerializableInvocationError.ArgumentsTypeMisMatch
    public required convenience init<ArgumentType:Serializable>(arguments:ArgumentType)throws{
        self.init()
        // You should guarantee type safety on init
        if arguments is User{
            self.argumentsData=arguments.serialize()
        }else{
            throw SerializableInvocationError.ArgumentsTypeMisMatch
        }
    }
    
    override public func invoke() {
        if let user:User = try? self.arguments(){
            if let email = user.email{
                bprint("\(email)",file:#file,function:#function,line: #line)
            }else{
                bprint("\(user.UID)",file:#file,function:#function,line: #line)
            }
            
        }
    }
}
