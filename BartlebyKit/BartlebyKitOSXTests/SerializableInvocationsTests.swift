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
    }
    
    
    
    func test001_SerializableInvocationWithInferedType() {
        
        // Create an invocation
        let arguments = PrintMessageSampleArguments()
        arguments.message="Hello Dolly 001"
        do{
            let invocation = try PrintMessageSample(arguments:arguments)
            // Serialize to NSData
            let serializedInvocation:NSData=invocation.serialize()
            
            // You can run this if you know the inferred type at compilation time
            if let deserializedInvocation:PrintMessageSample=JSerializer.deserialize(serializedInvocation) as? PrintMessageSample{
                deserializedInvocation.invoke()
                XCTAssertTrue(true)
            }else{
                XCTFail("Deserialization as failed")
            }
        }catch let exception{
            XCTFail("\(exception)")
        }
        
    }
    
    
    func test002_SerializableInvocationWithDynamicType() {
        // Create an invocation
        let arguments = PrintMessageSampleArguments()
        arguments.message="Hello Dolly 002"
        do{
            let invocation = try PrintMessageSample(arguments:arguments)
            // Serialize to NSData
            let serializedInvocation:NSData=invocation.serialize()
            
            // DYNAMIC == No inference of the type
            if let deserializedInvocation=JSerializer.deserialize(serializedInvocation) as? SerializableInvocation{
                deserializedInvocation.invoke()
                XCTAssert(true)
            }else{
                XCTFail("Deserialization as failed")
            }
        }catch let exception{
            XCTFail("\(exception)")
        }
    }
    
    
    func test003_SerializableInvocationWithDynamicTypeViaThePerformer() {
        
        // Create an invocation
        let arguments = PrintMessageSampleArguments()
        arguments.message="Hello Dolly again 003"
        do{
            let invocation = try PrintMessageSample(arguments:arguments)
            // Serialize to NSData
            let serializedInvocation:NSData=invocation.serialize()
            try serializedInvocation.executeSerializedInvocation()
            XCTAssert(true)
        }catch let exception{
            XCTFail("\(exception)")
        }
        
    }

    
    func test004_UseATaskInvocation(){
        let user=User()
        user.email="bpds@me.com"
        if let printer =  try? PrintUser(arguments:user){
            let serializedInvocation=printer.serialize()
            if let deserializedInvocation=JSerializer.deserialize(serializedInvocation) as? PrintUser{
                deserializedInvocation.invoke()
                XCTAssert(true)
            }else{
                XCTFail("Deserialization as failed")
            }

        }
    }
    
    
    /*
     func testComposedSerializableInvocation() {
     
     do{
     let arguments = MultiplePrintMessageSampleArguments()
     try ComposedPrintMessageSample(arguments:arguments).invoke()
     
     }catch{
     switch error{
     case SerializableInvocationError.ArgumentsTypeMisMatch :
     bprint("SerializableInvocationError.ArgumentsTypeMisMatch")
     break
     // You can handle execution Exception
     default:
     break
     }
     }
     
     
     }
     */
    
}
