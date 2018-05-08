//
//  Global.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 06/05/2016.
//
//  A set of general global functions

import Foundation

// The `=? operator allows simplify optional assignements :
//  `a = b ?? a` can be written : `a =? b`
infix operator =?: AssignmentPrecedence

public func =? <T>(left: inout T?, right: T?) {
    left = right ?? left
}

public func =? <T>(left: inout T, right: T?) {
    left = right ?? left
}

public let GB = 1_000_000_000
public let MB = 1_000_000
public let KB = 1000

public typealias UID = String
/**
 Returns a category for glog

 - parameter subject: the subject to classify

 - returns: a string representing the category
 */
public func logsCategoryFor(_ subject: Any) -> String {
    if let s = subject as? Collectible {
        return s.d_collectionName
    }
    return Default.LOG_DEFAULT
}

/// Global logs Observers

internal var glogObservers = [Logger]()

public func addGlobalLogsObserver(_ logger: Logger) {
    glogObservers.append(logger)
}

public func removeGlobalLogsObserver(_ logger: Logger) {
    if let idx = glogObservers.index(where: { $0.UID == logger.UID }) {
        glogObservers.remove(at: idx)
    }
}

/**
 Global log  indirection with guided contextual info is relayed to any openned document log
 Usage : glog("<Message>",file:#file,function:#function,line:#line")
 You can create code snippet

 - parameter items: the items to print
 - parameter file:  the file
 - parameter line:  the line
 - parameter function : the function name
 - parameter context: a contextual string
 */
public func glog(_ message: Any, file: String = #file, function: String = #function, line: Int = #line, category: String = Default.LOG_DEFAULT, decorative: Bool = false) {
    for observer in glogObservers {
        observer.log(message, file: file, function: function, line: line, category: category, decorative: decorative)
    }
    if decorative {
        print("\(message)")
    } else {
        print("\(category)-\(file)(\(line)).\(function): \(message)")
    }
}

// MARK: - Sync on Main Thread

/// synchronously but thread-safely invoke p assed-in block on main thread avoiding deadlock
public func syncOnMain(execute block: () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.sync(execute: block)
    }
}

/// synchronously but thread-safely invoke passed-in block on main thread avoiding deadlock
/// This method allows to synchronize blocks that throws
/// - Parameter block: the block
public func syncThrowableOnMain(execute block: () throws -> Void) rethrows {
    if Thread.isMainThread {
        try block()
    } else {
        try DispatchQueue.main.sync(execute: block)
    }
}

/// synchronously but thread-safely invoke passed-in block on main thread avoiding deadlock
public func syncOnMainAndReturn<T>(execute work: () throws -> T) rethrows -> T {
    if Thread.isMainThread {
        return try work()
    } else {
        return try DispatchQueue.main.sync(execute: work)
    }
}
