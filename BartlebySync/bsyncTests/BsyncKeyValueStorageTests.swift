//
//  BsyncKeyValueStorageTests.swift
//  bsync
//
//  Created by Martin Delille on 13/04/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class BsyncKeyValueStorageTests: XCTestCase {
    private static let _kvsPath = NSTemporaryDirectory() + Bartleby.randomStringWithLength(6) + ".kvs";
    let _kvs = BsyncKeyValueStorage(filePath: BsyncKeyValueStorageTests._kvsPath)
    let _fm = NSFileManager()
    
//    override static func setUp() {
//        super.setUp()
//        
//        print(_kvsPath)
//        Bartleby.sharedInstance.configureWith(TestConfiguration)
//    }
//    
//    override func setUp() {
//        super.setUp()
//        
//        do {
//            try _kvs.open()
//        } catch {
//            XCTFail("\(error)")
//        }
//    }
//    
//    override func tearDown() {
//        super.tearDown()
//        
//        do {
//            try _kvs.save()
//        } catch {
//            XCTFail("\(error)")
//        }
//    }
//    
//    func test101_Upsert1() {
//        XCTAssertFalse(_fm.fileExistsAtPath(BsyncKeyValueStorageTests._kvsPath))
//        let user = User()
//        user.creatorUID = user.UID
//        user.spaceUID = Bartleby.createUID()
//        _kvs["user1"] = user
//    }
//    
//    func test102_Upsert2() {
//        XCTAssertTrue(_fm.fileExistsAtPath(BsyncKeyValueStorageTests._kvsPath))
//        _kvs["key2"] = "value2" as Serializable
//    }
//
//    func test103_Upsert3() {
//        _kvs["key3"] = "value3"
//    }
//    
//    func test104_Read() {
//        if let user: User = _kvs.read("user1") {
////            XCTAssertEqual(horse.name, "Rocinante")
////            XCTAssertEqual(horse.numberOfLegs, 4)
//        } else {
//            XCTFail("No value with key key1")
//        }
//    }
//    
//    func test105_Delete() {
//        _kvs.delete("user1")
//    }
//    
//    func test106_ReadAfterDelete_ShouldFail() {
//        if let _ = _kvs["horse"] {
//            XCTFail("The key \"horse\" should have been deleted")
//        }
//    }
//    
//    func test106_Enumerate() {
//        let all = _kvs.enumerate()
//        XCTAssertEqual(all.count, 2)
//        XCTAssertEqual(all[0].0, "key3")
//        XCTAssertEqual(all[0].1, "value3")
//        XCTAssertEqual(all[1].0, "key2")
//        XCTAssertEqual(all[1].1, "value2")
//    }
//    
//    func test107_RemoveAll() {
//        do {
//            try _kvs.removeAll()
//            XCTAssertFalse(_fm.fileExistsAtPath(BsyncKeyValueStorageTests._kvsPath))
//        } catch {
//            XCTFail("\(error)")
//        }
//    }
//    
//    func test108_EnumerateAfterRemoveAll() {
//        let kvs = BsyncKeyValueStorage(filePath: BsyncKeyValueStorageTests._kvsPath)
//        XCTAssertFalse(_fm.fileExistsAtPath(BsyncKeyValueStorageTests._kvsPath))
//
//        do {
//            try kvs.open()
//        } catch {
//            XCTFail("\(error)")
//        }
//        XCTAssertEqual(0, kvs.enumerate().count)
//    }
}
