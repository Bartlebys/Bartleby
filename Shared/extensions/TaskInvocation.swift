//
//  Tasks+SerializableInvocation.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 26/04/2016.
//
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
    //import BartlebyKit
#endif


public enum TaskInvocationError : ErrorType {
    case ArgumentsTypeMisMatch
    case NoArgument
}


@objc(TaskInvocation) public class TaskInvocation:Task,SerializableInvocation{
   
  
    public required convenience init<ArgumentType:Serializable>(arguments:ArgumentType) throws{
        self.init()
        self.argumentsData=arguments.serialize()
    }

    
    // Run the invocation
    // All the logic is encapuslated.
    // You should override the implementation
    public func invoke(){
    }
    
    /**
     
     - throws: Error on deserialization and type missmatch
     
     - returns: A collectible object
     */
    public func arguments<ArgumentType:Serializable>() throws -> ArgumentType{
        if let argumentsData = self.argumentsData {
            let deserialized=JSerializer.deserialize(argumentsData)
            if let arguments = deserialized as? ArgumentType{
                return arguments
            }else{
                throw TaskInvocationError.ArgumentsTypeMisMatch
            }
        }
        throw TaskInvocationError.NoArgument
    }
    
    // MARK: Mappable
    
    required public init?(_ map: Map) {
        super.init(map)
        mapping(map)
    }
    
    override public func mapping(map: Map) {
        super.mapping(map)
    }
    
    
    // MARK: NSSecureCoding
    
    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
    }
    
    
    override public class func supportsSecureCoding() -> Bool{
        return true
    }
    
    required public init() {
        super.init()
    }

}