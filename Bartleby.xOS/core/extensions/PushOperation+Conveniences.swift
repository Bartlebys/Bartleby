//
//  Operation+Conveniences.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 06/09/2016.
//
//

import Foundation

public extension PushOperation{

    public func canBePushed()->Bool{

        if self.status == .none || self.status == .pending {
            return true
        }

        if self.status == .completed{
            if let completionState=self.completionState{
                if completionState.success==false{
                    return true // Retry
                }
            }
        }

        return false
    }

}
