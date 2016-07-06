//
//  CryptoHelperTests.swift
//  BartlebyKit
//
//  Created by Martin Delille on 30/03/2016.
//
//

import XCTest

import BartlebyKit

class CryptoHelperTests: TestCase {
    private static let _cryptoHelper = CryptoHelper(key:TestsConfiguration.KEY, salt:TestsConfiguration.SHARED_SALT)

    func testEncryptDataDecryptData() {
        // Given a buffer defined by a base64 string
        let base64dString = "SGkh"
        // that is converted to a NSData
        if let data = NSData(base64EncodedString: base64dString, options: [.IgnoreUnknownCharacters]) {
            do {
                // If we encrypt it
                let encryptedData = try CryptoHelperTests._cryptoHelper.encryptData(data)
                // we get an encrypted buffer
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
        var encryptedString=""
        // If we encrypt it
        do {
            encryptedString = try CryptoHelperTests._cryptoHelper.encryptString(string)
            // we get an encrypted base64 string
            XCTAssertEqual(encryptedString, "eTCPvyGC1XPax9XAwdBDdQ==")
        } catch {
            XCTFail("\(error)")
        }

        do {

            // Let's convert the encrypted base64 string to an encrypted buffer
            if let encryptedData = encryptedString.dataUsingEncoding(Default.STRING_ENCODING) {
                // If we decrypt it
                let decryptedData = try CryptoHelperTests._cryptoHelper.decryptData(encryptedData)
                // And convert its content to a string
                let decryptedString = String(data: decryptedData, encoding: Default.STRING_ENCODING)
                // Let's transform it to a string
                XCTAssertEqual(decryptedString, "martin")
            } else {
                XCTFail("Error during NSData encoding")
            }
        } catch {
            XCTFail("\(error)")
        }

    }

    func testEncryptDataDecrypString() {
        let string = "martin"
        if let data = string.dataUsingEncoding(Default.STRING_ENCODING) {
            do {
                let encryptedData = try CryptoHelperTests._cryptoHelper.encryptData(data)
                if let dataString=String(data: encryptedData, encoding: Default.STRING_ENCODING) {
                    let decryptedString = try CryptoHelperTests._cryptoHelper.decryptString(dataString)
                    XCTAssertEqual(decryptedString, "martin")
                } else {
                    XCTFail("Error during NSData encoding")
                }


            } catch {
                XCTFail("\(error)")
            }
        } else {
            XCTFail("Error data creation from string")
        }
    }
    
    func testEncryptDecrypt_HashMap() {
        let hashMapString = "{\"pthToH\":{\"file.txt\":\"1408464486\"}}"
        do {
            let cryptedHashMapString = try CryptoHelperTests._cryptoHelper.encryptString(hashMapString)
            // we get an encrypted base64 string
//            XCTAssertEqual(cryptedHashMapString, "eTCPvyGC1XPax9XAwdBDdQ==")
            // If we decrypt it
            let decryptedHashMapString = try CryptoHelperTests._cryptoHelper.decryptString(cryptedHashMapString)
            // we get back our original string
            XCTAssertEqual(decryptedHashMapString, "{\"pthToH\":{\"file.txt\":\"1408464486\"}}")
        } catch {
            XCTFail("\(error)")
        }
    }
}
