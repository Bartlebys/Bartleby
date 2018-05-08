//
//  LockerTests.swift
//  BartlebyKit
//
//  Created by Martin Delille on 25/03/2016.
//
//

import BartlebyKit
import XCTest

class LockerTests: XCTestCase {
    fileprivate static let _document = BartlebyDocument()
    fileprivate static var _spaceUID = Default.NO_UID

    fileprivate static var _creatorUser: User? {
        didSet {
            if let user = _creatorUser {
                user.creatorUID = user.UID
                user.spaceUID = LockerTests._spaceUID
                user.email = LockerTests._creatorEmail
                user.password = LockerTests._creatorUserPassword
                user.status = .actived
            }
        }
    }

    fileprivate static var _creatorUserID: String = "UNDEFINED"
    fileprivate static var _creatorUserPassword: String = "UNDEFINED"
    fileprivate static let _creatorEmail = "Creator@LockerTests"

    fileprivate static var _consumerUser: User?
    fileprivate static var _consumerUserID: String = "UNDEFINED"
    fileprivate static var _consumerUserPassword: String = "UNDEFINED"
    fileprivate static let _consumerPhone = "Consumer@LockerTests"

    fileprivate static var _locker: Locker?
    fileprivate static var _lockerID: String = "UNDEFINED"
    fileprivate static var _lockerCode: String = "UNDEFINED"

    override static func setUp() {
        super.setUp()
        Bartleby.sharedInstance.configureWith(TestsConfiguration.self)
        let document = LockerTests._document
        Bartleby.sharedInstance.declare(document)
        LockerTests._spaceUID = document.spaceUID
        LockerTests._creatorUser = document.newManagedModel() as User
        if let user = LockerTests._creatorUser {
            document.metadata.configureCurrentUser(user)
        }
    }

    // MARK: 1 - Creation of users and a locker

    func test101_CreateUser_Creator() {
        let expectation = self.expectation(description: "CreateUser should respond")

        if let creator = LockerTests._creatorUser {
            LockerTests._creatorUser = creator
            LockerTests._creatorUserID = creator.UID
            LockerTests._creatorUserPassword = creator.password ?? Default.NO_PASSWORD

            CreateUser.execute(creator, in: LockerTests._document.UID,
                               sucessHandler: { _ in
                                   expectation.fulfill()
            }) { context in
                expectation.fulfill()
                XCTFail("\(context)")
            }

            waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }

    func test102_CreateUser_Consumer() {
        let expectation = self.expectation(description: "CreateUser should respond")
        let consumer = LockerTests._document.newManagedModel() as User
        consumer.creatorUID = LockerTests._creatorUserID
        consumer.spaceUID = LockerTests._spaceUID
        consumer.phoneNumber = LockerTests._consumerPhone

        LockerTests._consumerUser = consumer
        LockerTests._consumerUserID = consumer.UID
        LockerTests._consumerUserPassword = consumer.password ?? Default.NO_PASSWORD

        CreateUser.execute(consumer, in: LockerTests._document.UID,
                           sucessHandler: { _ in
                               expectation.fulfill()
        }) { context in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test103_LoginUser_Creator() {
        let expectation = self.expectation(description: "LoginUser should respond")
        if let user = LockerTests._creatorUser {
            user.login(sucessHandler: { () -> Void in
                expectation.fulfill()
            }) { (context) -> Void in
                expectation.fulfill()
                XCTFail("\(context)")
            }

            waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }

    func test104_CreateLocker() {
        let expectation = self.expectation(description: "CreateLocker should respond")
        let locker = LockerTests._document.newManagedModel() as Locker
        locker.associatedDocumentUID = LockerTests._document.UID
        locker.creatorUID = LockerTests._creatorUserID
        locker.userUID = LockerTests._consumerUserID
        locker.startDate = Date(timeIntervalSinceNow: -3600)
        locker.endDate = Date.distantFuture
        locker.verificationMethod = .online
        LockerTests._locker = locker
        LockerTests._lockerCode = locker.code
        LockerTests._lockerID = locker.UID

        CreateLocker.execute(locker,
                             in: LockerTests._document.UID,
                             sucessHandler: { _ in
                                 expectation.fulfill()
        }) { context in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test105_ReadLockerById_ShouldFail_fromCreator() {
        let expectation = self.expectation(description: "ReadLockerById should respond")

        ReadLockerById.execute(from: LockerTests._document.UID,
                               lockerId: LockerTests._lockerID,
                               sucessHandler: { _ in
                                   expectation.fulfill()
                                   XCTFail("Creator are not allowed to read locker")

        }) { context in
            expectation.fulfill()
            XCTAssertEqual(context.httpStatusCode, 403)
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test105_ReadLockersByIds_ShouldFail_fromCreator() {
        let expectation = self.expectation(description: "ReadLockersByIds should respond")

        let p = ReadLockersByIdsParameters()
        p.ids = [LockerTests._lockerID]

        ReadLockersByIds.execute(from: LockerTests._document.UID,
                                 parameters: p,
                                 sucessHandler: { _ in
                                     expectation.fulfill()
                                     XCTFail("Creator are not allowed to read locker")
        }) { context in
            expectation.fulfill()
            XCTAssertEqual(context.httpStatusCode, 403)
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test199_LogOut_Creator() {
        let expectation = self.expectation(description: "LogoutUser should respond")
        LogoutUser.execute(LockerTests._creatorUser!,
                           sucessHandler: { () -> Void in
                               expectation.fulfill()
        }) { (context) -> Void in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    // MARK: 2 - Test with consumer

    func test201_LogIn_Consumer() {
        let expectation = self.expectation(description: "LoginUser should respond")

        if let consumerUser = LockerTests._consumerUser {
            // (!) TO BECOME THE MAIN USER
            LockerTests._document.metadata.configureCurrentUser(consumerUser)

            consumerUser.login(sucessHandler: { () -> Void in
                expectation.fulfill()
            }) { (context) -> Void in
                expectation.fulfill()
                XCTFail("\(context)")
            }

            waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }

    func test202_ReadLockerById() {
        let expectation = self.expectation(description: "ReadLockerById should always fail")

        ReadLockerById.execute(from: LockerTests._document.UID,
                               lockerId: LockerTests._lockerID,
                               sucessHandler: { _ in
                                   expectation.fulfill()
                                   XCTFail("Lockers should only be verifyed")

        }) { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test203_VerifyLocker_online() {
        let expectation = self.expectation(description: "VerifyLocker should respond")

        VerifyLocker.execute(LockerTests._lockerID,
                             inDocumentWithUID: LockerTests._document.UID,
                             code: LockerTests._lockerCode,
                             accessGranted: { _ in
                                 expectation.fulfill()
        }) { context in
            expectation.fulfill()
            XCTFail("\(String(describing: context.responseString))")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test299_LogOut_Consumer() {
        let expectation = self.expectation(description: "LogoutUser should respond")
        LogoutUser.execute(LockerTests._consumerUser!,
                           sucessHandler: { () -> Void in
                               expectation.fulfill()
        }) { (context) -> Void in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    // MARK: 3 - Local verify locker tests

    func test302_VerifyLocker_BadCode() {
        let expectation = self.expectation(description: "VerifyLocker should respond")

        VerifyLocker.execute(LockerTests._lockerID,
                             inDocumentWithUID: LockerTests._document.UID,
                             code: "BADCOD",
                             accessGranted: { _ in
                                 expectation.fulfill()
                                 XCTFail("Verification should fail with bad code")
        }) { context in
            expectation.fulfill()
            XCTAssertEqual(context.code, 1)
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test303_VerifyLocker_BadLocker() {
        let expectation = self.expectation(description: "VerifyLocker should respond")

        VerifyLocker.execute("BADID",
                             inDocumentWithUID: LockerTests._document.UID,
                             code: LockerTests._lockerCode,
                             accessGranted: { _ in
                                 expectation.fulfill()
                                 XCTFail("Verification should fail with bad locker ID")
        }) { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    // MARK: 4 - Cleanup

    func test401_LoginUser_Creator() {
        let expectation = self.expectation(description: "LoginUser should respond")
        if let user = LockerTests._creatorUser {
            user.login(sucessHandler: { () -> Void in
                expectation.fulfill()
            }) { (context) -> Void in
                expectation.fulfill()
                XCTFail("\(context)")
            }

            waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }

    func test402_DeleteLocker() {
        if LockerTests._locker == nil {
            XCTFail("LockerTests._locker is void")
        } else {
            let expectation = self.expectation(description: "DeleteLocker should respond")

            DeleteLocker.execute(LockerTests._locker!, from: LockerTests._document.UID, sucessHandler: { _ in
                expectation.fulfill()
            }) { context in
                expectation.fulfill()
                XCTFail("\(context)")
            }

            waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        }
    }

    func test403_DeleteUser_Consumer() {
        let expectation = self.expectation(description: "DeleteUser should respond")

        DeleteUser.execute(LockerTests._consumerUser!,
                           from: LockerTests._document.UID,
                           sucessHandler: { (_) -> Void in
                               expectation.fulfill()
        }) { (context) -> Void in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test404_DeleteUser_Creator() {
        let expectation = self.expectation(description: "DeleteUser should respond")

        DeleteUser.execute(LockerTests._creatorUser!,
                           from: LockerTests._document.UID,
                           sucessHandler: { (_) -> Void in
                               expectation.fulfill()
        }) { (context) -> Void in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test405_LogOut_Creator() {
        let expectation = self.expectation(description: "LogoutUser should respond")
        LogoutUser.execute(LockerTests._creatorUser!,
                           sucessHandler: { () -> Void in
                               expectation.fulfill()
        }) { (context) -> Void in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
}
