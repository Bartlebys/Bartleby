//
//  JObjectTests.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/04/2016.
//
//

import XCTest
import BartlebyKit

class JObjectTests: XCTestCase {

    func test_001Copy_using_NSCopying() {
        let user=User()
        user.email="bartleby@barltebys.org"
        user.creatorUID=user.UID
        user.verificationMethod=User.VerificationMethod.ByEmail
        // Test NSCopying on JObject
        if let copiedUser=user.copy() as? User {
            XCTAssert(user.email == copiedUser.email, "users should be equivalent")
            XCTAssertFalse(user === copiedUser, "users should be distinct instances")
        } else {
            XCTFail("Failure on copy")
        }
    }

    func test_002Cloning_via_jserializer() {
        let user=User()
        user.email="bartleby@barltebys.org"
        user.creatorUID=user.UID
        user.verificationMethod=User.VerificationMethod.ByEmail
        // Test NSCopying on JObject
        do {
            if let copiedUser = try JSerializer.volatileDeepCopy(user) {
                XCTAssert(user.email == copiedUser.email, "users should be equivalent")
                XCTAssertFalse(user === copiedUser, "users should be distinct instances")
            } else {
                XCTFail("Failure on copy")
            }

        } catch {
            XCTFail("\(error)")
        }
    }

}
