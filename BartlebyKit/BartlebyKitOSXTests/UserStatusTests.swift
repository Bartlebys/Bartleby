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
    private static let _spaceUID = Bartleby.createUID()

    private static var _creatorUser: User?
    private static var _creatorUserID: String="UNDEFINED"
    private static let _creatorUserEmail="Creator@UserStatusTests"
    private static let _creatorUserPassword=Bartleby.randomStringWithLength(6)

    private static var _suspendedUser: User?
    private static var _suspendedUserID: String="UNDEFINED"
    private static let _suspendedUserEmail="SuspendedUser@UserStatusTests"
    private static let _suspendedUserPassword=Bartleby.randomStringWithLength(6)

    override static func setUp() {
        super.setUp()

        Bartleby.sharedInstance.configureWith(TestsConfiguration)
    }

    // MARK: 1 - Users Creation

    func test101_createUser_Creator() {
        let expectation = expectationWithDescription("CreateUser should respond")

        let user=User()
        user.spaceUID=UserStatusTests._spaceUID// (!) VERY IMPORTANT A USER MUST BE ASSOCIATED TO A spaceUID
        user.creatorUID=user.UID // (!) Auto creation in this context (Check ACL)
        user.email=UserStatusTests._creatorUserEmail
        user.password=UserStatusTests._creatorUserPassword

        // Store the current user and ID
        UserStatusTests._creatorUser = user
        UserStatusTests._creatorUserID = user.UID // We store the UID for future deletion

        CreateUser.execute(user,
                           inDataSpace:UserStatusTests._spaceUID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context.response)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test102_createUser_UserThatWillBeSuspendedLater() {
        let expectation = expectationWithDescription("CreateUser should respond")

        let user = User()
        user.spaceUID = UserStatusTests._spaceUID// (!) VERY IMPORTANT A USER MUST BE ASSOCIATED TO A spaceUID
        user.creatorUID = UserStatusTests._creatorUserID
        user.email = UserStatusTests._suspendedUserEmail
        user.password = UserStatusTests._suspendedUserPassword

        // Store the current user and ID
        UserStatusTests._suspendedUser = user
        UserStatusTests._suspendedUserID = user.UID

        CreateUser.execute(user,
                           inDataSpace:UserStatusTests._spaceUID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context.response)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    // User login/logout before suspension

    func test201_Login_UserNotSuspendedYet() {
        let expectation = expectationWithDescription("LoginUser should respond")
        if let user = UserStatusTests._suspendedUser {
            user.login(withPassword: UserStatusTests._suspendedUserPassword,
                       sucessHandler: {
                        expectation.fulfill()
                }) { (context) ->() in
                    expectation.fulfill()
                    XCTFail("\(context)")
            }

            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }

    func test299_Logout_UserNotSuspendedYet() {
        let expectation = expectationWithDescription("LogoutUser should respond")
        if let user = UserStatusTests._suspendedUser {
            user.logout(sucessHandler: {
                expectation.fulfill()

                }) { (context) ->() in
                    expectation.fulfill()
                    XCTFail("\(context)")
            }

            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }

    }

    // MARK: 3 - Creator login and update user status and logout
    func test301_Login_Creator() {
        let expectation = expectationWithDescription("LoginUser should respond")
        if let user = UserStatusTests._creatorUser {
            user.login(withPassword: UserStatusTests._creatorUserPassword,
                       sucessHandler: {
                        expectation.fulfill()
                }) { (context) ->() in
                    expectation.fulfill()
                    XCTFail("\(context)")
            }

            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }

    func test302_Update_StatusToSuspended() {

        let expectation = expectationWithDescription("UpdateUser should respond")

        if let user=UserStatusTests._suspendedUser {
            user.status = .Suspended

            UpdateUser.execute(user,
                               inDataSpace: UserStatusTests._spaceUID,
                               sucessHandler: { (context) -> () in
                                expectation.fulfill()
            }) { (context) -> () in
                expectation.fulfill()
                XCTFail("\(context)")
            }

            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }

    func test399_Logout_Creator() {
        let expectation = expectationWithDescription("LogoutUser should respond")
        LogoutUser.execute(fromDataSpace: UserStatusTests._spaceUID,
                           sucessHandler: { () -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    // MARK: 4 - Try to login suspended user
    func test401_Login_SuspendedUser_ShouldFail() {
        let expectation = expectationWithDescription("LoginUser should respond")
        if let user = UserStatusTests._suspendedUser {
            user.login(withPassword: UserStatusTests._creatorUserPassword,
                       sucessHandler: {
                        expectation.fulfill()
                        XCTFail("A suspended user shou")
                }) { (context) ->() in
                    expectation.fulfill()
                    XCTAssertEqual(context.httpStatusCode, 401)
            }

            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }

    // MARK: 5 - Cleanup
    func test501_Login_Creator() {
        let expectation = expectationWithDescription("LoginUser should respond")
        if let user = UserStatusTests._creatorUser {
            user.login(withPassword: UserStatusTests._creatorUserPassword,
                       sucessHandler: {
                        expectation.fulfill()
                }) { (context) ->() in
                    expectation.fulfill()
                    XCTFail("\(context)")
            }

            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }

    func test502_Delete_SuspendedUser() {

        let expectation = expectationWithDescription("DeleteUser should respond")

        DeleteUser.execute(UserStatusTests._suspendedUserID,
                           fromDataSpace:UserStatusTests._spaceUID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test503_Delete_Creator() {

        let expectation = expectationWithDescription("DeleteUser should respond")

        DeleteUser.execute(UserStatusTests._creatorUserID,
                           fromDataSpace:UserStatusTests._spaceUID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test504_Logout_Creator() {
        let expectation = expectationWithDescription("LogoutUser should respond")
        if let user = UserStatusTests._creatorUser {
            user.logout(sucessHandler: {
                expectation.fulfill()
                }) { (context) ->() in
                    expectation.fulfill()
                    XCTFail("\(context)")
            }

            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }
}
