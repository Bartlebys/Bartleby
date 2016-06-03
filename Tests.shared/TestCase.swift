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

/// This test class override XCTestCase to share common test behavior between
/// Bartleby unit tests. It does the following:
///
/// - Provide a *assetPath* property creating a specific folder for the test case class
/// - Remove this *assetPath* folder depending of the configuration (See TestsConfiguration.REMOVE_ASSET_AFTER_TESTS
/// - Configure Bartleby
/// - Provide a helper method for creating users
/// - Clean all created users during static tear down
class TestCase: XCTestCase {
    
    static let fm = NSFileManager.defaultManager()
    let _fm = TestCase.fm
    
    static var _creator: User? = nil
    static var _createdUsers = [User]()
    
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
        
        // Purge cookie for the domain
        if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL) {
            for cookie in cookies {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
            }
        }
        
        if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL) {
            XCTAssertTrue((cookies.count==0), "We should  have 0 cookie  #\(cookies.count)")
        }
        
        // Make sur created users list is clean
        _createdUsers.removeAll()
        _creator = nil
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
        
        // Clean stored users
        _creator = nil
        _createdUsers.removeAll()
    }
    
    func createUser(spaceUID: String, creator: User? = nil, email: String? = nil, handlers: Handlers) -> User {
        let user = User()
        user.spaceUID = spaceUID
        if let creator = creator {
            user.creatorUID = creator.UID
        } else if let creator = TestCase._creator {
            user.creatorUID = creator.UID
        } else {
            user.creatorUID = user.creatorUID
            TestCase._creator = user
        }
        if let email = email {
            user.verificationMethod = .ByEmail
            user.email = email
        }
        
        TestCase._createdUsers.append(user)
        
        CreateUser.execute(user, inDataSpace: spaceUID, sucessHandler: { (context) in
            handlers.on(Completion.successState())
        }) { (context) in
            handlers.on(Completion.failureStateFromJHTTPResponse(context))
            
        }
        
        return user
        
    }
    
    private func _deleteNextUser(handlers: Handlers) {
        if TestCase._createdUsers.isEmpty {
            // If all users have been deleted, it means that we're almost done, let log out the creator!
            if let creator = TestCase._creator {
                creator.logout(sucessHandler: {
                    handlers.on(Completion.successState())
                    }, failureHandler: { (context) in
                        handlers.on(Completion.failureStateFromJHTTPResponse(context))
                })
            } else {
                handlers.on(Completion.failureState("Unable to delete users without creator", statusCode: .Bad_Request))
            }
        } else {
            let user = TestCase._createdUsers.removeLast()
            DeleteUser.execute(user.UID, fromDataSpace: user.spaceUID, sucessHandler: { (context) in
                // Delete recursively the next created user
                self._deleteNextUser(handlers)
                }, failureHandler: { (context) in
                    handlers.on(Completion.failureStateFromJHTTPResponse(context))
            })
        }
    }
    
    func deleteCreatedUsers(handlers: Handlers) {
        if let creator = TestCase._creator {
            // Login the creator
            creator.login(withPassword: creator.password, sucessHandler: {
                // Delete each user with a recursive method
                self._deleteNextUser(handlers)
                }, failureHandler: { (context) in
                    handlers.on(Completion.failureStateFromJHTTPResponse(context))
            })
        } else {
            handlers.on(Completion.failureState("Unable to delete users without creator", statusCode: .Bad_Request))
        }
    }
}
