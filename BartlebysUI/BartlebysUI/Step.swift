//
//  Step.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 24/03/2018.
//  Copyright © 2018 Chaosmos SAS. All rights reserved.
//

import Foundation


// MARK: - Step

public protocol Step{
    var stepIndex:Int { get set }
    func proceedToValidation()
}
