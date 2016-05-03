//
//  TransformTests.swift
//  BartlebyKit
//
//  Created by Martin Delille on 21/04/2016.
//
//

import XCTest

//import ObjectMapper

import BartlebyKit

class TransformTests: XCTestCase {

    override static func setUp() {
        super.setUp()
        Bartleby.sharedInstance.configureWith(TestsConfiguration)
    }

    func test_CryptedStringTransform() {
        let transform = CryptedStringTransform()

        let s1 = "Coucou"

        let json = transform.transformToJSON(s1)

        print(json)

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

    func test_Base64DataTransform() {
        let transform = Base64DataTransform()

        let s1 = "Une année de plus"
        let data1 = s1.dataUsingEncoding(NSUTF8StringEncoding)

        let json = transform.transformToJSON(data1)

        print("json:\(json)")

        if let data2 = transform.transformFromJSON(json) {
            let s2 = String(data: data2, encoding: NSUTF8StringEncoding)
            XCTAssertEqual(s1, s2)
        } else {
            XCTFail("Error transforming string")
        }
    }
}
