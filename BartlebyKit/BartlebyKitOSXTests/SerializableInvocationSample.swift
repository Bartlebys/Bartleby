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


// MARK: - Using a TaskInvocation (that s the best approach)

public class PrintUser: TaskInvocation {
    
    // Initializes with the arguments
    // You MUST IMPLEMENT type safety
    // and throw SerializableInvocationError.ArgumentsTypeMisMatch
    public required convenience init<ArgumentType:Serializable>(arguments:ArgumentType)throws{
        self.init()
        // You should guarantee type safety on init
        if arguments is User{
            self.argumentsData=arguments.serialize()
        }else{
            throw SerializableInvocationError.ArgumentsTypeMisMatch
        }
    }
    
    override public func invoke() {
        if let user:User = try? self.arguments(){
            if let email = user.email{
                bprint("\(email)",file:#file,function:#function,line: #line)
            }else{
                bprint("\(user.UID)",file:#file,function:#function,line: #line)
            }
            
        }
    }
}




// MARK: - Creating a Manual instance

@objc(PrintMessageSampleArguments) class PrintMessageSampleArguments : BaseObject {
    
    //
    var message:String=""
    
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
        message <- map["message"]
    }
    
}


// Dont forget to set @objc(ClassName) before your class for invocations
// You can use "public class PrintMessageSample<ArgumentType:PrintMessageSampleArguments>..." but you will loose the dynamism
@objc(PrintMessageSample) public class PrintMessageSample: BaseObject,SerializableInvocation{
    
    // MARK:- SerializableInvocation
    
    internal var _serializableArguments:PrintMessageSampleArguments=PrintMessageSampleArguments()
    

    public required convenience init<ArgumentType:Serializable>(arguments:ArgumentType) throws{
        self.init()
        if arguments is PrintMessageSampleArguments{
            self._serializableArguments = arguments as! PrintMessageSampleArguments
        }else{
            throw SerializableInvocationError.ArgumentsTypeMisMatch
        }
        
    }
    
    
    public func invoke(){
        bprint("PRINT \(_serializableArguments.message)",file:#file,function:#function,line: #line)
    }
    
    // MARK: Mappable
    
    public required init?(_ map: Map) {
        super.init(map)
        mapping(map)
    }
    
    
    public required init(){
        super.init()
    }
    
    // MARK: Mappable
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    public override func mapping(map: Map) {
        super.mapping(map)
        _serializableArguments <- map["_serializableArguments"]
    }
    
    
}