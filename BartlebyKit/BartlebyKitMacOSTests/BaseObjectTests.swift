//
//  BaseObjectTests.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/04/2016.
//
//

import XCTest
import BartlebyKit

class BaseObjectTests: XCTestCase {

    func test_001Copy_using_NSCopying() {
        let document=BartlebyDocument()
        let user=User()
        user.referentDocument=document
        user.email="bartleby@barltebys.org"
        user.creatorUID=user.UID
        user.verificationMethod=User.VerificationMethod.byEmail
        // Test NSCopying on BaseObject
        if let copiedUser=user.copy() as? User {
            XCTAssert(user.email == copiedUser.email, "users should be equivalent")
            XCTAssertFalse(user === copiedUser, "users should be distinct instances")
        } else {
            XCTFail("Failure on copy")
        }
    }

}
