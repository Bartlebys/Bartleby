//
//  HandlersTests.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 03/05/2016.
//
//

import XCTest
import BartlebyKit

class CompletionWithResultTests: TestCase {

    // MARK: Generic result
    func  test101_generic_Result_mapping() {
        let handlers=Handlers(completionHandler: { (completion) in
            if let user: User = completion.getResult() {
                 XCTAssertEqual(user.email, "bartleby@barltebys.org")
            } else {
                XCTFail(completion.message)
            }
        })
        self.completionWitResult(handlers)
    }


    func  test102_generic_Result_mapping_explicit_serializer() {
        let handlers=Handlers(completionHandler: { (completion) in
            if let user: User = completion.getResultFromSerializer(JSerializer.sharedInstance) {
                XCTAssertEqual(user.email, "bartleby@barltebys.org")
            } else {
                XCTFail(completion.message)
            }
        })
        self.completionWitResult(handlers)
    }

    func completionWitResult(handlers: Handlers) {
        let user=User()
        user.email="bartleby@barltebys.org"
        user.creatorUID=user.UID
        user.verificationMethod=User.VerificationMethod.ByEmail

        let completion=Completion.successState()
        completion.setResult(user)
        handlers.on(completion)
    }

    // MARK: String result
    func test201_string_Result_mapping() {
        let completion = Completion.successState()
        let s1 = "A poor lonesome string"
        completion.setStringResult(s1)
        let s2: String? = completion.getStringResult()
        XCTAssertEqual(s1, s2)
    }

    // MARK: String array result
    func test301_string_array_result_mapping() {
        let completion = Completion.successState()
        let array1 = ["A", "poor", "lonesome", "string"]
        completion.setStringArrayResult(array1)
        if let array2: [String] = completion.getStringArrayResult() {
        XCTAssertEqual(array1, array2)
        } else {
            XCTFail("Error getting the string array result")
        }
    }

}
