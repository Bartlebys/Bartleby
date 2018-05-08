//
//  AuthCookiesTests.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 12/11/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import BartlebyKit
import XCTest

class AuthCookiesTests: XCTestCase {
    fileprivate static let _email = "\(Bartleby.randomStringWithLength(6))@AuthCookiesTests"
    fileprivate static let _password = Bartleby.randomStringWithLength(6)
    fileprivate static var _userID: String = "UNDEFINED"
    fileprivate static var _createdUser: User?

    // We need a real local document to login.
    static let document: BartlebyDocument = BartlebyDocument()

    override class func setUp() {
        super.setUp()
        Bartleby.sharedInstance.configureWith(TestsConfiguration.self)
        AuthCookiesTests.document.configureSchema()
        Bartleby.sharedInstance.declare(AuthCookiesTests.document)
        AuthCookiesTests.document.metadata.identificationMethod = DocumentMetadata.IdentificationMethod.cookie

        // Purge cookie for the domain
        if let cookies = HTTPCookieStorage.shared.cookies(for: TestsConfiguration.API_BASE_URL) {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }

    // MARK: - User Creation

    func test001_createUser() {
        let expectation = self.expectation(description: "CreateUser should respond")
        let user = AuthCookiesTests.document.newManagedModel() as User
        user.email = AuthCookiesTests._email
        user.verificationMethod = .byEmail
        user.creatorUID = user.UID // (!) Auto creation in this context (Check ACL)
        user.password = AuthCookiesTests._password
        AuthCookiesTests._userID = user.UID // We store the UID for future deletion

        // Store the current user
        AuthCookiesTests._createdUser = user
        CreateUser.execute(user,
                           in: AuthCookiesTests.document.UID,
                           sucessHandler: { (_) -> Void in
                               expectation.fulfill()
        }) { (context) -> Void in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test002_LoginUser() {
        let expectation = self.expectation(description: "LoginUser should respond")
        if let user = AuthCookiesTests._createdUser {
            user.login(sucessHandler: { () -> Void in
                expectation.fulfill()

                if let cookies = HTTPCookieStorage.shared.cookies(for: TestsConfiguration.API_BASE_URL) {
                    XCTAssertTrue((cookies.count > 0), "We should  have one cookie  #\(cookies.count)")
                } else {
                    XCTFail("Auth requires a cookie")
                }

            }) { (context) -> Void in
                expectation.fulfill()
                XCTFail("\(context)")
            }

            waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }

    func test003_LogoutUser() {
        let expectation = self.expectation(description: "LogoutUser should respond")
        LogoutUser.execute(AuthCookiesTests._createdUser!,
                           sucessHandler: { () -> Void in
                               expectation.fulfill()
                               if let cookies = HTTPCookieStorage.shared.cookies(for: TestsConfiguration.API_BASE_URL) {
                                   XCTAssertTrue((cookies.count == 0), "We should not have any cookie set found #\(cookies.count)")
                               }
        }) { (context) -> Void in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test004_LoginUser() {
        let expectation = self.expectation(description: "LoginUser should respond")
        if let user = AuthCookiesTests._createdUser {
            user.login(sucessHandler: { () -> Void in
                expectation.fulfill()

                if let cookies = HTTPCookieStorage.shared.cookies(for: TestsConfiguration.API_BASE_URL) {
                    XCTAssertTrue((cookies.count > 0), "We should  have at least one cookie  #\(cookies.count)")
                } else {
                    XCTFail("Auth requires a cookie")
                }
            }) { (context) -> Void in
                expectation.fulfill()
                XCTFail("\(context)")
            }

            waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }

    func test008_DeleteUser() {
        let expectation = self.expectation(description: "DeleteUser should respond")

        DeleteUser.execute(AuthCookiesTests._createdUser!,
                           from: AuthCookiesTests.document.UID,
                           sucessHandler: { (_) -> Void in
                               expectation.fulfill()
        }) { (context) -> Void in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test009_LogoutUser() {
        let expectation = self.expectation(description: "LogoutUser should respond")
        LogoutUser.execute(AuthCookiesTests._createdUser!,
                           sucessHandler: { () -> Void in
                               expectation.fulfill()
                               if let cookies = HTTPCookieStorage.shared.cookies(for: TestsConfiguration.API_BASE_URL) {
                                   XCTAssertTrue((cookies.count == 0), "We should not have any cookie set found #\(cookies.count)")
                               }
        }) { (context) -> Void in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
}
