//
//  AuthCookiesTests.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 12/11/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import XCTest
import BartlebyKit

class AuthCookiesTests: TestCase {
    private static let _spaceUID = Bartleby.createUID()

    private static let _email="\(Bartleby.randomStringWithLength(6))@AuthCookiesTests"
    private static let _password=Bartleby.randomStringWithLength(6)
    private static var _userID: String="UNDEFINED"
    private static var _createdUser: User?

    // MARK: - User Creation

    func test001_createUser() {
        let expectation = expectationWithDescription("CreateUser should respond")

        let user=User()
        user.email=AuthCookiesTests._email
        user.verificationMethod = .ByEmail
        user.creatorUID=user.UID // (!) Auto creation in this context (Check ACL)
        user.password=AuthCookiesTests._password
        user.spaceUID=AuthCookiesTests._spaceUID// (!) VERY IMPORTANT A USER MUST BE ASSOCIATED TO A spaceUID
        AuthCookiesTests._userID=user.UID // We store the UID for future deletion

        // Store the current user
        AuthCookiesTests._createdUser=user
        CreateUser.execute(user,
                           inDataSpace:AuthCookiesTests._spaceUID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test002_LoginUser() {
        let expectation = expectationWithDescription("LoginUser should respond")
        if let user = AuthCookiesTests._createdUser {
            user.login(withPassword: AuthCookiesTests._password,
                       sucessHandler: { () -> () in
                        expectation.fulfill()

                        if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL) {
                            XCTAssertTrue((cookies.count>0), "We should  have one cookie  #\(cookies.count)")
                        } else {
                            XCTFail("Auth requires a cookie")
                        }

            }) { (context) ->() in
                expectation.fulfill()
                XCTFail("\(context)")
            }

            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }

    func test003_LogoutUser() {
        let expectation = expectationWithDescription("LogoutUser should respond")
        LogoutUser.execute(fromDataSpace: AuthCookiesTests._spaceUID,
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

    func test004_LoginUser() {
        let expectation = expectationWithDescription("LoginUser should respond")
        if let user = AuthCookiesTests._createdUser {
            user.login(withPassword: AuthCookiesTests._password,
                       sucessHandler: { () -> () in
                        expectation.fulfill()

                        if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL) {
                            XCTAssertTrue((cookies.count>0), "We should  have at least one cookie  #\(cookies.count)")
                        } else {
                            XCTFail("Auth requires a cookie")
                        }
            }) { (context) ->() in
                expectation.fulfill()
                XCTFail("\(context)")
            }

            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }


    func test008_DeleteUser() {

        let expectation = expectationWithDescription("DeleteUser should respond")

        DeleteUser.execute(AuthCookiesTests._userID,
                           fromDataSpace: AuthCookiesTests._spaceUID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test009_LogoutUser() {
        let expectation = expectationWithDescription("LogoutUser should respond")
        LogoutUser.execute(fromDataSpace:AuthCookiesTests._spaceUID,
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
