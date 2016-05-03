//
//  ProgressionNotification.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 03/05/2016.
//
//

import Foundation
#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif


// MARK: - ProgressionNotification

/// A Progress notification
public class ProgressionNotification: NSNotification, NSSecureCoding {
    
    static public let NAME="PROGRESSION_NOTIFICATION_NAME"
    
    var progressionState: Progression
    
    public convenience init(state: Progression, object: AnyObject?, userInfo: [NSObject : AnyObject]?) {
        self.init(name: ProgressionNotification.NAME, object: object, userInfo: userInfo)
        self.progressionState=state
    }
    
    public convenience init() {
        self.init(name: ProgressionNotification.NAME, object:nil, userInfo: nil)
    }
    
    override init(name: String, object: AnyObject?, userInfo: [NSObject : AnyObject]?) {
        self.progressionState=Progression.defaultState()
        super.init(name: ProgressionNotification.NAME, object: object, userInfo: userInfo)
    }
    
    // MARK: Mappable
    
    required public convenience init?(_ map: Map) {
        self.init()
        mapping(map)
    }
    
    public func mapping(map: Map) {
        self.progressionState <- map["progressionState"]
    }
    
    // MARK: NSSecureCoding
    
    required public init?(coder decoder: NSCoder) {
        self.progressionState=decoder.decodeObjectOfClass(Progression.self, forKey: "progressionState")!
        super.init(coder: decoder)
    }
    
    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
    }
    
    
    public class func supportsSecureCoding() -> Bool {
        return true
    }
    
}
