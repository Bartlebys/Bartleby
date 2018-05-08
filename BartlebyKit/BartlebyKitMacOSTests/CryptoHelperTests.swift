//
//  CryptoHelperTests.swift
//  BartlebyKit
//
//  Created by Martin Delille on 30/03/2016.
//
//

import BartlebyKit
import XCTest

class CryptoHelperTests: TestCase {
    fileprivate static let _cryptoHelper = CryptoHelper(salt: TestsConfiguration.SHARED_SALT)

    func testEncryptDataDecryptData() {
        var bytes = [UInt8]()
        for _ in 0 ... 100 {
            bytes.append(UInt8(arc4random_uniform(UInt32(UInt8.max))))
        }
        let data = Data(bytes: bytes)
        do {
            // If we encrypt it
            let encryptedData = try CryptoHelperTests._cryptoHelper.encryptData(data, useKey: TestsConfiguration.KEY)
            // we get an encrypted buffer
            // If we decrypt it
            let decryptedData = try CryptoHelperTests._cryptoHelper.decryptData(encryptedData, useKey: TestsConfiguration.KEY)
            // we get back our original string
            XCTAssertEqual(data, decryptedData)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testEncryptStringDecryptString() {
        // Given a string
        let string = "martin"
        do {
            // If we encrypt it
            let encryptedString = try CryptoHelperTests._cryptoHelper.encryptString(string, useKey: TestsConfiguration.KEY)
            // If we decrypt it
            let decryptedString = try CryptoHelperTests._cryptoHelper.decryptString(encryptedString, useKey: TestsConfiguration.KEY)
            // we get back our original string
            XCTAssertEqual(decryptedString, "martin")
        } catch {
            XCTFail("\(error)")
        }
    }

    func testEncryptStringToDataDecryptDataToString() {
        // Given a string
        let string = Bartleby.randomStringWithLength(512, signs: "{'èç')à')\"'$$€${}!12673hdazuodazdhudzaohudzo  ≈")
        do {
            // If we encrypt it
            let encryptedData = try CryptoHelperTests._cryptoHelper.encryptStringToData(string, useKey: TestsConfiguration.KEY)
            // If we decrypt it
            let decryptedString = try CryptoHelperTests._cryptoHelper.decryptStringFromData(encryptedData, useKey: TestsConfiguration.KEY)
            // we get back our original string
            XCTAssertEqual(decryptedString, string)
        } catch {
            XCTFail("\(error)")
        }
    }
}
