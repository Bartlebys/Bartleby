//
//  CollectibleStateMessage.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 06/03/2017.
//
//

import Foundation


public class CollectibleStateMessage<T:Collectible>:StateMessage{

    public typealias RawValue = CollectibleStateMessage

    let name:String
    let object:T

    init(name:String,object:T) {
        self.name=name
        self.object=object
    }

    public required init?(rawValue: CollectibleStateMessage.RawValue) {
        self.name=rawValue.name
        self.object=rawValue.object
    }

    public var rawValue: CollectibleStateMessage{
        return self
    }

    public var hashValue: Int{
        return self.object.UID.hashValue
    }

    public static func == (lhs: CollectibleStateMessage, rhs: CollectibleStateMessage) -> Bool {
        return (lhs.object.UID == rhs.object.UID && lhs.name == rhs.name)
    }
    
}
