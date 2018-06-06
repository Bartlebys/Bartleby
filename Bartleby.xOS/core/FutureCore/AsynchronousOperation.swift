//
//  AsynchronousOperation.swift
//  BartlebysCore
//
//  Created by Benoit Pereira da silva on 06/06/2018.
//  Copyright © 2018 Bartleby. All rights reserved.
//

import Foundation


// An Operation that can be used to perform Asynchronous Tasks.
// Usage
// 1- You should override this operation
// 2- Override the main method and call `self.state = .finished` on completion
//     override func main () {
//         super.main()
//         if self.isCancelled {
//              return
//         }
//         self.myAsyncStuff(from: self.url, onSuccess: { (...) in
//             self.state = .finished
//         }
//
open class AsynchronousOperation: Operation {

    override open var isAsynchronous: Bool { return true }
    override open var isExecuting: Bool { return self.state == .executing }
    override open var isFinished: Bool { return self.state == .finished }

    public var state = State.ready {
        willSet {
            self.willChangeValue(forKey: self.state.keyPath)
            self.willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            self.didChangeValue(forKey: self.state.keyPath)
            self.didChangeValue(forKey: oldValue.keyPath)
        }
    }

    public enum State: String {
        case ready = "Ready"
        case executing = "Executing"
        case finished = "Finished"
        fileprivate var keyPath: String { return "is" + self.rawValue }
    }

    override open func start() {
        if self.isCancelled {
            self.state = .finished
        } else {
            self.state = .ready
            self.main()
        }
    }

    override open func main() {
        if self.isCancelled {
            self.state = .finished
        } else {
            self.state = .executing
        }
    }
}
