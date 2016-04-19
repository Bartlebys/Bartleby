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

// SHOULD

class SerializableInvocations: XCTestCase {
    func testSerializableInvocation() {
        
        var hasThrownArgumentsTypeMisMatch=false
        
        
        // #1 This approach is 100% safe because the execution flow is stopped on Type Missmatch exception
        
        do{
            // This appproach of Dynamic invocation is 100% type safe.
            // Create an invocation
            
            let arguments = PrintMessageSampleArguments()
            arguments.message="Hello Dolly 1"
            
            let invocation = try PrintMessageSample(arguments:arguments)
            
            // Serialize to NSData
            let serializedInvocation:NSData=invocation.serialize()
            
            // Execute from serialized Data
            serializedInvocation.executeSerializedInvocation()
            
            
        }catch{
            switch error{
            case SerializableInvocationError.ArgumentsTypeMisMatch :
                bprint("SerializableInvocationError.ArgumentsTypeMisMatch")
                hasThrownArgumentsTypeMisMatch=true
                break
            // You can handle execution Exception
            default:
                break
            }
        }
        
        XCTAssertFalse(hasThrownArgumentsTypeMisMatch, "SerializableInvocationError.ArgumentsTypeMisMatch Thrown!")
        
    }
    
    
    // We pass an invalid argument object with the same signature
    func testInvalidSerializableInvocation() {
        
        var hasThrownArgumentsTypeMisMatch=false
        
        do{
            // This appproach of Dynamic invocation is 100% type safe.
            // Create an invocation
            
            let arguments = PrintMessageSampleArgumentsInvalid()
            arguments.message="Hello Dolly 2 should fail"
            
            let invocation = try PrintMessageSample(arguments:arguments)
            
            // Serialize to NSData
            let serializedInvocation:NSData=invocation.serialize()
            
            // Execute from serialized Data
            serializedInvocation.executeSerializedInvocation()
            
        }catch {
            switch error{
            case SerializableInvocationError.ArgumentsTypeMisMatch :
                bprint("SerializableInvocationError.ArgumentsTypeMisMatch")
                hasThrownArgumentsTypeMisMatch=true
                break
            // You can handle execution Exception
            default:
                break
            }
        }
        XCTAssertTrue(hasThrownArgumentsTypeMisMatch, "PrintMessageSampleArgumentsInvalid is invalid SerializableInvocationError.ArgumentsTypeMisMatch should have been thrown!")
        
        
    }
    
    
    
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
    
    
}
