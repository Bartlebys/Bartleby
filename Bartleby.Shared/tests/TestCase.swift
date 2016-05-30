//
//  TestCase.swift
//  bsync
//
//  Created by Martin Delille on 27/05/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation
import XCTest

#if !USE_EMBEDDED_MODULES
    import BartlebyKit
#endif

class TestObserver: NSObject, XCTestObservation {
    private var _failureCount = 0

    var hasSucceeded: Bool {
        get {
            return _failureCount == 0
        }
    }

    func testCase(testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        self._failureCount += 1
    }
}

class TestCase: XCTestCase {
    
    static var assetPath: String {
        get {
            return Bartleby.getSearchPath(.DesktopDirectory)! + NSStringFromClass(self) + "/"
        }
    }
    
    private static var _testObserver = TestObserver()
    
    override class func setUp() {
        super.setUp()
        XCTestObservationCenter.sharedTestObservationCenter().addTestObserver(_testObserver)
    }
    
    override static func tearDown() {
        XCTestObservationCenter.sharedTestObservationCenter().removeTestObserver(_testObserver)
        let fm = NSFileManager()
        let remove = TestsConfiguration.REMOVE_ASSET_AFTER_TESTS
        if fm.fileExistsAtPath(assetPath) && remove != RemoveAssets.Never {
            if (remove == RemoveAssets.Always) || (_testObserver.hasSucceeded) {
                do {
                    try fm.removeItemAtPath(self.assetPath)
                } catch {
                    bprint("Error: \(error)", file: #file, function: #function, line: #line)
                }
            }
        }
        
    }
}