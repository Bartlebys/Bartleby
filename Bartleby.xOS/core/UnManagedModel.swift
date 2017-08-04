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
@objc(UnManagedModel) open class UnManagedModel: NSObject,Codable,Exposed,DeclaredTypeName {

    open class func typeName() -> String {
        return "UnManagedModel"
    }

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
        do{
            let data = try JSON.encoder.encode(self)
            if let dictionary = try JSONSerialization.jsonObject(with: data, options:.allowFragments) as? [String : Any]{
                return dictionary
            }
        }catch{
            // Silent catch
        }
        return [String:Any]()
    }


}

extension UnManagedModel:JSONString{

    // MARK:-  JSONString

    open func toJSONString(_ prettyPrint:Bool)->String{
        let encoder = JSON.encoder
        if prettyPrint{
            encoder.outputFormatting = .prettyPrinted
        }
        do{
            let data = try JSON.encoder.encode(self)
            return data.optionalString(using: Default.STRING_ENCODING) ?? Default.DESERIALIZATION_HAS_FAILED
        }catch{
            return Default.DESERIALIZATION_HAS_FAILED
        }
    }

    // MARK: - CustomStringConvertible

    override open var description: String {
        get {
            if self is Descriptible {
                return (self as! Descriptible).toString()
            }else{
                return self.toJSONString(true)
            }

        }
    }

}




