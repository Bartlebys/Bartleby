//
//  LockerTests.swift
//  BartlebyKit
//
//  Created by Martin Delille on 25/03/2016.
//
//

import XCTest
import BartlebyKit

class LockerTests: XCTestCase {

    private static let _document = BartlebyDocument()
    private static var _spaceUID = Default.NO_UID

    private static var _creatorUser: User? {
        didSet {
            if let user = _creatorUser {
                user.creatorUID = user.UID
                user.spaceUID = LockerTests._spaceUID
                user.email = LockerTests._creatorEmail
                user.password = LockerTests._creatorUserPassword
            }
        }
    }
    private static var _creatorUserID: String="UNDEFINED"
    private static var _creatorUserPassword: String="UNDEFINED"
    private static let _creatorEmail = "Creator@LockerTests"

    private static var _consumerUser: User?
    private static var _consumerUserID: String="UNDEFINED"
    private static var _consumerUserPassword: String="UNDEFINED"
    private static let _consumerPhone = "Consumer@LockerTests"

    private static var _locker: Locker?
    private static var _lockerID: String="UNDEFINED"
    private static var _lockerCode: String="UNDEFINED"

    override static func setUp() {
        super.setUp()
        Bartleby.sharedInstance.configureWith(TestsConfiguration)
        let document=LockerTests._document
        Bartleby.sharedInstance.declare(document)
        LockerTests._spaceUID = document.spaceUID
        LockerTests._creatorUser = User()
        if let user =  LockerTests._creatorUser {
            document.registryMetadata.currentUser = user
            document.registryMetadata.creatorUID = user.UID
            document.registryMetadata.rootObjectUID = Bartleby.createUID()
        }

    }

    // MARK: 0 - Init

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


    // MARK: 1 - Creation of users and a locker

    func test101_CreateUser_Creator() {
        let expectation = expectationWithDescription("CreateUser should respond")

        if let creator=LockerTests._creatorUser {
            LockerTests._creatorUser = creator
            LockerTests._creatorUserID = creator.UID
            LockerTests._creatorUserPassword = creator.password

            CreateUser.execute(creator, inDataSpace: LockerTests._spaceUID,
                               sucessHandler: { (context) in
                                expectation.fulfill()
            }) { (context) in
                expectation.fulfill()
                XCTFail("\(context)")
            }

            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
                if let error = error {
                    bprint(error.localizedDescription)
                }
            }
        } else {
            XCTFail("Invalid user")
        }
    }

    func test102_CreateUser_Consumer() {
        let expectation = expectationWithDescription("CreateUser should respond")
        let consumer = User()
        consumer.creatorUID = LockerTests._creatorUserID
        consumer.spaceUID = LockerTests._spaceUID
        consumer.phoneNumber = LockerTests._consumerPhone

        LockerTests._consumerUser = consumer
        LockerTests._consumerUserID = consumer.UID
        LockerTests._consumerUserPassword = consumer.password

        CreateUser.execute(consumer, inDataSpace: LockerTests._spaceUID,
                           sucessHandler: { (context) in
                            expectation.fulfill()
        }) { (context) in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            if let error = error {
                bprint(error.localizedDescription)
            }
        }
    }

    func test103_LoginUser_Creator() {
        let expectation = expectationWithDescription("LoginUser should respond")
        if let user = LockerTests._creatorUser {
            user.login(withPassword: LockerTests._creatorUserPassword,
                       sucessHandler: { () -> () in
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
        } else {
            XCTFail("Invalid user")
        }
    }

    func test104_CreateLocker() {
        let expectation = expectationWithDescription("CreateLocker should respond")
        let locker = Locker()
        locker.spaceUID = LockerTests._spaceUID
        locker.creatorUID = LockerTests._creatorUserID
        locker.userUID = LockerTests._consumerUserID
        locker.verificationMethod = .Online
        LockerTests._locker = locker
        LockerTests._lockerCode = locker.code
        LockerTests._lockerID = locker.UID

        CreateLocker.execute(locker,
                             inDataSpace: LockerTests._spaceUID,
                             sucessHandler: { (context) in
                                expectation.fulfill()
        }) { (context) in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            if let error = error {
                bprint(error.localizedDescription)
            }
        }
    }

    func test105_ReadLockerById_ShouldFail_fromCreator() {
        let expectation = expectationWithDescription("ReadLockerById should respond")

        ReadLockerById.execute(fromDataSpace: LockerTests._spaceUID,
                               lockerId: LockerTests._lockerID,
                               sucessHandler: { (locker) in
                                expectation.fulfill()
                                XCTFail("Creator are not allowed to read locker")

        }) { (context) in
            expectation.fulfill()
            XCTAssertEqual(context.httpStatusCode, 403)
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            if let error = error {
                bprint(error.localizedDescription)
            }
        }
    }

    func test105_ReadLockersByIds_ShouldFail_fromCreator() {
        let expectation = expectationWithDescription("ReadLockersByIds should respond")

        let p = ReadLockersByIdsParameters()
        p.ids = [LockerTests._lockerID]

        ReadLockersByIds.execute(fromDataSpace: LockerTests._spaceUID,
                                 parameters: p,
                                 sucessHandler: { (lockers) in
                                    expectation.fulfill()
                                    XCTFail("Creator are not allowed to read locker")
            }) { (context) in
                expectation.fulfill()
                XCTAssertEqual(context.httpStatusCode, 403)
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            if let error = error {
                bprint(error.localizedDescription)
            }
        }
    }

    func test199_LogOut_Creator() {
        let expectation = expectationWithDescription("LogoutUser should respond")
        LogoutUser.execute(fromDataSpace: LockerTests._spaceUID,
                           sucessHandler: { () -> () in
                            expectation.fulfill()
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

    // MARK: 2 - Test with consumer

    func test201_LogIn_Consumer() {
        let expectation = expectationWithDescription("LoginUser should respond")

        if let consumerUser = LockerTests._consumerUser {

            // (!) TO BECOME THE MAIN USER
            LockerTests._document.registryMetadata.currentUser=consumerUser

            consumerUser.login(withPassword: LockerTests._consumerUserPassword,
                       sucessHandler: { () -> () in
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
        } else {
            XCTFail("Invalid user")
        }
    }

    func test202_ReadLockerById() {
        let expectation = expectationWithDescription("ReadLockerById should always fail")

        ReadLockerById.execute(fromDataSpace: LockerTests._spaceUID,
                               lockerId: LockerTests._lockerID,
                               sucessHandler: { (locker) in
                                expectation.fulfill()
                                XCTFail("Lockers should only be verifyed")

        }) { (context) in
            expectation.fulfill()

        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            if let error = error {
                bprint(error.localizedDescription)
            }
        }
    }


    func test203_VerifyLocker_online() {
        let expectation = expectationWithDescription("VerifyLocker should respond")

        VerifyLocker.execute(LockerTests._lockerID,
                             inDataSpace: LockerTests._spaceUID,
                             code: LockerTests._lockerCode,
                             accessGranted: { (locker) in
                                expectation.fulfill()
        }) { (context) in
            expectation.fulfill()
            XCTFail("\(context.result)")
        }

        waitForExpectationsWithTimeout(100.0) { (error) in
            if let error = error {
                bprint("Error: \(error.localizedDescription)")
            }
        }
    }

    func test299_LogOut_Consumer() {
        let expectation = expectationWithDescription("LogoutUser should respond")
        LogoutUser.execute(fromDataSpace: LockerTests._spaceUID,
                           sucessHandler: { () -> () in
                            expectation.fulfill()
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


    // MARK: 3 - Local verify locker tests



    func test302_VerifyLocker_BadCode() {
        let expectation = expectationWithDescription("VerifyLocker should respond")

        VerifyLocker.execute(LockerTests._lockerID,
                                                inDataSpace: LockerTests._spaceUID,
                                                code: "BADCOD",
                                                accessGranted: { (locker) in
                                                    expectation.fulfill()
                                                    XCTFail("Verification should fail with bad code")
        }) { (context) in
            expectation.fulfill()
            XCTAssertEqual(context.code, 1)
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            if let error = error {
                bprint("Error: \(error.localizedDescription)")
            }
        }
    }

    func test303_VerifyLocker_BadLocker() {
        let expectation = expectationWithDescription("VerifyLocker should respond")

        VerifyLocker.execute( "BADID",
                                                 inDataSpace: LockerTests._spaceUID,
                                                 code: LockerTests._lockerCode,
                                                 accessGranted: { (locker) in
                                                    expectation.fulfill()
                                                    XCTFail("Verification should fail with bad locker ID")
        }) { (context) in
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { (error) in
            if let error = error {
                bprint("Error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: 4 - Cleanup

    func test401_LoginUser_Creator() {
        let expectation = expectationWithDescription("LoginUser should respond")
        if let user = LockerTests._creatorUser {
            user.login(withPassword: LockerTests._creatorUserPassword,
                       sucessHandler: { () -> () in
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
        } else {
            XCTFail("Invalid user")
        }
    }

    func test402_DeleteLocker() {

        let expectation = expectationWithDescription("DeleteLocker should respond")

        DeleteLocker.execute(LockerTests._lockerID, fromDataSpace: LockerTests._spaceUID, sucessHandler: { (context) in
            expectation.fulfill()
        }) { (context) in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { error -> Void in
            if let error = error {
                bprint("Error: \(error.localizedDescription)")
            }
        }

    }

    func test403_DeleteUser_Consumer() {

        let expectation = expectationWithDescription("DeleteUser should respond")

        DeleteUser.execute(LockerTests._consumerUserID,
                           fromDataSpace:LockerTests._spaceUID,
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

    func test404_DeleteUser_Creator() {

        let expectation = expectationWithDescription("DeleteUser should respond")

        DeleteUser.execute(LockerTests._creatorUserID,
                           fromDataSpace:LockerTests._spaceUID,
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

    func test405_LogOut_Creator() {
        let expectation = expectationWithDescription("LogoutUser should respond")
        LogoutUser.execute(fromDataSpace: LockerTests._spaceUID,
                           sucessHandler: { () -> () in
                            expectation.fulfill()
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
