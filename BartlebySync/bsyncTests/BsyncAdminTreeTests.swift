//
//  BsyncAdminTreeTests.swift
//  bsync
//
//  Created by Martin Delille on 25/05/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class BsyncAdminTreeTests: TestCase {

    private static let _user = User()
    private static let _treeName = Bartleby.randomStringWithLength(10)
    private static let _context = BsyncContext(sourceURL: NSURL(fileURLWithPath: assetPath + _treeName + "/"),
                                        andDestinationUrl: TestsConfiguration.API_BASE_URL.URLByAppendingPathComponent("BartlebySync/tree/" + _treeName),
                                        restrictedTo: nil,
                                        autoCreateTrees: false)
    private let _admin = BsyncAdmin()
    
    override static func setUp() {
        super.setUp()
        
        _user.creatorUID = _user.UID
        _user.spaceUID = TestCase.document.spaceUID
        self._context.credentials = BsyncCredentials()
        self._context.credentials?.user = _user
        self._context.credentials?.password = _user.password
        self._context.credentials?.salt = TestsConfiguration.SHARED_SALT
    }
    
//    func test100_install() {
//        let expectation = expectationWithDescription("install ok")
//        
//        _admin.installWithCompletionBlock(_context, handlers: Handlers { (install) in
//            expectation.fulfill()
//            XCTAssert(install.success, install.message)
//            })
//        
//        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
//    }
    
    func test100_createUser() {
        let expectation = expectationWithDescription("Create user")
        
        CreateUser.execute(BsyncAdminTreeTests._user, inDataSpace: TestCase.document.spaceUID, sucessHandler: { (context) in
            expectation.fulfill()
            }) { (context) in
                expectation.fulfill()
                XCTFail("\(context)")
        }
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test101_loginUser() {
        let expectation = expectationWithDescription("Login user")
        
        BsyncAdminTreeTests._user.login(withPassword: BsyncAdminTreeTests._user.password, sucessHandler: { 
            expectation.fulfill()
            }) { (context) in
                expectation.fulfill()
                XCTFail("\(context)")
        }
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test102_touchUnexistingTree() {
        let expectation = expectationWithDescription("touch")
        
        _admin.touchTreesWithCompletionBlock(BsyncAdminTreeTests._context, handlers: Handlers { (touch) in
            expectation.fulfill()
            XCTAssertFalse(touch.success, "Tree shouldn't exists")
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test103_createTree() {
        let expectation = expectationWithDescription("create")
        
        _admin.createTreesWithCompletionBlock(BsyncAdminTreeTests._context, handlers: Handlers { (create) in
            expectation.fulfill()
            XCTAssert(create.success, create.message + " with error code: \(create.statusCode)")
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test104_touchExistingTree() {
        let expectation = expectationWithDescription("touch")
        
        _admin.touchTreesWithCompletionBlock(BsyncAdminTreeTests._context, handlers: Handlers { (touch) in
            expectation.fulfill()
            XCTAssert(touch.success, touch.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    // MARK: Cleanup
    func test501_DeleteUser() {
        
        let expectation = expectationWithDescription("DeleteUser should respond")
        
        BsyncAdminTreeTests._user.logout(sucessHandler: { 
            expectation.fulfill()
            }) { (context) in
                expectation.fulfill()
                XCTFail("\(context)")
        }
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test502_LogoutUser() {
        let expectation = expectationWithDescription("LogoutUser should respond")
        LogoutUser.execute(fromDataSpace:TestCase.document.spaceUID,
                           sucessHandler: { () -> () in
                            expectation.fulfill()
                            if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL) {
                                XCTAssertTrue((cookies.count==0), "We should not have any cookie set found #\(cookies.count)")
                            }
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
}
