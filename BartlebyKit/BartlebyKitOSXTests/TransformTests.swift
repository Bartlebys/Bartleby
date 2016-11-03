//
//  TransformTests.swift
//  BartlebyKit
//
//  Created by Martin Delille on 21/04/2016.
//
//

import XCTest
import BartlebyKit

class TransformTests: XCTestCase {

    override static func setUp() {
        super.setUp()
        Bartleby.sharedInstance.configureWith(TestsConfiguration.self)
    }

    func test_CryptedStringTransform() {
        let transform = CryptedStringTransform()
        let s1 = "Coucou"
        let json = transform.transformToJSON(s1)
        let s2 = transform.transformFromJSON(json)
        XCTAssertEqual(s1, s2)
    }

    func test_CryptedSerializableTransform_withUser() {
        let transform = CryptedSerializableTransform<User>()

        let user1 = User()
        user1.spaceUID = Bartleby.createUID()
        user1.creatorUID = user1.UID

        let json = transform.transformToJSON(user1)

        print("json:\(json)")

        if let user2 = transform.transformFromJSON(json) {
            XCTAssertEqual(user1.UID, user2.UID)
        } else {
            XCTFail("Error transforming user2")
        }
    }

}
