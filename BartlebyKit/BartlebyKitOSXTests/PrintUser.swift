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


// MARK: - Using a Task

public class PrintUser: Task, ConcreteTask {

    // Universal type support
    override public class func typeName() -> String {
        return "PrintUser"
    }

    /**
     This initializer **MUST:** call configureWithArguments
     - parameter arguments: the arguments

     - returns: a well initialized task.
     */
    convenience required public init (arguments: Collectible) {
        self.init()
        self.configureWithArguments(arguments)
    }


     public func invoke() {
        do {
            if let user: User = try self.arguments() as User {
                if let email = user.email {
                    bprint("\(email)", file:#file, function:#function, line: #line)
                } else {
                    bprint("\(user.UID)", file:#file, function:#function, line: #line)
                }
            }
            self.forward(Completion.successState())
        } catch let e {
            bprint("\(e)", file:#file, function:#function, line:#line)
        }

    }

}
