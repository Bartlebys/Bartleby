//
//  bsyncHashMapTests.swift
//  bsync
//
//  Created by Martin Delille on 10/03/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class bsyncHashMapTests: TestCase {
    private var _sourceHashMap, _destinationHashMap: HashMap!
    private var _deltaPathMap: DeltaPathMap!

    // MARK: Set up / tear down
    override func setUp() {
        super.setUp()

        _sourceHashMap = HashMap()
        _destinationHashMap = HashMap()
        _deltaPathMap = nil
    }

    override func tearDown() {
        super.tearDown()

        _sourceHashMap = nil
        _destinationHashMap = nil
        _deltaPathMap = nil
    }

    // MARK: Basic hash map
    func testNewHashMap() {
        XCTAssertNotNil(_sourceHashMap, "A new hash map should be created")

        XCTAssertTrue(_sourceHashMap.useCompactSerialization, "A new hash map use compact serialization")
        XCTAssertTrue(_sourceHashMap.deltaPathMapWithReducedTransfer, "A new hash map try to reduce the operation")
        XCTAssertEqual(_sourceHashMap.count(), 0, "A new hash map should be empty")
    }

    func testSetSyncHash() {
        _sourceHashMap.setSyncHash("aaa", forPath: "/path/to/a")

        XCTAssertEqual(_sourceHashMap.hashForPath("/path/to/a"), "aaa")
        XCTAssertEqual(_sourceHashMap.pathsForHash("aaa"), [])

        _sourceHashMap.useCompactSerialization = false

        XCTAssertEqual(_sourceHashMap.pathsForHash("aaa"), ["/path/to/a"])
    }

    // MARK: Simple delta map test
    func testDeltaMapWithBadSourceAndDestination() {
        XCTAssertNil(_sourceHashMap.deltaPathMapWithSource(nil, andDestination: nil, withFilter: nil), "Computing delta path map with bad source or destination return nothing")
    }

    func testDeltaMapCreate() {
        _sourceHashMap.setSyncHash("aaa", forPath: "/path/to/a")

        _deltaPathMap = _sourceHashMap.deltaPathMapWithSource(_sourceHashMap, andDestination: _destinationHashMap, withFilter: nil)

        XCTAssertEqual(_deltaPathMap.createdPaths, ["/path/to/a"])
        XCTAssertEqual(_deltaPathMap.deletedPaths, [])
        XCTAssertEqual(_deltaPathMap.updatedPaths, [])
        XCTAssertEqual(_deltaPathMap.copiedPaths, [])
        XCTAssertEqual(_deltaPathMap.movedPaths, [])
    }

    func testDeltaMapDelete() {
        _destinationHashMap.setSyncHash("aaa", forPath: "/path/to/a")

        _deltaPathMap = _sourceHashMap.deltaPathMapWithSource(_sourceHashMap, andDestination: _destinationHashMap, withFilter: nil)

        XCTAssertEqual(_deltaPathMap.createdPaths, [])
        XCTAssertEqual(_deltaPathMap.deletedPaths, ["/path/to/a"])
        XCTAssertEqual(_deltaPathMap.updatedPaths, [])
        XCTAssertEqual(_deltaPathMap.copiedPaths, [])
        XCTAssertEqual(_deltaPathMap.movedPaths, [])
    }

    func testDeltaMapUpdate() {
        _sourceHashMap.setSyncHash("aaa", forPath: "/path/to/a")
        _destinationHashMap.setSyncHash("bbb", forPath: "/path/to/a")

        _deltaPathMap = _sourceHashMap.deltaPathMapWithSource(_sourceHashMap, andDestination: _destinationHashMap, withFilter: nil)

        XCTAssertEqual(_deltaPathMap.createdPaths, [])
        XCTAssertEqual(_deltaPathMap.deletedPaths, [])
        XCTAssertEqual(_deltaPathMap.updatedPaths, ["/path/to/a"])
        XCTAssertEqual(_deltaPathMap.copiedPaths, [])
        XCTAssertEqual(_deltaPathMap.movedPaths, [])
    }


    func testDeltaMapCopy() {
        _sourceHashMap.setSyncHash("aaa", forPath: "/path/to/a")
        _sourceHashMap.setSyncHash("aaa", forPath: "/path/to/b")
        _destinationHashMap.setSyncHash("aaa", forPath: "/path/to/a")

        _deltaPathMap = _sourceHashMap.deltaPathMapWithSource(_sourceHashMap, andDestination: _destinationHashMap, withFilter: nil)

        XCTAssertEqual(_deltaPathMap.createdPaths, [])
        XCTAssertEqual(_deltaPathMap.deletedPaths, [])
        XCTAssertEqual(_deltaPathMap.updatedPaths, [])
        XCTAssertEqual(_deltaPathMap.copiedPaths, [["/path/to/b", "/path/to/a"]])
        XCTAssertEqual(_deltaPathMap.movedPaths, [])
    }

    func testDeltaMapMove() {
        _sourceHashMap.setSyncHash("aaa", forPath: "/path/to/b")
        _destinationHashMap.setSyncHash("aaa", forPath: "/path/to/a")

        _deltaPathMap = _sourceHashMap.deltaPathMapWithSource(_sourceHashMap, andDestination: _destinationHashMap, withFilter: nil)

        XCTAssertEqual(_deltaPathMap.createdPaths, [])
        XCTAssertEqual(_deltaPathMap.deletedPaths, [])
        XCTAssertEqual(_deltaPathMap.updatedPaths, [])
        XCTAssertEqual(_deltaPathMap.copiedPaths, [])
        XCTAssertEqual(_deltaPathMap.movedPaths, [["/path/to/b", "/path/to/a"]])
    }

    func testDeltaCreateWithMultipleCopy() {
        _sourceHashMap.setSyncHash("aaa", forPath: "/path/to/a")
        _sourceHashMap.setSyncHash("aaa", forPath: "/path/to/b")
        _sourceHashMap.setSyncHash("aaa", forPath: "/path/to/c")

        _deltaPathMap = _sourceHashMap.deltaPathMapWithSource(_sourceHashMap, andDestination: _destinationHashMap, withFilter: nil)

        XCTAssertEqual(_deltaPathMap.createdPaths, ["/path/to/a"])
        XCTAssertEqual(_deltaPathMap.deletedPaths, [])
        XCTAssertEqual(_deltaPathMap.updatedPaths, [])
        XCTAssertEqual(_deltaPathMap.copiedPaths, [
            ["/path/to/b", "/path/to/a"],
            ["/path/to/c", "/path/to/a"]
            ])
        XCTAssertEqual(_deltaPathMap.movedPaths, [])
    }

    func testDeltaUpdateWithCopyBeforeAndAfter() {
        _destinationHashMap.setSyncHash("aaa", forPath: "/path/to/a")

        _sourceHashMap.setSyncHash("bbb", forPath: "/path/to/a")
        _sourceHashMap.setSyncHash("bbb", forPath: "/path/to/b")
        _sourceHashMap.setSyncHash("aaa", forPath: "/path/to/c")

        _deltaPathMap = _sourceHashMap.deltaPathMapWithSource(_sourceHashMap, andDestination: _destinationHashMap, withFilter: nil)

        XCTAssertEqual(_deltaPathMap.createdPaths, [])
        XCTAssertEqual(_deltaPathMap.deletedPaths, [])
        XCTAssertEqual(_deltaPathMap.updatedPaths, ["/path/to/a"])
        XCTAssertEqual(_deltaPathMap.copiedPaths, [
            ["/path/to/b", "/path/to/a"]
            ])
        XCTAssertEqual(_deltaPathMap.movedPaths, [
            ["/path/to/c", "/path/to/a"]
            ])
    }
}

extension HashMap {
    func hashForPath(path: String) -> String? {
        if let nsDict: [NSObject: AnyObject] = self.dictionaryRepresentation() {
            if let pthToH = nsDict["pthToH"] as? Dictionary<String, String> {
                return pthToH[path]
            }
        }
        return nil
    }

    func pathsForHash(hash: String) -> [String] {
        if let nsDict: [NSObject: AnyObject] = self.dictionaryRepresentation() {
            if let hToPths = nsDict["hToPths"] as? Dictionary<String, AnyObject> {
                if let paths = hToPths[hash] as? [String] {
                    return paths
                }
            }
        }
        return []
    }
}
