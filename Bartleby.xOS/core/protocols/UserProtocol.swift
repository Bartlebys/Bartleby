//
//  UserProtocol.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 23/09/2015.
//  Copyright © 2016 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

// The user protocol defines the minimal contract
// To be a good bartleby Citizen.
public protocol UserProtocol: Collectible {
    associatedtype Status
    associatedtype VerificationMethod

    var spaceUID: String { get set }

    var verificationMethod: VerificationMethod { get set }

    var firstname: String { get set }

    var lastname: String { get set }

    var email: String? { get set }

    var phoneNumber: String? { get set }

    var password: String { get set }

    var activationCode: String { get set }

    var status: Status { get set }
}
