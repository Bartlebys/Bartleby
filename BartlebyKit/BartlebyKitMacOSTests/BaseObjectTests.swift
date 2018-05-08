//
//  BaseObjectTests.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 07/04/2016.
//
//

import BartlebyKit
import XCTest

class BaseObjectTests: TestCase {
    func test001_serializeDeserializeAUser() {
        let user = TestCase.document.newManagedModel() as User
        user.email = "tim@apple.com"
        user.password = "pruneau"
        let data = user.serialize()

        do {
            let deserialized = try JSON.decoder.decode(User.self, from: data)
            XCTAssert(deserialized.email == "tim@apple.com", "email \(deserialized.email)")
            XCTAssert(deserialized.password == "pruneau", "password \(deserialized.password ?? Default.NO_PASSWORD)")
        } catch {
            XCTFail("\(error)")
        }
    }

    func test002_serializeDeserializeAUser() {
        let user = TestCase.document.newManagedModel() as User
        user.email = "tim@apple.com"
        user.password = "pruneau"
        let data = user.serialize()
        do {
            if let deserialized: [String: Any] = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] {
                if let email = deserialized["email"] as? String {
                    XCTAssert(email == "tim@apple.com", "email \(email)")
                } else {
                    XCTFail("email should be a String")
                }
                if let password = deserialized["password"] as? String {
                    // The password should be crypted
                    XCTAssert(password != "pruneau", "password \(password)")
                } else {
                    XCTFail("password should be a String")
                }

            } else {
                XCTFail("Casting failure")
            }

        } catch {
            XCTFail("\(error)")
        }
    }

    /*
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
     */
}
