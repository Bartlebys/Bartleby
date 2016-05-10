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


class SerializableInvocationsTests: XCTestCase {

    override static func setUp() {
        super.setUp()
        Bartleby.sharedInstance.configureWith(TestsConfiguration)
        BartlebyDocument.declareCollectibleTypes()
        Registry.declareCollectibleType(PrintUser)// REQUIRED !!!
        Registry.declareCollectibleType(Alias<PrintUser>)
    }


    override static func tearDown() {
        super.tearDown()
        Registry.purgeCollectibleType()
    }

    /**
      DIRECT INVOCATION BASIC TESTS
     */

    func test001_PrintUserTask() {
        let user=User()
        user.email="bartleby@barltebys.org"
        let printer =  PrintUser(arguments:user)
        let serializedInvocation=printer.serialize()
        let o=JSerializer.deserialize(serializedInvocation)
        if let deserializedInvocation=o as? PrintUser {
            deserializedInvocation.invoke()
            XCTAssert(true)
        } else {
            if let error = o as? ObjectError {
                 XCTFail("Deserialization as failed \(error.message)")
            } else {
                 XCTFail("Deserialization as failed")
            }

        }
    }


    func test002_PrintUserTask_Dynamic() {
        let user=User()
        user.email="benoit@pereira-da-silva.com"
        let printer = PrintUser(arguments:user)
        let serializedInvocation=printer.serialize()
        if let deserializedInvocation=JSerializer.deserialize(serializedInvocation) as? ConcreteTask {
            deserializedInvocation.invoke()
            XCTAssert(true)
        } else {
            XCTFail("Deserialization as failed")
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

}
