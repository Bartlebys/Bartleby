//
//  ManagedModel+DatatUpdatable.swift
//  Bartleby macOS
//
//  Created by Benoit Pereira da silva on 04/08/2017.
//

import Foundation

extension ManagedModel:DataUpdatable{

    open func updateData(_ data: Data,provisionChanges:Bool) throws -> Serializable {
        do {
            let deserialized = try JSON.decoder.decode(type(of: self), from: data)
            try self.mergeWith(deserialized)
            if provisionChanges && self.isInspectable {
                self.provisionChanges(forKey: "*", oldValue: self, newValue: self)
            }
        }catch{
            // Silent
        }
        return self
    }
    
}
