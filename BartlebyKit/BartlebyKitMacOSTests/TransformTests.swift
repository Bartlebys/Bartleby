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
        /*
        let transform = CryptedStringTransform()
        let s1 = "Coucou"
        let json = transform.transformToJSON(s1)
        let s2 = transform.transformFromJSON(json)
        XCTAssertEqual(s1, s2)
         */
    }


}
