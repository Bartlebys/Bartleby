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
    
    func testCaseWillStart(testCase: XCTestCase) {
        if let name = testCase.name {
            print("\n#### \(name) ####\n")
        }
    }

    func testCase(testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        self._failureCount += 1
    }
}

class TestCase: XCTestCase {
    
    static let fm = NSFileManager.defaultManager()
    let _fm = TestCase.fm

    static var assetPath: String {
        get {
            return Bartleby.getSearchPath(.DesktopDirectory)! + NSStringFromClass(self) + "/"
        }
    }
    
    private static var _testObserver = TestObserver()
    
    override class func setUp() {
        super.setUp()
        
        // Remove asset folder if it exists
        do {
            if fm.fileExistsAtPath(assetPath) {
                try fm.removeItemAtPath(assetPath)
            }
            try fm.createDirectoryAtPath(assetPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            XCTFail("\(error)")
        }

        // Add test observer
        XCTestObservationCenter.sharedTestObservationCenter().addTestObserver(_testObserver)
        
        // Configure Bartleby
        Bartleby.sharedInstance.configureWith(TestsConfiguration)
    }
    
    override static func tearDown() {
        super.tearDown()
        
        // Remove test observer
        XCTestObservationCenter.sharedTestObservationCenter().removeTestObserver(_testObserver)
        
        // Remove asset folder depending of the configuration
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