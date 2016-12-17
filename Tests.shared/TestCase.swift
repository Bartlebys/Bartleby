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
    fileprivate var _failureCount = 0

    var hasSucceeded: Bool {
        get {
            return _failureCount == 0
        }
    }

    func testCaseWillStart(_ testCase: XCTestCase) {
        if let name = testCase.name {
            print("\n#### \(name) ####\n")
        }
    }

    func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
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

    static let fm = FileManager.default
    let _fm = TestCase.fm

    static var testName = ""
    var testName = ""

    static var assetPath = ""
    var assetPath: String = ""

    fileprivate static var _creator: User? = nil
    fileprivate static var _createdUsers = [User]()

    fileprivate static var _testObserver = TestObserver()

    // We need a real local document to login.
    fileprivate static var _document:BartlebyDocument?
    static var document=_document!


    /// MARK: Behaviour after test run

    enum RemoveAssets {
        case always
        case onSuccess
        case never
    }

    static var removeAsset = RemoveAssets.onSuccess


    override class func setUp() {
        super.setUp()


        Bartleby.sharedInstance.configureWith(TestsConfiguration.self)
        TestCase._document=BartlebyDocument()
        TestCase.document.configureSchema()
        Bartleby.sharedInstance.declare(TestCase.document)
        // By default we use kvid auth.
        TestCase.document.metadata.identificationMethod=DocumentMetadata.IdentificationMethod.key

        // Initialize test case variable
        testName = NSStringFromClass(self)
        TestCase._document?.log("==========================================================",file:#file,function:#function,line:#line,category:testName,decorative:true)
        TestCase._document?.log("    \(testName)",file:#file,function:#function,line:#line,category:testName,decorative:true)
        TestCase._document?.log("    on \(TestsConfiguration.API_BASE_URL)",file:#file,function:#function,line:#line,category:testName,decorative:true)
        TestCase._document?.log("==========================================================",file:#file,function:#function,line:#line,category:testName,decorative:true)


        //        assetPath = NSTemporaryDirectory() + testName + "/"
        assetPath = Bartleby.getSearchPath(.desktopDirectory)! + "/\(testName)/"
        glog("Asset path: \(assetPath)",file:#file,function:#function,line:#line)

        // Remove asset folder if it exists
        do {
            if fm.fileExists(atPath: assetPath) {
                try fm.removeItem(atPath: assetPath)
            }
            try fm.createDirectory(atPath: assetPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            XCTFail("\(error)")
        }

        if TestsConfiguration.ENABLE_TEST_OBSERVATION{
            // Add test observer
            XCTestObservationCenter.shared().addTestObserver(_testObserver)
        }

        // Purge cookie for the domain
        if let cookies=HTTPCookieStorage.shared.cookies(for: TestsConfiguration.API_BASE_URL as URL) {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }

        if let cookies=HTTPCookieStorage.shared.cookies(for: TestsConfiguration.API_BASE_URL as URL) {
            XCTAssertTrue((cookies.count==0), "We should  have 0 cookie  #\(cookies.count)")
        }

        // Make sure created users list is clean
        _createdUsers.removeAll()
        _creator = nil
    }

    override static func tearDown() {
        super.tearDown()

        if  TestsConfiguration.ENABLE_TEST_OBSERVATION{
            // Remove test observer
            XCTestObservationCenter.shared().removeTestObserver(_testObserver)

            // Remove asset folder depending of the configuration
            if fm.fileExists(atPath: assetPath) && removeAsset != .never {
                if (removeAsset == .always) || (_testObserver.hasSucceeded) {
                    do {
                        try fm.removeItem(atPath: self.assetPath)
                    } catch {
                       TestCase._document?.log("Error: \(error)", file: #file, function: #function, line: #line)
                    }
                }
            }

        }

        // Clean stored users
        _creator = nil
        _createdUsers.removeAll()
        TestCase._document?.dumpLogsEntries({ (entry) -> Bool in
            return true
            }, fileName: NSStringFromClass(self))

         TestCase._document?.cleanUpLogs()

    }

    override func setUp() {
        testName = TestCase.testName
        assetPath = TestCase.assetPath
    }

    func waitForExpectations(_ timeout: TimeInterval = TestsConfiguration.TIME_OUT_DURATION) {
        self.waitForExpectations(timeout: timeout, handler: nil)
    }

    /**
     Helper to create user for the test class which will be stored statically
     and automatically deleted when calling its counterpart deleteCreatedUsers()

     - parameter spaceUID:  The space UID the user should be created into
     - parameter creator:   The creator (if nil, the user will be auto created)
     - parameter email:     Optional email (if nil, the random value will be kept)
     - parameter autologin: Allow to login the user right after the creation
     - parameter handlers:  The progress and completion handlers

     - returns: A User instance
     */
    func createUser(_ spaceUID: String, creator: User? = nil, email: String? = nil, autologin: Bool = false, handlers: Handlers) -> User {
        let user = TestCase.document.newObject() as User
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
            user.verificationMethod = .byEmail
            user.email = email
        }
        TestCase._createdUsers.append(user)

        // Create user on the server
        CreateUser.execute(user, in:TestCase.document.UID, sucessHandler: { (context) in

            if autologin {
                // Login if needed
                user.login( sucessHandler: {
                    handlers.on(Completion.successState())

                    }, failureHandler: { (context) in
                        glog("Autologin of \(user.UID) has failed",file:#file,function:#function,line:#line,category: Default.LOG_DEFAULT)
                        handlers.on(Completion.failureStateFromHTTPContext(context))
                })
            } else {
                handlers.on(Completion.successState())
            }
        }) { (context) in
            glog("Creation of \(user.UID) has failed",file:#file,function:#function,line:#line,category: Default.LOG_DEFAULT)
            handlers.on(Completion.failureStateFromHTTPContext(context))
        }

        // The user is returned
        return user

    }

    /**
     Delete recursively the created users

     - parameter handlers: The progress and completion handlers
     */
    fileprivate func _deleteNextUser(_ handlers: Handlers) {
        if TestCase._createdUsers.isEmpty {
            // If all users have been deleted, it means that we're almost done, let log out the creator!
            if let creator = TestCase._creator {
                creator.logout(sucessHandler: {
                    handlers.on(Completion.successState())
                    }, failureHandler: { (context) in
                        handlers.on(Completion.failureStateFromHTTPContext(context))
                })
            } else {
                handlers.on(Completion.failureState("Unable to delete users without creator", statusCode: .bad_Request))
            }
        } else {
            let user = TestCase._createdUsers.removeLast()
            DeleteUser.execute(user, from:TestCase.document.UID, sucessHandler: { (context) in
                // Delete recursively the next created user
                self._deleteNextUser(handlers)
                }, failureHandler: { (context) in
                    handlers.on(Completion.failureStateFromHTTPContext(context))
            })
        }
    }

    /**
     Delete all users created with its counterpart createUser()

     - parameter handlers: The progress and completion handlers
     */
    func deleteCreatedUsers(_ handlers: Handlers) {
        if let creator = TestCase._creator {
            // Login the creator
            creator.login( sucessHandler: {
                // Delete each user with a recursive method
                self._deleteNextUser(handlers)
                }, failureHandler: { (context) in
                    handlers.on(Completion.failureStateFromHTTPContext(context))
            })
        } else {
            handlers.on(Completion.failureState("Unable to delete users without creator", statusCode: .bad_Request))
        }
    }


    /**
     Writes a string to a given path.

     - parameter string:                    the string
     - parameter path:                      the path
     - parameter createIntermediaryFolders: if set to true the intermediary folders are created

     - throws: throws file issue
     */
    func writeStrinToPath(_ string:String,path:String,createIntermediaryFolders:Bool=true) throws -> () {
        let fileURL=URL(fileURLWithPath:path)
        let folderURL=fileURL.deletingLastPathComponent()
        if createIntermediaryFolders{
            try self._fm.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: [:])
        }
        try string.write(to: fileURL, atomically: true, encoding: Default.STRING_ENCODING)
    }
    
    
}
