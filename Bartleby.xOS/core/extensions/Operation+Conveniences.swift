//
//  Operation+Conveniences.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 06/09/2016.
//
//

import Foundation

public extension Operation{

    public func canBePushed()->Bool{

        if self.status == .None || self.status == .Pending {
            return true
        }

        if self.status == .Completed{
            if let completionState=self.completionState{
                if completionState.success==false{
                    return true // Retry
                }
            }
        }

        return false
    }

}