//
//  CompletionNotification.swift
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
public class CompletionNotification: NSNotification, NSSecureCoding {

    static public let NAME="COMPLETION_NOTIFICATION_NAME"

    var completionState: Completion

    public convenience init(state: Completion, object: AnyObject?, userInfo: [NSObject : AnyObject]?) {
        self.init(name: CompletionNotification.NAME, object: object, userInfo: userInfo)
        self.completionState=state
    }

    public convenience init() {
        self.init(name: CompletionNotification.NAME, object:nil, userInfo: nil)
    }

    override init(name: String, object: AnyObject?, userInfo: [NSObject : AnyObject]?) {
        self.completionState=Completion.defaultState()
        super.init(name: CompletionNotification.NAME, object: object, userInfo: userInfo)
    }

    // MARK: Mappable

    required public convenience init?(_ map: Map) {
        self.init()
        mapping(map)
    }

    public func mapping(map: Map) {
        self.completionState <- map["completionState"]
    }

    // MARK: NSSecureCoding

    required public init?(coder decoder: NSCoder) {
        self.completionState=decoder.decodeObjectOfClass(Completion.self, forKey: "completionState")!
        super.init(coder: decoder)
    }

    override public func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
    }


    public class func supportsSecureCoding() -> Bool {
        return true
    }

}
