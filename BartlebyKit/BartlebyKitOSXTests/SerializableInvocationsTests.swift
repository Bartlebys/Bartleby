//
//  SerializableInvocationsTests.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 12/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import XCTest
import Alamofire
import ObjectMapper
import BartlebyKit


// MARK: - With ObjC

@objc(PrintUser) public class PrintUser: Task, ConcreteTask {

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


    override public func invoke() throws {
        try super.invoke()
        if let user: User = try self.arguments() as User {
            if let email = user.email {
                bprint("\(email)", file:#file, function:#function, line: #line)
            } else {
                bprint("\(user.UID)", file:#file, function:#function, line: #line)
            }
        }
        try self.forward(Completion.successState())
    }
}


// MARK: -

public class RePrintUserWithoutObjc: Task, ConcreteTask {

    // Universal type support
    override public class func typeName() -> String {
        return "RePrintUserWithoutObjc"
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


    public override func invoke() throws {

        if let user: User = try self.arguments() as User {
            if let email = user.email {
                bprint("\(email)", file:#file, function:#function, line: #line)
            } else {
                bprint("\(user.UID)", file:#file, function:#function, line: #line)
            }
        }
        try self.forward(Completion.successState())

    }
}







class SerializableInvocationsTests: XCTestCase {

    override static func setUp() {
        super.setUp()
        Bartleby.sharedInstance.configureWith(TestsConfiguration)
    }


    override static func tearDown() {
        super.tearDown()
    }

    /**
     DIRECT INVOCATION BASIC TESTS
     */

    func test001_PrintUserTask() {
        let user=User()
        user.email="bartleby@barltebys.org"
        let printer =  PrintUser(arguments:user)
        let serializedInvocation=printer.serialize()
        do {
            let o = try JSerializer.deserialize(serializedInvocation)
            if let deserializedInvocation=o as? PrintUser {
                try deserializedInvocation.invoke()
                XCTAssert(true)
            } else {
                XCTFail("Deserialization as failed")
            }
        } catch {
            XCTFail("\(error)")
        }

    }


    func test002_PrintUserTask_Dynamic() {
        do {
            let user=User()
            user.email="benoit@pereira-da-silva.com"
            let printer = PrintUser(arguments:user)
            let serializedInvocation=printer.serialize()
            if let deserializedInvocation = try JSerializer.deserialize(serializedInvocation) as? ConcreteTask {
                try deserializedInvocation.invoke()
                XCTAssert(true)
            } else {
                XCTFail("Deserialization as failed")
            }
        } catch {
            XCTFail("\(error)")
        }

    }

    func test002__PrintUserTask_Via_NSData_Performer() {
        let user=User()
        user.email="benoit@chaosmose.com"
        do {
            let invocation = PrintUser(arguments:user)
            // Serialize to NSData
            let serializedInvocation: NSData=invocation.serialize()
            // Try to execute
            try serializedInvocation.executeSerializedTask()
            XCTAssert(true)
        } catch let exception {
            XCTFail("\(exception)")
        }
    }



    func test004_RePrintUserWithoutObjcTask_ShouldFail() {
        let user=User()
        user.email="bartleby@barltebys.org"
        let printer =  RePrintUserWithoutObjc(arguments:user)
        let serializedInvocation=printer.serialize()
        do {
            let o = try JSerializer.deserialize(serializedInvocation)

            if let deserializedInvocation=o as? RePrintUserWithoutObjc {
                try deserializedInvocation.invoke()
                XCTFail("Deserialization should fail because RePrintUserWithoutObjc is not declared")
            } else {

                XCTFail("Deserialization should fail because RePrintUserWithoutObjc is not declared")
            }
        } catch {
            XCTAssert(true)
        }

    }


    func test005_RePrintUserWithoutObjcTask() {
        let user=User()
        user.email="bartleby@barltebys.org"
        let printer =  RePrintUserWithoutObjc(arguments:user)
        Registry.declareCollectibleType(RePrintUserWithoutObjc)

        let serializedInvocation=printer.serialize()
        do {
            let o = try JSerializer.deserialize(serializedInvocation)
            if let deserializedInvocation=o as? RePrintUserWithoutObjc {
                try deserializedInvocation.invoke()
                XCTAssert(true)
            } else {
                XCTFail("Deserialization as failed")
            }
        } catch {
            XCTFail("\(error)")
        }

    }


    func test006_RePrintUserWithoutObjc_Dynamic() {
        do {
            let user=User()
            user.email="benoit@pereira-da-silva.com"
            let printer = PrintUser(arguments:user)
            let serializedInvocation=printer.serialize()
            if let deserializedInvocation = try JSerializer.deserialize(serializedInvocation) as? ConcreteTask {
                try deserializedInvocation.invoke()
                XCTAssert(true)
            } else {
                XCTFail("Deserialization as failed")
            }
        } catch {
            XCTFail("\(error)")
        }

    }

    func test007__RePrintUserWithoutObjc_Via_NSData_Performer() {
        let user=User()
        user.email="benoit@chaosmose.com"
        do {
            let invocation = PrintUser(arguments:user)
            // Serialize to NSData
            let serializedInvocation: NSData=invocation.serialize()
            // Try to execute
            try serializedInvocation.executeSerializedTask()
            XCTAssert(true)
        } catch let exception {
            XCTFail("\(exception)")
        }
    }


}
