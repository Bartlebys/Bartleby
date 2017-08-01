//
//  UnManagedModel.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 13/12/2016.
//
//

import Foundation

// Models can be :
// - ManagedModel ( fully managed models)
// - UnManagedModel (no supervision, no change provisionning )
@objc(UnManagedModel) open class UnManagedModel: NSObject,Codable,Exposed {


    required public override init() {
        super.init()
    }


    /// Performs the deserialization without invoking provisionChanges
    ///
    /// - parameter changes: the changes closure
    public func quietChanges(_  changes:()->()){
        changes()
    }


    /// Performs the deserialization without invoking provisionChanges
    ///
    /// - parameter changes: the changes closure
    public func quietThrowingChanges(_ changes:()throws->())rethrows{
        try changes()
    }


    // MARK: - Codable

    required public init(from decoder: Decoder) throws{
        super.init()
    }

    open func encode(to encoder: Encoder) throws {
    }

    // MARK: - Exposed

    open var exposedKeys:[String] {
        return [String]()
    }

    open func setExposedValue(_ value:Any?, forKey key: String) throws {
    }

    open func getExposedValueForKey(_ key:String) throws -> Any?{
        return nil
    }
}

extension UnManagedModel:DictionaryRepresentation{

    open func dictionaryRepresentation() -> [String : Any] {
        var dictionary = [String:Any]()
        for key in self.exposedKeys{
            if let value = try? self.getExposedValueForKey(key){
                if let convertibleValue = value as? DictionaryRepresentation{
                    dictionary[key] = convertibleValue.dictionaryRepresentation()
                }else{
                  dictionary[key] = value
                }
            }
        }
        return dictionary
    }
}


