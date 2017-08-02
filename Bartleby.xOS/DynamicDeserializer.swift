//
//  DynamicFactory.swift
//  Bartleby macOS
//
//  Created by Benoit Pereira da silva on 02/08/2017.
//

import Foundation


public struct DynamicFactory{

    enum Error:Error {
        case classNotFound
    }

    // You register the class
    enum ClassName:String {
        case none
    }


    static func deserialize(className:ClassName) throws -> Any {
        switch className {
        case .none:
            throw DynamicFactory.Error.classNotFound
        default:
          throw DynamicFactory.Error.classNotFound
        }
    }

}
