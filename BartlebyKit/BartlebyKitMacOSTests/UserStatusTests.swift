//
//  UserStatusTests.swift
//  BartlebyKit
//
//  Created by Martin Delille on 01/04/2016.
//
//

import XCTest

import BartlebyKit

class UserStatusTests: XCTestCase {

    fileprivate static var _creatorUser: User?
    fileprivate static var _creatorUserID: String="UNDEFINED"
    fileprivate static let _creatorUserEmail="Creator@UserStatusTests"
    fileprivate static let _creatorUserPassword=Bartleby.randomStringWithLength(6)

    fileprivate static var _suspendedUser: User?
    fileprivate static var _suspendedUserID: String="UNDEFINED"
    fileprivate static let _suspendedUserEmail="SuspendedUser@UserStatusTests"
    fileprivate static let _suspendedUserPassword=Bartleby.randomStringWithLength(6)


    // We need a real local document to login.
    static let document:BartlebyDocument=BartlebyDocument()


    override class func setUp() {
        super.setUp()
        Bartleby.sharedInstance.configureWith(TestsConfiguration.self)
        UserStatusTests.document.configureSchema()
        Bartleby.sharedInstance.declare(UserStatusTests.document)
        UserStatusTests.document.metadata.identificationMethod=DocumentMetadata.IdentificationMethod.cookie

        // Purge cookie for the domain
        if let cookies=HTTPCookieStorage.shared.cookies(for: TestsConfiguration.API_BASE_URL) {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
    }



    // MARK: 1 - Users Creation

    func test101_createUser_Creator() {
        let expectation = self.expectation(description: "CreateUser should respond")

        let user=UserStatusTests.document.newManagedModel() as User
        user.creatorUID=user.UID // (!) Auto creation in this context (Check ACL)
        user.email=UserStatusTests._creatorUserEmail
        user.password=UserStatusTests._creatorUserPassword

        // Store the current user and ID
        UserStatusTests._creatorUser = user
        UserStatusTests._creatorUserID = user.UID // We store the UID for future deletion

        CreateUser.execute(user,
                           in:UserStatusTests.document.UID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(String(describing: context.responseString))")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test102_createUser_UserThatWillBeSuspendedLater() {
        let expectation = self.expectation(description: "CreateUser should respond")

        let user = UserStatusTests.document.newManagedModel() as User
        user.creatorUID = UserStatusTests._creatorUserID
        user.email = UserStatusTests._suspendedUserEmail
        user.password = UserStatusTests._suspendedUserPassword

        // Store the current user and ID
        UserStatusTests._suspendedUser = user
        UserStatusTests._suspendedUserID = user.UID

        CreateUser.execute(user,
                           in:UserStatusTests.document.UID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(String(describing: context.responseString))")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    // User login/logout before suspension

    func test201_Login_UserNotSuspendedYet() {
        let expectation = self.expectation(description: "LoginUser should respond")
        if let user = UserStatusTests._suspendedUser {
            user.login(sucessHandler: {
                        expectation.fulfill()
                }) { (context) ->() in
                    expectation.fulfill()
                    XCTFail("\(context)")
            }

            waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }

    func test299_Logout_UserNotSuspendedYet() {
        let expectation = self.expectation(description: "LogoutUser should respond")
        if let user = UserStatusTests._suspendedUser {
            user.logout(sucessHandler: {
                expectation.fulfill()

                }) { (context) ->() in
                    expectation.fulfill()
                    XCTFail("\(context)")
            }

            waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }

    }

    // MARK: 3 - Creator login and update user status and logout
    func test301_Login_Creator() {
        let expectation = self.expectation(description: "LoginUser should respond")
        if let user = UserStatusTests._creatorUser {
            user.login(sucessHandler: {
                        expectation.fulfill()
                }) { (context) ->() in
                    expectation.fulfill()
                    XCTFail("\(context)")
            }

            waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }

    func test302_Update_StatusToSuspended() {

        let expectation = self.expectation(description: "UpdateUser should respond")

        if let user=UserStatusTests._suspendedUser {
            user.status = .suspended

            UpdateUser.execute(user,
                               in: UserStatusTests.document.UID,
                               sucessHandler: { (context) -> () in
                                expectation.fulfill()
            }) { (context) -> () in
                expectation.fulfill()
                XCTFail("\(context)")
            }

            waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }

    func test399_Logout_Creator() {
        let expectation = self.expectation(description: "LogoutUser should respond")
        LogoutUser.execute(UserStatusTests._creatorUser!,
                           sucessHandler: { () -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    // MARK: 4 - Try to login suspended user
    func test401_Login_SuspendedUser_ShouldFail() {
        let expectation = self.expectation(description: "LoginUser should respond")
        if let user = UserStatusTests._suspendedUser {
            user.login(sucessHandler: {
                        expectation.fulfill()
                        XCTFail("A suspended user shou")
                }) { (context) ->() in
                    expectation.fulfill()
                    XCTAssertEqual(context.httpStatusCode, 423)
            }

            waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }

    // MARK: 5 - Cleanup
    func test501_Login_Creator() {
        let expectation = self.expectation(description: "LoginUser should respond")
        if let user = UserStatusTests._creatorUser {
            user.login(sucessHandler: {
                        expectation.fulfill()
                }) { (context) ->() in
                    expectation.fulfill()
                    XCTFail("\(context)")
            }

            waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }

    func test502_Delete_SuspendedUser() {

        let expectation = self.expectation(description: "DeleteUser should respond")

        DeleteUser.execute(UserStatusTests._suspendedUser!,
                           from:UserStatusTests.document.UID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test503_Delete_Creator() {

        let expectation = self.expectation(description: "DeleteUser should respond")

        DeleteUser.execute(UserStatusTests._creatorUser!,
                           from:UserStatusTests.document.UID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test504_Logout_Creator() {
        let expectation = self.expectation(description: "LogoutUser should respond")
        if let user = UserStatusTests._creatorUser {
            user.logout(sucessHandler: {
                expectation.fulfill()
                }) { (context) ->() in
                    expectation.fulfill()
                    XCTFail("\(context)")
            }

            waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }
}
