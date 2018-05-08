//
//  Data+String.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 01/08/2017.
//

import Foundation

enum DataEncodingError: Error {
    case stringEncodingHasFailed
}

public extension Data {
    public func optionalString(using: String.Encoding) -> String? {
        return String(data: self, encoding: using)
    }

    public func string(using: String.Encoding) throws -> String {
        if let s = String(data: self, encoding: using) {
            return s
        }
        throw DataEncodingError.stringEncodingHasFailed
    }
}
