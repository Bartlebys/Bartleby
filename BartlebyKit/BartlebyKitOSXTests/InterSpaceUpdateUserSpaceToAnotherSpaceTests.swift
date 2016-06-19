//
//  InterSpaceUpdateUserSpaceToAnotherSpaceTests.swift
//  BartlebyKit
//
//  Created by Martin Delille on 04/04/2016.
//
//

import XCTest

import BartlebyKit

class InterSpaceUpdateUserSpaceToAnotherSpaceTests: TestCase {
    
    private static var _spaceA = Default.NO_UID
    private static var _spaceB = Default.NO_UID
    private static let _emailA="\(Bartleby.randomStringWithLength(5))@lylo.tv"
    private static let _passwordA=Bartleby.randomStringWithLength(6)
    private static var _userIDA: String = Default.NO_UID
    private static var _userA: User?

    // We need a real local document to login.
    static let document1:BartlebyDocument=BartlebyDocument()
    static let document2:BartlebyDocument=BartlebyDocument()

    // MARK: 1 - User creation

    override class func setUp() {
        super.setUp()
        Bartleby.sharedInstance.configureWith(TestsConfiguration)

        InterSpaceUpdateUserSpaceToAnotherSpaceTests.document1.configureSchema()
        Bartleby.sharedInstance.declare(InterSpaceUpdateUserSpaceToAnotherSpaceTests.document1)
        InterSpaceUpdateUserSpaceToAnotherSpaceTests.document1.registryMetadata.identificationMethod=RegistryMetadata.IdentificationMethod.Key
        InterSpaceUpdateUserSpaceToAnotherSpaceTests._spaceA = InterSpaceUpdateUserSpaceToAnotherSpaceTests.document1.spaceUID

        InterSpaceUpdateUserSpaceToAnotherSpaceTests.document2.configureSchema()
        Bartleby.sharedInstance.declare(InterSpaceTests.document2)
        InterSpaceUpdateUserSpaceToAnotherSpaceTests.document2.registryMetadata.identificationMethod=RegistryMetadata.IdentificationMethod.Key
        InterSpaceUpdateUserSpaceToAnotherSpaceTests._spaceB = InterSpaceUpdateUserSpaceToAnotherSpaceTests.document2.spaceUID
    }



    func test101_createUserA() {
        let expectation = expectationWithDescription("CreateUser should respond")

        let user=User()
        user.email=InterSpaceUpdateUserSpaceToAnotherSpaceTests._emailA
        user.verificationMethod = .ByEmail
        user.creatorUID=user.UID // (!) Auto creation in this context (Check ACL)
        user.password=InterSpaceUpdateUserSpaceToAnotherSpaceTests._passwordA
        user.spaceUID=InterSpaceUpdateUserSpaceToAnotherSpaceTests._spaceA// (!) VERY IMPORTANT A USER MUST BE ASSOCIATED TO A spaceUID
        InterSpaceUpdateUserSpaceToAnotherSpaceTests._userIDA=user.UID // We store the UID for future deletion
        InterSpaceUpdateUserSpaceToAnotherSpaceTests._userA=user
        CreateUser.execute(user,
                           inDataSpace:InterSpaceUpdateUserSpaceToAnotherSpaceTests._spaceA,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    // MARK: 2 - Login, update user space and logout
    func test201_LoginUserA_intoSpaceA() {

        let expectation = expectationWithDescription("LoginUser should respond")
        if let user = InterSpaceUpdateUserSpaceToAnotherSpaceTests._userA {
            // Space id is very important
            LoginUser.execute(user,

                              //inDataSpace: InterSpaceUpdateUserSpaceToAnotherSpaceTests._spaceA,
                              withPassword: InterSpaceUpdateUserSpaceToAnotherSpaceTests._passwordA,
                              sucessHandler: { () -> () in
                                expectation.fulfill()
            }) { (context) -> () in
                expectation.fulfill()
                XCTFail("Status code \(context.httpStatusCode)")
            }

            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }

    func test202_UpdateUser_SpaceA_toSpaceB_ShouldFail() {
        let expectation = expectationWithDescription("UpdateUser should respond")
        do {
            if let user = InterSpaceUpdateUserSpaceToAnotherSpaceTests._userA {
                if let clonedUser = try JSerializer.volatileDeepCopy(user) {
                    // Updating userA space
                    clonedUser.spaceUID = InterSpaceUpdateUserSpaceToAnotherSpaceTests._spaceB
                    UpdateUser.execute(clonedUser,
                                       inDataSpace: InterSpaceUpdateUserSpaceToAnotherSpaceTests._spaceA,
                                       sucessHandler: { (context) in
                                        expectation.fulfill()
                                        XCTFail("User can not update its spaceId")
                    }) { (context) -> () in
                        expectation.fulfill()
                        XCTAssert(context.httpStatusCode >= 400 )
                    }

                    waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
                } else {
                    XCTFail("Invalid user")
                }
            } else {
                XCTFail("Invalid user")
            }
        } catch {
             XCTFail("\(error)")
        }
    }


    // MARK: 3 - Deletion and log out

    func test301_DeleteUserA() {
        let expectation = expectationWithDescription("DeleteUser should respond")
        DeleteUser.execute(InterSpaceUpdateUserSpaceToAnotherSpaceTests._userIDA,
                           fromDataSpace: InterSpaceUpdateUserSpaceToAnotherSpaceTests._spaceA,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("Status code \(context.httpStatusCode)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test302_LogoutUserA() {
        let expectation = expectationWithDescription("LogoutUser should respond")
        LogoutUser.execute(fromDataSpace: InterSpaceUpdateUserSpaceToAnotherSpaceTests._spaceA,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("Status code \(context.httpStatusCode)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
}
