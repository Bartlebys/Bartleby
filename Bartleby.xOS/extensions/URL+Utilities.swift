//
//  String+Paths.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 14/11/2016.
//
//

import Foundation

public extension URL {
    public var isAnAlias: Bool {
        // Alias? https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/URL.swift#L417
        let resv: URLResourceValues? = try? resourceValues(forKeys: [URLResourceKey.isAliasFileKey])
        return resv?.isAliasFile ?? false
    }

    public var isInMainBundle: Bool {
        return absoluteString.contains(Bundle.main.bundleURL.path)
    }

    /// Returns if the url is accessible.
    /// relies  #import "unistd.h" (must be added to the bridging header)
    /// - Parameter url: the url to test
    /// - Returns: true if the url is sandboxed
    public var isSandBoxed: Bool {
        if isFileURL {
            let fileSystemRepresentation = NSString(string: path).fileSystemRepresentation
            return access(fileSystemRepresentation, R_OK) == 0
        } else {
            return true
        }
    }
}
