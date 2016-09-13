//
//  BsyncKeyValueStorageTests.swift
//  bsync
//
//  Created by Martin Delille on 13/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class BsyncKeyValueStorageTests: TestCase {

    fileprivate static let _spaceUID = TestCase.document.spaceUID
    fileprivate static var _userID = "UNDEFINED"
    fileprivate static let _kvsUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(Bartleby.randomStringWithLength(6) + ".kvs")
    let _kvs = BsyncKeyValueStorage(url: BsyncKeyValueStorageTests._kvsUrl)

    override func setUp() {
        super.setUp()

        do {
            try _kvs.open()
        } catch {
            XCTFail("\(error)")
        }
    }

    override func tearDown() {
        super.tearDown()

        do {
            try _kvs.save()
        } catch {
            XCTFail("\(error)")
        }
    }

    func test101_Upsert1() {
        XCTAssertFalse(_fm.fileExists(atPath: BsyncKeyValueStorageTests._kvsUrl.path))
        let user = User()
        user.creatorUID = user.UID
        user.spaceUID = BsyncKeyValueStorageTests._spaceUID
        BsyncKeyValueStorageTests._userID = user.UID
        _kvs["user1"] = user
    }
    func test102_Upsert2() {
       XCTAssertTrue(_fm.fileExists(atPath: BsyncKeyValueStorageTests._kvsUrl.path))
        let s=JString()
        s.string="value2"
       _kvs["key2"] = s

   }


    func test104_ReadUser() {
        if let user = _kvs["user1"] as? User {
            XCTAssertEqual(user.UID, BsyncKeyValueStorageTests._userID)
            XCTAssertEqual(user.spaceUID, BsyncKeyValueStorageTests._spaceUID)
        } else {
            XCTFail("Error retrieving user1")
        }
    }
    func test105_ReadString() {
        if let value2 = _kvs["key2"] as? JString {
            XCTAssertEqual(value2.string, "value2")
        } else {
            XCTFail("Error retrieving value2")
        }
    }

    func test106_Delete() {
        _kvs.delete("user1")
    }

    func test106_ReadAfterDelete_ShouldFail() {
        if let _ = _kvs["user1"] {
            XCTFail("The key \"user1\" should have been deleted")
        }
    }


    func test108_RemoveAll() {
        do {
            try _kvs.removeAll()
            XCTAssertFalse(_fm.fileExists(atPath: BsyncKeyValueStorageTests._kvsUrl.path))
        } catch {
            XCTFail("\(error)")
        }
    }

    func test109_EnumerateAfterRemoveAll() {
        let kvs = BsyncKeyValueStorage(url: BsyncKeyValueStorageTests._kvsUrl)
        XCTAssertFalse(_fm.fileExists(atPath: BsyncKeyValueStorageTests._kvsUrl.path))

        do {
            try kvs.open()
        } catch {
            XCTFail("\(error)")
        }
        XCTAssertEqual(0, kvs.enumerate().count)
    }


    func test110_SerializableString() {
        let s1 = "Rocinante"
        _kvs.setStringValue(s1, forKey: "horse")
        if let s2 = _kvs.getStringValueForKey("horse") {
            XCTAssertEqual(s2, s1)
        } else {
            XCTFail("Serialization error")
        }
    }


    func test110_SerializableData() {
        if let d1 = "Rocinante".data( using: String.Encoding.utf8){
            _kvs.setDataValue(d1, forKey:"horseAsData")
            if let d2 = _kvs.getDataValueForKey("horseAsData") {
                XCTAssertEqual(d2, d1)
            } else {
                XCTFail("Serialization error")
            }
        }else{
             XCTFail("NSData encoding failure")
        }

    }
}
