//
//  DictionaryDictionaryKeyPath.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 15/09/2017.
//

// Adapted from the excellent post of Ole Begemann
// https://oleb.net/blog/2017/01/dictionary-key-paths/
// This approach is used by bartleby to convert types during data migration
// It should not be used in normal situations.

// Usage :
// `dict[keyPath: "translations.characters.x"] = "Jojo"`

import Foundation

public struct DictionaryKeyPath {
    var segments: [String]

    var isEmpty: Bool { return segments.isEmpty }
    var path: String {
        return segments.joined(separator: ".")
    }
    /// Strips off the first segment and returns a pair
    /// consisting of the first segment and the remaining key path.
    /// Returns nil if the key path has no segments.
    func headAndTail() -> (head: String, tail: DictionaryKeyPath)? {
        guard !isEmpty else { return nil }
        var tail = segments
        let head = tail.removeFirst()
        return (head, DictionaryKeyPath(segments: tail))
    }
}

/// Initializes a DictionaryKeyPath with a string of the form "this.is.a.keypath"
public extension DictionaryKeyPath {
    init(_ string: String) {
        segments = string.components(separatedBy: ".")
    }
}

extension DictionaryKeyPath: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }

    public init(unicodeScalarLiteral value: String) {
        self.init(value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
}

// Needed because Swift 3.0 doesn't support extensions with concrete
// same-type requirements (extension Dictionary where Key == String).
protocol StringProtocol {
    init(string s: String)
}

extension String: StringProtocol {
    init(string s: String) {
        self = s
    }
}

extension Dictionary where Key == String {
    subscript(keyPath keyPath: DictionaryKeyPath) -> Any? {
        get {
            switch keyPath.headAndTail() {
            case nil:
                // key path is empty.
                return nil
            case let (head, remainingDictionaryKeyPath)? where remainingDictionaryKeyPath.isEmpty:
                // Reached the end of the key path.
                let key = Key(string: head)
                return self[key]
            case let (head, remainingDictionaryKeyPath)?:
                // Key path has a tail we need to traverse.
                let key = Key(string: head)
                switch self[key] {
                case let nestedDict as [Key: Any]:
                    // Next nest level is a dictionary.
                    // Start over with remaining key path.
                    return nestedDict[keyPath: remainingDictionaryKeyPath]
                default:
                    // Next nest level isn't a dictionary.
                    // Invalid key path, abort.
                    return nil
                }
            }
        }
        set {
            switch keyPath.headAndTail() {
            case nil:
                // key path is empty.
                return
            case let (head, remainingDictionaryKeyPath)? where remainingDictionaryKeyPath.isEmpty:
                // Reached the end of the key path.
                let key = Key(string: head)
                self[key] = newValue as? Value
            case let (head, remainingDictionaryKeyPath)?:
                let key = Key(string: head)
                let value = self[key]
                switch value {
                case var nestedDict as [Key: Any]:
                    // Key path has a tail we need to traverse
                    nestedDict[keyPath: remainingDictionaryKeyPath] = newValue
                    self[key] = nestedDict as? Value
                default:
                    // Invalid keyPath
                    return
                }
            }
        }
    }
}
