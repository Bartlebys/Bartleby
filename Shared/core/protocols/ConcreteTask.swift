//
//  ConcreteTask.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 08/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation


public protocol SerializableArguments {
    // (!) This method is implemented as final in a Task extension to force Type Matching Safety
    // it throws Task.ArgumentsTypeMisMatch
    func arguments<ExpectedType:Serializable>() throws -> ExpectedType
}

public protocol Invocable{
    // Run the invocation
    // All the logic is encapuslated.
    func invoke()
}


public protocol ConcreteTask:SerializableArguments,Invocable{
    // Initializes with the arguments
    // You serialize the arguments in this method
    init(arguments:Serializable)
}