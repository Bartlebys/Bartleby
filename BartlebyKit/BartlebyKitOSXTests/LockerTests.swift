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

    static let rootObjectUID=Bartleby.createUID()

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
        let _ = try? document.setRootObjectUID(LockerTests.rootObjectUID)
        Bartleby.sharedInstance.declare(document)
        LockerTests._spaceUID = document.spaceUID
        LockerTests._creatorUser = document.newUser()
        if let user =  LockerTests._creatorUser {
            document.registryMetadata.currentUser = user
            document.registryMetadata.creatorUID = user.UID
        }

    }

    // MARK: 1 - Creation of users and a locker

    func test101_CreateUser_Creator() {
        let expectation = expectationWithDescription("CreateUser should respond")

        if let creator=LockerTests._creatorUser {
            LockerTests._creatorUser = creator
            LockerTests._creatorUserID = creator.UID
            LockerTests._creatorUserPassword = creator.password

            CreateUser.execute(creator, inRegistryWithUID: LockerTests._document.UID,
                               sucessHandler: { (context) in
                                expectation.fulfill()
            }) { (context) in
                expectation.fulfill()
                XCTFail("\(context)")
            }

            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }

    func test102_CreateUser_Consumer() {
        let expectation = expectationWithDescription("CreateUser should respond")
        let consumer = LockerTests._document.newUser()
        consumer.creatorUID = LockerTests._creatorUserID
        consumer.spaceUID = LockerTests._spaceUID
        consumer.phoneNumber = LockerTests._consumerPhone

        LockerTests._consumerUser = consumer
        LockerTests._consumerUserID = consumer.UID
        LockerTests._consumerUserPassword = consumer.password

        CreateUser.execute(consumer, inRegistryWithUID: LockerTests._document.UID,
                           sucessHandler: { (context) in
                            expectation.fulfill()
        }) { (context) in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
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

            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
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
                             inRegistryWithUID: LockerTests._document.UID,
                             sucessHandler: { (context) in
                                expectation.fulfill()
        }) { (context) in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test105_ReadLockerById_ShouldFail_fromCreator() {
        let expectation = expectationWithDescription("ReadLockerById should respond")

        ReadLockerById.execute(fromRegistryWithUID: LockerTests._document.UID,
                               lockerId: LockerTests._lockerID,
                               sucessHandler: { (locker) in
                                expectation.fulfill()
                                XCTFail("Creator are not allowed to read locker")

        }) { (context) in
            expectation.fulfill()
            XCTAssertEqual(context.httpStatusCode, 403)
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test105_ReadLockersByIds_ShouldFail_fromCreator() {
        let expectation = expectationWithDescription("ReadLockersByIds should respond")

        let p = ReadLockersByIdsParameters()
        p.ids = [LockerTests._lockerID]

        ReadLockersByIds.execute(fromRegistryWithUID: LockerTests._document.UID,
                                 parameters: p,
                                 sucessHandler: { (lockers) in
                                    expectation.fulfill()
                                    XCTFail("Creator are not allowed to read locker")
            }) { (context) in
                expectation.fulfill()
                XCTAssertEqual(context.httpStatusCode, 403)
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test199_LogOut_Creator() {
        let expectation = expectationWithDescription("LogoutUser should respond")
        LogoutUser.execute(LockerTests._creatorUser!,
                           sucessHandler: { () -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
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

            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }

    func test202_ReadLockerById() {
        let expectation = expectationWithDescription("ReadLockerById should always fail")

        ReadLockerById.execute(fromRegistryWithUID: LockerTests._document.UID,
                               lockerId: LockerTests._lockerID,
                               sucessHandler: { (locker) in
                                expectation.fulfill()
                                XCTFail("Lockers should only be verifyed")

        }) { (context) in
            expectation.fulfill()

        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }


    func test203_VerifyLocker_online() {
        let expectation = expectationWithDescription("VerifyLocker should respond")

        VerifyLocker.execute(LockerTests._lockerID,
                             inRegistryWithUID: LockerTests._document.UID,
                             code: LockerTests._lockerCode,
                             accessGranted: { (locker) in
                                expectation.fulfill()
        }) { (context) in
            expectation.fulfill()
            XCTFail("\(context.result)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test299_LogOut_Consumer() {
        let expectation = expectationWithDescription("LogoutUser should respond")
        LogoutUser.execute(LockerTests._consumerUser!,
                           sucessHandler: { () -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }


    // MARK: 3 - Local verify locker tests



    func test302_VerifyLocker_BadCode() {
        let expectation = expectationWithDescription("VerifyLocker should respond")

        VerifyLocker.execute(LockerTests._lockerID,
                                                inRegistryWithUID: LockerTests._document.UID,
                                                code: "BADCOD",
                                                accessGranted: { (locker) in
                                                    expectation.fulfill()
                                                    XCTFail("Verification should fail with bad code")
        }) { (context) in
            expectation.fulfill()
            XCTAssertEqual(context.code, 1)
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test303_VerifyLocker_BadLocker() {
        let expectation = expectationWithDescription("VerifyLocker should respond")

        VerifyLocker.execute( "BADID",
                                                 inRegistryWithUID: LockerTests._document.UID,
                                                 code: LockerTests._lockerCode,
                                                 accessGranted: { (locker) in
                                                    expectation.fulfill()
                                                    XCTFail("Verification should fail with bad locker ID")
        }) { (context) in
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
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

            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }

    func test402_DeleteLocker() {

        let expectation = expectationWithDescription("DeleteLocker should respond")

        DeleteLocker.execute(LockerTests._lockerID, fromRegistryWithUID: LockerTests._document.UID, sucessHandler: { (context) in
            expectation.fulfill()
        }) { (context) in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test403_DeleteUser_Consumer() {

        let expectation = expectationWithDescription("DeleteUser should respond")

        DeleteUser.execute(LockerTests._consumerUserID,
                           fromRegistryWithUID:LockerTests._document.UID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test404_DeleteUser_Creator() {

        let expectation = expectationWithDescription("DeleteUser should respond")

        DeleteUser.execute(LockerTests._creatorUserID,
                           fromRegistryWithUID:LockerTests._document.UID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test405_LogOut_Creator() {
        let expectation = expectationWithDescription("LogoutUser should respond")
        LogoutUser.execute(LockerTests._creatorUser!,
                           sucessHandler: { () -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
}
