//
//  CryptoHelperTests.swift
//  BartlebyKit
//
//  Created by Martin Delille on 30/03/2016.
//
//

import XCTest

import BartlebyKit

class CryptoHelperTests: XCTestCase {
    private static let _cryptoHelper = CryptoHelper(key:TestsConfiguration.KEY, salt:TestsConfiguration.SHARED_SALT)

    override static func setUp() {
        super.setUp()
        Bartleby.sharedInstance.configureWith(TestsConfiguration)
    }

    func testEncryptDataDecryptData() {
        // Given a buffer defined by a base64 string
        let base64dString = "SGkh"
        // that is converted to a NSData
        if let data = NSData(base64EncodedString: base64dString, options: [.IgnoreUnknownCharacters]) {
            do {
                // If we encrypt it
                let encryptedData = try CryptoHelperTests._cryptoHelper.encryptData(data)
                // we get an encrypted buffer
                XCTAssertEqual(encryptedData.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn), "FacTvJN9YQVRqzW8mCuy4w==")
                // If we decrypt it
                let decryptedData = try CryptoHelperTests._cryptoHelper.decryptData(encryptedData)
                // we get back our original buffer
                XCTAssertEqual("SGkh", decryptedData.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn))
            } catch {
                XCTFail("\(error)")
            }
        } else {
            XCTFail("Error during base 64 encoding")
        }
    }

    func testEncryptStringDecryptString() {
        // Given a string
        let string = "martin"
        do {
            // If we encrypt it
            let encryptedString = try CryptoHelperTests._cryptoHelper.encryptString(string)
            // we get an encrypted base64 string
            XCTAssertEqual(encryptedString, "eTCPvyGC1XPax9XAwdBDdQ==")
            // If we decrypt it
            let decryptedString = try CryptoHelperTests._cryptoHelper.decryptString(encryptedString)
            // we get back our original string
            XCTAssertEqual(decryptedString, "martin")
        } catch {
            XCTFail("\(error)")
        }
    }

    func testEncryptStringDecryptData() {
        // Given a string
        let string = "martin"
        // If we encrypt it
        do {
            let encryptedString = try CryptoHelperTests._cryptoHelper.encryptString(string)
            // we get an encrypted base64 string
            XCTAssertEqual(encryptedString, "eTCPvyGC1XPax9XAwdBDdQ==")
            // Let's convert the encrypted base64 string to an encrypted buffer
            if let encryptedData = NSData(base64EncodedString: encryptedString, options: [.IgnoreUnknownCharacters]) {
                // If we decrypt it
                let decryptedData = try CryptoHelperTests._cryptoHelper.decryptData(encryptedData)
                // And convert its content to a string
                let decryptedString = String(data: decryptedData, encoding: Default.TEXT_ENCODING)
                // Let's transform it to a string
                XCTAssertEqual(decryptedString, "martin")
            } else {
                XCTFail("Error during base 64 encoding")
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func testEncryptDataDecrypString() {
        let string = "martin"
        if let data = string.dataUsingEncoding(Default.TEXT_ENCODING) {
            do {
                let encryptedData = try CryptoHelperTests._cryptoHelper.encryptData(data)
                let encryptedBase64Data = encryptedData.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
                let decryptedString = try CryptoHelperTests._cryptoHelper.decryptString(encryptedBase64Data)
                XCTAssertEqual(decryptedString, "martin")

            } catch {
                XCTFail("\(error)")
            }
        } else {
            XCTFail("Error data creation from string")
        }
    }
}
