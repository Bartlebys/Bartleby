//
//  Operation+Conveniences.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 06/09/2016.
//
//

import Foundation

public extension PushOperation {
    public func canBePushed() -> Bool {
        if status == .none || status == .pending {
            return true
        }

        if status == .completed {
            if let completionState = self.completionState {
                if completionState.success == false {
                    return true // Retry
                }
            }
        }

        return false
    }
}
