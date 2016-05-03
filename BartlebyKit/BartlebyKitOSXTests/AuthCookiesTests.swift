//
//  AuthCookiesTests.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 12/11/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import XCTest
import BartlebyKit

class AuthCookiesTests: XCTestCase {
    private static let _spaceUID = Bartleby.createUID()

    private static let _email="\(Bartleby.randomStringWithLength(6))@AuthCookiesTests"
    private static let _password=Bartleby.randomStringWithLength(6)
    private static var _userID: String="UNDEFINED"
    private static var _createdUser: User?

    override static func setUp() {
        super.setUp()
        Bartleby.sharedInstance.configureWith(TestsConfiguration)
    }

    // MARK: - User Creation

    func test000_purgeCookiesForTheDomain() {
        print("Using : \(TestsConfiguration.API_BASE_URL)")

        if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL) {
            for cookie in cookies {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
            }
        }

        if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL) {
            XCTAssertTrue((cookies.count==0), "We should  have 0 cookie  #\(cookies.count)")
        }
    }


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

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { error -> Void in
            if let error = error {
                bprint("Error: \(error.localizedDescription)")
            }
        }

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

            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { error -> Void in
                if let error = error {
                    bprint("Error: \(error.localizedDescription)")
                }
            }
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

        waitForExpectationsWithTimeout(7.0) { error -> Void in
            if let error = error {
                bprint("Error: \(error.localizedDescription)")
            }
        }
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

            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { error -> Void in
                if let error = error {
                    bprint("Error: \(error.localizedDescription)")
                }
            }
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

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { error -> Void in
            if let error = error {
                bprint("Error: \(error.localizedDescription)")
            }
        }

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

        waitForExpectationsWithTimeout(7.0) { error -> Void in
            if let error = error {
                bprint("Error: \(error.localizedDescription)")
            }
        }
    }
}
