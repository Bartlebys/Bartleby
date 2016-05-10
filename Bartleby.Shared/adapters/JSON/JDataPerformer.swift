//
//  JDataPerformer.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 08/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation


public enum InvocationPerformanceError: ErrorType {
    case ConcreteTaskRequired
}

extension NSData {

    public func executeSerializedTask()throws ->() {
        if let dsi: ConcreteTask = try JSerializer.deserialize(self) as? ConcreteTask {
            dsi.invoke()
        } else {
           throw InvocationPerformanceError.ConcreteTaskRequired
        }
    }

}
