//
//  Base64DataTransform.swift
//  bsync
//
//  Created by Martin Delille on 25/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif

open class Base64DataTransform: TransformType {
    public typealias Object = Data
    public typealias JSON = String

    public init() {
    }

    open func transformFromJSON(_ value: AnyObject?) -> Object? {
        if let string=value as? String {
            return Data(base64Encoded: string, options: [.ignoreUnknownCharacters])
        }
        return nil
    }

    open func transformToJSON(_ value: Object?) -> JSON? {
        if let d=value {
            return d.base64EncodedString(options: .endLineWithCarriageReturn)
        }
        return nil
    }
}
