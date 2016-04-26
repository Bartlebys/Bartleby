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

public protocol SerializableArguments:Collectible{}


// A serializable invocation is a class that encapsulates the arguments
// in a Serializable object to be passed to a generic invoke method
public protocol SerializableInvocation:Collectible {
    
    // The method to init  with the arguments
    // implements type safety and throw SerializableInvocationError.ArgumentsTypeMisMatch
    init(arguments:SerializableArguments) throws
    
    // Run the invocation
    // All the logic is encapuslated.
    func invoke()
    
}


// MARK: Responding invocation

public protocol InvocationResponse:Collectible{}

// A serializable invocation is a class that encapsulates the arguments
// in a Serializable object to be passed to a generic invoke method
// and returns a SerializableInvocation during execution
public protocol RespondingInvocation:Collectible{
    
    // The method to init  with the arguments
    // implements type safety and throw SerializableInvocationError.ArgumentsTypeMisMatch
    init(arguments:SerializableArguments) throws
    
    // Run the invocation and returns a response.
    func invoke(responseClosure:()->InvocationResponse)
    
}
