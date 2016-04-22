//
//  BsyncKeyValueStorageTests.swift
//  bsync
//
//  Created by Martin Delille on 13/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class BsyncKeyValueStorageTests: XCTestCase {
    private static let _spaceUID = Bartleby.createUID()
    private static var _userID = "UNDEFINED"
    private static let _kvsUrl = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(Bartleby.randomStringWithLength(6) + ".kvs");
    let _kvs = BsyncKeyValueStorage(url: BsyncKeyValueStorageTests._kvsUrl)
    let _fm = NSFileManager()
    
    override static func setUp() {
        super.setUp()
        
        Bartleby.sharedInstance.configureWith(TestsConfiguration)
    }
    
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
        XCTAssertFalse(_fm.fileExistsAtPath(BsyncKeyValueStorageTests._kvsUrl.path!))
        let user = User()
        user.creatorUID = user.UID
        user.spaceUID = BsyncKeyValueStorageTests._spaceUID
        BsyncKeyValueStorageTests._userID = user.UID
        _kvs["user1"] = user
    }
    
    func test102_Upsert2() {
        XCTAssertTrue(_fm.fileExistsAtPath(BsyncKeyValueStorageTests._kvsUrl.path!))
        _kvs["key2"] = "value2"
    }

    func test103_Upsert3() {
        _kvs["key3"] = "value3"
    }
    
    func test104_ReadUser() {
        if let user = _kvs["user1"] as? User {
            XCTAssertEqual(user.UID, BsyncKeyValueStorageTests._userID)
            XCTAssertEqual(user.spaceUID, BsyncKeyValueStorageTests._spaceUID)
        } else {
            XCTFail("Error retrieving user1")
        }
    }
    
//    func test105_ReadString() {
//        if let value2 = _kvs["value2"] as? String {
//            XCTAssertEqual(value2, "value2")
//        } else {
//            XCTFail("Error retrieving value2")
//        }
//    }
    
    func test106_Delete() {
        _kvs.delete("user1")
    }
    
    func test106_ReadAfterDelete_ShouldFail() {
        if let _ = _kvs["user1"] {
            XCTFail("The key \"user1\" should have been deleted")
        }
    }
    
    func test107_Enumerate() {
        let all = _kvs.enumerate()
        XCTAssertEqual(all.count, 2)
    }
    
    func test108_RemoveAll() {
        do {
            try _kvs.removeAll()
            XCTAssertFalse(_fm.fileExistsAtPath(BsyncKeyValueStorageTests._kvsUrl.path!))
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test109_EnumerateAfterRemoveAll() {
        let kvs = BsyncKeyValueStorage(url: BsyncKeyValueStorageTests._kvsUrl)
        XCTAssertFalse(_fm.fileExistsAtPath(BsyncKeyValueStorageTests._kvsUrl.path!))

        do {
            try kvs.open()
        } catch {
            XCTFail("\(error)")
        }
        XCTAssertEqual(0, kvs.enumerate().count)
    }
    
//    func test110_SerializableString() {
//        let s1 = "Rocinante"
//        let data1 = s1.serialize()
//        if let s2 = JSerializer.deserialize(data1) as? String {
//            XCTAssertEqual(s2, s1)
//        } else {
//            XCTFail("Serialization error")
//        }
//    }
}
