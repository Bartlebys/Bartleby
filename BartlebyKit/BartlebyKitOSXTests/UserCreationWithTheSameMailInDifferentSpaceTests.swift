//
//  UserCreationWithTheSameMailInDifferentSpaceTests.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 15/12/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import XCTest
import BartlebyKit

class UserCreationWithTheSameMailInDifferentSpaceTests: XCTestCase {

    private static var _spaceUID1 = Default.NO_UID
    private static var _spaceUID2 = Default.NO_UID
    private static let _email1="user@lylo.tv"// Same mail
    private static let _email2="user@lylo.tv"
    private static let _password1=Bartleby.randomStringWithLength(6)// Different password
    private static let _password2=Bartleby.randomStringWithLength(6)
    private static var _userID1: String = Default.NO_UID
    private static var _userID2: String = Default.NO_UID
    private static var _createdUser1: User?
    private static var _createdUser2: User?


    // We need a real local document to login.
    static let document1:BartlebyDocument=BartlebyDocument()
    static let document2:BartlebyDocument=BartlebyDocument()

    override class func setUp() {
        super.setUp()
        Bartleby.sharedInstance.configureWith(TestsConfiguration)

        UserCreationWithTheSameMailInDifferentSpaceTests.document1.configureSchema()
        Bartleby.sharedInstance.declare(UserCreationWithTheSameMailInDifferentSpaceTests.document1)
        UserCreationWithTheSameMailInDifferentSpaceTests.document1.registryMetadata.identificationMethod=RegistryMetadata.IdentificationMethod.Key
        UserCreationWithTheSameMailInDifferentSpaceTests._spaceUID1 = UserCreationWithTheSameMailInDifferentSpaceTests.document1.spaceUID

        UserCreationWithTheSameMailInDifferentSpaceTests.document2.configureSchema()
        Bartleby.sharedInstance.declare(UserCreationWithTheSameMailInDifferentSpaceTests.document2)
        UserCreationWithTheSameMailInDifferentSpaceTests.document2.registryMetadata.identificationMethod=RegistryMetadata.IdentificationMethod.Key
        UserCreationWithTheSameMailInDifferentSpaceTests._spaceUID2 = UserCreationWithTheSameMailInDifferentSpaceTests.document2.spaceUID
    }


    func test001_createUser1() {
        let expectation = expectationWithDescription("CreateUser should respond")

        let user=UserCreationWithTheSameMailInDifferentSpaceTests.document1.newUser()
        user.verificationMethod = .ByEmail
        user.email=UserCreationWithTheSameMailInDifferentSpaceTests._email1
        user.creatorUID=user.UID // (!) Auto creation in this context (Check ACL)
        user.password=UserCreationWithTheSameMailInDifferentSpaceTests._password1
        UserCreationWithTheSameMailInDifferentSpaceTests._userID1=user.UID // We store the UID for future deletion
        UserCreationWithTheSameMailInDifferentSpaceTests._createdUser1=user
        CreateUser.execute(user,
                           inRegistry:UserCreationWithTheSameMailInDifferentSpaceTests.document1.UID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("Status code \(context.httpStatusCode)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }


    func test002_deleteUser2_shouldFail() {
        let expectation = expectationWithDescription("DeleteUser should respond")
        DeleteUser.execute(UserCreationWithTheSameMailInDifferentSpaceTests._userID2,
                           fromRegistry: UserCreationWithTheSameMailInDifferentSpaceTests.document2.UID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
                            XCTFail("The user does not not exists its deletion should fail")
        }) { (context) -> () in
            expectation.fulfill()

            XCTAssertEqual(context.httpStatusCode, 403, "The ACL should block this deletion")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test003_LoginUser1() {

        let expectation = expectationWithDescription("LoginUser should respond")
        if let user = UserCreationWithTheSameMailInDifferentSpaceTests._createdUser1 {
            // Space id is very important
            LoginUser.execute(user,
                              withPassword: UserCreationWithTheSameMailInDifferentSpaceTests._password1,
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


    func test005_createUser2() {
        let expectation = expectationWithDescription("CreateUser should respond")

        let user=UserCreationWithTheSameMailInDifferentSpaceTests.document2.newUser()
        user.verificationMethod = .ByEmail
        user.email=UserCreationWithTheSameMailInDifferentSpaceTests._email2
        user.creatorUID=user.UID // (!) Auto creation in this context (Check ACL)
        user.password=UserCreationWithTheSameMailInDifferentSpaceTests._password2
        UserCreationWithTheSameMailInDifferentSpaceTests._userID2=user.UID // We store the UID for future deletion
        UserCreationWithTheSameMailInDifferentSpaceTests._createdUser2=user

        CreateUser.execute(user,
                           inRegistry:UserCreationWithTheSameMailInDifferentSpaceTests.document2.UID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("Status code \(context.httpStatusCode)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test006_deleteUser2_shouldFailAgain() {
        let expectation = expectationWithDescription("DeleteUser should respond")
        DeleteUser.execute(UserCreationWithTheSameMailInDifferentSpaceTests._userID2,
                           fromRegistry: UserCreationWithTheSameMailInDifferentSpaceTests.document2.UID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
                            XCTFail("The ACL should have blocked this deletion we are not authenticated")
        }) { (context) -> () in
            expectation.fulfill()
            XCTAssertEqual(context.httpStatusCode, 403, "The ACL should block this deletion")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test007_LoginUser2() {
        let expectation = expectationWithDescription("LoginUser should respond")
        if let user = UserCreationWithTheSameMailInDifferentSpaceTests._createdUser2 {
            // Space id is very important
            LoginUser.execute(user,
                              //inDataSpace:UserCreationWithTheSameMailInDifferentSpaceTests._spaceUID2,
                              withPassword: user.password,
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

    func test008_DeleteUser1() {
        let expectation = expectationWithDescription("DeleteUser should respond")

        DeleteUser.execute(UserCreationWithTheSameMailInDifferentSpaceTests._userID1,
                           fromRegistry: UserCreationWithTheSameMailInDifferentSpaceTests.document1.UID
            ,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("Status code \(context.httpStatusCode)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }




    func test009_DeleteUser2() {
        let expectation = expectationWithDescription("DeleteUser should respond")
        DeleteUser.execute(UserCreationWithTheSameMailInDifferentSpaceTests._userID2,
                           fromRegistry: UserCreationWithTheSameMailInDifferentSpaceTests.document2.UID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("Status code \(context.httpStatusCode)")
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }


    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }



}
