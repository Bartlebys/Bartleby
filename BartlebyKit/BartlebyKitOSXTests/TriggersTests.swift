//
//  TriggersTests.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 01/06/2016.
//
//

import Foundation
import XCTest
import BartlebyKit


class TriggersTests: XCTestCase {

    private static let _spaceUID="TEST_DATASPACE"
    private static let _senderUID=Bartleby.createUID()
    private static let _email="\(Bartleby.randomStringWithLength(5))@TriggersTests"
    private static let _newEmail="\(Bartleby.randomStringWithLength(5))@TriggersTests"
    private static let _password=Bartleby.randomStringWithLength(6)
    private static let _newPassword=Bartleby.randomStringWithLength(6)
    private static var _userID: String="UNDEFINED"
    private static var _createdUser: User?

    override static func setUp() {
        super.setUp()
        Bartleby.sharedInstance.configureWith(TestsConfiguration)
    }

    func test000_purgeTheCookiesForTheDomain() {
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
    // MARK: 1 - User Creation

    func test100_createUser() {
        let expectation = expectationWithDescription("CreateUser should respond")

        let user=User()
        user.email=TriggersTests._email
        user.verificationMethod = .ByEmail
        user.creatorUID=user.UID // (!) Auto creation in this context (Check ACL)
        user.password=TriggersTests._password
        user.spaceUID=TriggersTests._spaceUID// (!) VERY IMPORTANT A USER MUST BE ASSOCIATED TO A spaceUID
        TriggersTests._userID=user.UID // We store the UID for future deletion

        // Store the current user
        TriggersTests._createdUser=user

        CreateUser.execute(user,
                           inDataSpace:TriggersTests._spaceUID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }


    func test101_LoginUser() {
        let expectation = expectationWithDescription("LoginUser should respond")
        if let user = TriggersTests._createdUser {
            user.login(withPassword: TriggersTests._password,
                       sucessHandler: { () -> () in
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




    func test200_createTrigger() {
        let expectation = expectationWithDescription("Create Trigger should respond")
        let trigger=Trigger()
        trigger.direction = .Outgoing
        trigger.spaceUID = TriggersTests._spaceUID
        trigger.senderUID = TriggersTests._senderUID
        trigger.upserted.append(Bartleby.createUID())
        trigger.deleted.append(Bartleby.createUID())
            CreateTrigger.execute(trigger, inDataSpace: TriggersTests._spaceUID, sucessHandler: { (context) in
                    expectation.fulfill()
                }, failureHandler: { (context) in
                    XCTFail("Status code \(context.httpStatusCode)")
            })
        waitForExpectationsWithTimeout(TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }

    func test201_createTrigger() {
        let expectation = expectationWithDescription("Create Trigger should respond")
        let trigger=Trigger()
        trigger.defineUID()
        trigger.direction = .Outgoing
        trigger.spaceUID = TriggersTests._spaceUID
        trigger.senderUID = TriggersTests._senderUID
        trigger.upserted.append(Bartleby.createUID())
        trigger.deleted.append(Bartleby.createUID())
        CreateTrigger.execute(trigger, inDataSpace: TriggersTests._spaceUID, sucessHandler: { (context) in

            expectation.fulfill()
            }, failureHandler: { (context) in
                XCTFail("Status code \(context.httpStatusCode)")
        })
        waitForExpectationsWithTimeout(TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }




    // MARK: 6 - User Deletion

    func test601_DeleteUser() {

        let expectation = expectationWithDescription("DeleteUser should respond")

        DeleteUser.execute(TriggersTests._userID,
                           fromDataSpace:TriggersTests._spaceUID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test602_LogoutUser() {
        let expectation = expectationWithDescription("LogoutUser should respond")
        LogoutUser.execute(
            fromDataSpace:TriggersTests._spaceUID,
            sucessHandler: { () -> () in
                expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }


}
