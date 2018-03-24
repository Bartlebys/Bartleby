//
//  StepNavigation.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 24/03/2018.
//  Copyright © 2018 Chaosmos SAS. All rights reserved.
//

import Foundation


// MARK: - StepNavigation

public protocol StepNavigation{

    func didValidateStep(_ step:Int)
    func disableActions()
    func enableActions()

    // The progress indicator
    func enableProgressIndicator()
    func disableProgressIndicator()
}
