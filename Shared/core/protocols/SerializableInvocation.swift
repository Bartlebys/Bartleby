//
//  SerializableInvocation.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 08/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation


public enum SerializableInvocationError : ErrorType {
    case ArgumentsTypeMisMatch
}

// MARK: SerializableInvocation invocations


// A serializable invocation is a class that encapsulates the arguments
// in a Serializable object to be passed to a generic invoke method
public protocol SerializableInvocation:Serializable {
    
    // Initializes with the arguments
    // You MUST IMPLEMENT type safety 
    // and throw SerializableInvocationError.ArgumentsTypeMisMatch
    init<ArgumentType:Serializable>(arguments:ArgumentType) throws
    
    // Run the invocation
    // All the logic is encapuslated.
    func invoke()
    
}

// Implementation sample

/*
 
public class PrintUser: TaskInvocation {
 
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
*/