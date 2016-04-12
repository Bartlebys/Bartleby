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
public protocol SerializableInvocation:Collectible{
    
    // The method to init  with the arguments
    // It normally uses the setArguments func that should 
    // implement type safety and throw SerializableInvocationError.ArgumentsTypeMisMatch
    init(arguments:Collectible) throws
    
    // Run the invocation
    // All the logic is encapuslated.
    func invoke()
    
    // Define the argument type to perform dynamic control on instanciation
    var argumentClassName:String! { get }
    
}


// MARK: Responding invocation

public protocol InvocationResponse:Collectible{
}

// A serializable invocation is a class that encapsulates the arguments
// in a Serializable object to be passed to a generic invoke method
// and returns a SerializableInvocation during execution
public protocol RespondingInvocation:Collectible{
    
    // The method to init  with the arguments
    // It normally uses the setArguments func that should 
    // Implement type safety
    init(arguments:Collectible) throws
    
    // Run the invocation and returns a response.
    func invoke(responseClosure:()->InvocationResponse)
    
    // Define the argument type to perform dynamic control on instanciation
    var argumentClassName:String! { get }

}
