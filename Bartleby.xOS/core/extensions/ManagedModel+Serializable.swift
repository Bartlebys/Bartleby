//
//  ManagedModel+Serializable.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/11/2016.
//
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif

// MARK: - Serializable

extension ManagedModel:Serializable{

    open func serialize() -> Data {
        let dictionaryRepresentation = self.dictionaryRepresentation()
        do {
            if Bartleby.configuration.HUMAN_FORMATTED_SERIALIZATON_FORMAT {
                return try JSONSerialization.data(withJSONObject: dictionaryRepresentation, options:[JSONSerialization.WritingOptions.prettyPrinted])
            } else {
                return try JSONSerialization.data(withJSONObject: dictionaryRepresentation, options:[])
            }
        } catch {
            return Data()
        }
    }


    /// Serialize the current object to an UTF8 string
    ///
    /// - Returns: return an UTF8 string
    open func serializeToUFf8String()->String{
        return self.toJSONString(false)
    }

    open func updateData(_ data: Data,provisionChanges:Bool) throws -> Serializable {
        if var JSONDictionary = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as? [String:AnyObject] {
            // Remove the UID_KEY if set to nil or NO_UID
            if JSONDictionary[Default.UID_KEY] == nil || JSONDictionary[Default.UID_KEY] as? String == Default.NO_UID{
                JSONDictionary.removeValue(forKey: Default.UID_KEY)
            }
            let map=Map(mappingType: .fromJSON, JSON: JSONDictionary)
            self.mapping(map: map)
            if provisionChanges && self.isInspectable {
                self.provisionChanges(forKey: "*", oldValue: self, newValue: self)
            }
        }
        return self
    }


    /// Merge the instance with another
    ///
    /// - parameter instance: the instance
    open func mergeWith(_ instance: Exposed) throws {
        for key in instance.exposedKeys{
            if self.exposedKeys.contains(key){
                let value = try instance.getExposedValueForKey(key)
                try self.setExposedValue(value, forKey: key)
            }else{
                self.log("Attempt to merge an unexisting key \(key) on \(instance))", file: #file, function: #function, line: #line, category: logsCategoryFor(self), decorative: false)
            }
        }
        self._commitCounter=Int(instance.commitCounter)
    }
    
}
