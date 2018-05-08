//
//  HandlersTests.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 03/05/2016.
//
//

import BartlebyKit
import XCTest

class CompletionWithResultTests: TestCase {

    // MARK: Generic result

    func test101_generic_Result_mapping() {
        let handlers = Handlers(completionHandler: { completion in
            if let user: User = completion.getResult() {
                XCTAssertEqual(user.email, "bartleby@barltebys.org")
            } else {
                XCTFail(completion.message)
            }
        })
        completionWitResult(handlers)
    }

    func completionWitResult(_ handlers: Handlers) {
        let user = User()
        user.email = "bartleby@barltebys.org"
        user.creatorUID = user.UID
        user.verificationMethod = User.VerificationMethod.byEmail

        let completion = Completion.successState()
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

    // MARK: Dictionary result

    func test401_dictionary_result_mapping() {
        let completion = Completion.successState()
        let dict1 = ["a.txt": "12345", "b.txt": "67890"]
        completion.setDictionaryResult(dict1)
        if let dict2: [String: String] = completion.getDictionaryResult() {
            XCTAssertEqual(dict1, dict2)
        } else {
            XCTFail("Error getting the dictionary result")
        }
    }
}
