
//
//  RangeAndStringTests.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 20/06/2017.
//
//

import BartlebyKit
import XCTest

class RangeAndStringTests: XCTestCase {
    let helloWorld = "Hello World"

    let fullRange = "Hello World".fullNSRange()

    func test_001_removeNSRange_full() {
        var h = helloWorld
        h.removeSubNSRange(fullRange)
        XCTAssert(h == "", h)
    }

    func test_002_remove_firstChar() {
        var h = helloWorld
        let r = NSRange(location: fullRange.firstLocation, length: 1)
        h.removeSubNSRange(r)
        XCTAssert(h == "ello World", h)
    }

    func test_003_remove_range_6_3() {
        var h = helloWorld
        let r = NSRange(location: 6, length: 3)
        h.removeSubNSRange(r)
        XCTAssert(h == "Hello ld", h)
    }

    func test_004_remove_lastChar() {
        var h = helloWorld
        let r = NSRange(location: fullRange.lastLocation, length: 1)
        h.removeSubNSRange(r)
        XCTAssert(h == "Hello Worl", h)
    }

    func test_005_remove_excess() {
        var h = helloWorld
        let r = NSRange(location: fullRange.lastLocation - 5, length: 100)
        h.removeSubNSRange(r)
        XCTAssert(h == "Hello", h)
    }
}
