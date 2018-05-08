//
//  TriggerHook.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 03/11/2016.
//
//

import Foundation

public protocol TriggerHook {
    /// Called by the Document before trigger integration
    ///
    /// - Parameter trigger: the trigger
    func triggerWillBeIntegrated(trigger: Trigger)

    /// Called by the Document after trigger integration
    ///
    /// - Parameter trigger: the trigger
    func triggerHasBeenIntegrated(trigger: Trigger)
}
