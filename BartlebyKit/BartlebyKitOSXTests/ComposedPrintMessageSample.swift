//
//  SerializableInvocationSample.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 12/10/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation
import ObjectMapper
import BartlebyKit
/*

@objc(MultiplePrintMessageSampleArguments) class MultiplePrintMessageSampleArguments : BaseObject {
    
    //
    var successMessage:String="Eureka it is success!"
    var failureMessage:String="Eureka failure was a must!"
    
    required init(){
        super.init()
    }
    // MARK: Mappable
    
    required init?(_ map: Map) {
        super.init(map)
        mapping(map)
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        successMessage <- map["successMessage"]
        failureMessage <- map["failureMessage"]
    }
    
}


@objc(ComposedPrintMessageSample) class ComposedPrintMessageSample: BaseObject,SerializableInvocation{
    
    // MARK:- SerializableInvocation

    // Random success
    let success:Bool = (arc4random_uniform(2) == 1)
    
    typealias ArgumentType=MultiplePrintMessageSampleArguments
    
    func invoke(){
        
        // PROCEED TO SUB INVOCATION 
        
        if success {
            
            do{
                // This appproach of Dynamic invocation is 100% type safe.
                // Create an invocation
                
                let arguments = PrintMessageSampleArguments()
                arguments.message=_serializableArguments.successMessage
                try PrintMessageSample(arguments:arguments).invoke()
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
  
        }else {
            
            do{
                // This appproach of Dynamic invocation is 100% type safe.
                // Create an invocation
                
                let arguments = PrintMessageSampleArguments()
                arguments.message=_serializableArguments.failureMessage
                 try PrintMessageSample(arguments:arguments).invoke()
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
    
    internal var _serializableArguments:ArgumentType=ArgumentType()
    
    var argumentClassName:String! {
        get{
            return NSStringFromClass(ArgumentType.self)
        }
    }
    
    required init(arguments:Collectible) throws {
        super.init()
        guard let args = arguments as? ArgumentType 
            else{
                throw SerializableInvocationError.ArgumentsTypeMisMatch
        }
        _serializableArguments = args
    }
    
    
    // MARK: Mappable
    
    required init?(_ map: Map) {
        super.init(map)
        mapping(map)
    }
    
    
    required init(){
        super.init()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        _serializableArguments <- map["_serializableArguments"]
    }
    
}*/