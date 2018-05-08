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
@objc(UnManagedModel) open class UnManagedModel: NSObject, Codable, Exposed, DeclaredTypeName {
    open class func typeName() -> String {
        return "UnManagedModel"
    }

    public required override init() {
        super.init()
    }

    /// Performs the deserialization without invoking provisionChanges
    ///
    /// - parameter changes: the changes closure
    public func quietChanges(_ changes: () -> Void) {
        changes()
    }

    /// Performs the deserialization without invoking provisionChanges
    ///
    /// - parameter changes: the changes closure
    public func quietThrowingChanges(_ changes: () throws -> Void) rethrows {
        try changes()
    }

    // MARK: - Codable

    public required init(from _: Decoder) throws {
        super.init()
    }

    open func encode(to _: Encoder) throws {
    }

    // MARK: - Exposed

    open var exposedKeys: [String] {
        return [String]()
    }

    open func setExposedValue(_: Any?, forKey _: String) throws {
    }

    open func getExposedValueForKey(_: String) throws -> Any? {
        return nil
    }
}

extension UnManagedModel: DictionaryRepresentation {
    open func dictionaryRepresentation() -> [String: Any] {
        do {
            let data = try JSON.encoder.encode(self)
            if let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                return dictionary
            }
        } catch {
            // Silent catch
        }
        return [String: Any]()
    }
}

extension UnManagedModel: JSONString {

    // MARK: -  JSONString

    open func toJSONString(_ prettyPrint: Bool) -> String {
        let encoder = prettyPrint ? JSON.prettyEncoder : JSON.encoder
        do {
            let data = try encoder.encode(self)
            return data.optionalString(using: Default.STRING_ENCODING) ?? Default.DESERIALIZATION_HAS_FAILED
        } catch {
            return Default.DESERIALIZATION_HAS_FAILED
        }
    }

    // MARK: - CustomStringConvertible

    open override var description: String {
        if self is Descriptible {
            return (self as! Descriptible).toString()
        } else {
            return toJSONString(true)
        }
    }
}
