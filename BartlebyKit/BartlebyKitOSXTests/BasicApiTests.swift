//
//  BasicApiTests.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 12/11/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


import XCTest
import BartlebyKit

class BasicApiTests: TestCase {


    fileprivate static let _email="\(Bartleby.randomStringWithLength(5))@BasicApiTests"
    fileprivate static let _newEmail="\(Bartleby.randomStringWithLength(5))@BasicApiTests"
    fileprivate static let _password=Bartleby.randomStringWithLength(6)
    fileprivate static let _newPassword=Bartleby.randomStringWithLength(6)
    fileprivate static var _userID: String="UNDEFINED"
    fileprivate static var _createdUser: User?


     override class func setUp() {
        super.setUp()
    }

    // MARK: 1 - User Creation

    func test101_createUser() {
        let expectation = self.expectation(description: "CreateUser should respond")

        let user=BasicApiTests.document.newUser()
        user.email=BasicApiTests._email
        user.verificationMethod = .byEmail
        user.creatorUID=user.UID // (!) Auto creation in this context (Check ACL)
        user.password=BasicApiTests._password
        user.spaceUID=TestCase.document.spaceUID// (!) VERY IMPORTANT A USER MUST BE ASSOCIATED TO A spaceUID
        BasicApiTests._userID=user.UID // We store the UID for future deletion

        // Store the current user
        BasicApiTests._createdUser=user

        CreateUser.execute(user,
                           inDocumentWithUID:TestCase.document.UID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    // MARK: 2 - Login Logout

    func test201_LoginUser() {
        let expectation = self.expectation(description: "LoginUser should respond")
        if let user = BasicApiTests._createdUser {
            user.login(sucessHandler: { () -> () in
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


    func test202_LogoutUser() {
        let expectation = self.expectation(description: "LogoutUser should respond")
        LogoutUser.execute(BasicApiTests._createdUser!,
                           sucessHandler: { () -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    // MARK: 3 - Read User while not auth.

    func test301_ReadUserByID_ShouldFail_Because_of_Logout() {

        let expectation = self.expectation(description: "ReadUserById should respond")

        ReadUserById.execute(from: TestCase.document.UID,
                             userId:BasicApiTests._userID,
                             sucessHandler: { (user: User) -> () in
                                expectation.fulfill()
                                XCTFail("No Auth Security issue we where able to grab \(user)")
        }) { (context) -> () in
            expectation.fulfill()
            XCTAssertEqual(context.httpStatusCode, 403)
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }


    // MARK: 4 - Reauth and read

    func test401_re_LoginUser() {
        let expectation = self.expectation(description: "LoginUser should respond")
        if let user = BasicApiTests._createdUser {
            user.login(sucessHandler: { () -> () in
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


    func test402_ReadUserByID_Should_Succeed() {

        let expectation = self.expectation(description: "ReadUserById should respond")

        ReadUserById.execute(from: TestCase.document.UID,
                             userId:BasicApiTests._userID,
                             sucessHandler: { (user: User) -> () in
                                expectation.fulfill()

                                XCTAssertNotNil(user, "User should not be nil")

                                let uidMatchs=(user.UID==BasicApiTests._createdUser!.UID)
                                XCTAssertTrue(uidMatchs, "UID should match")

                                let password=user.password
                                let passwordIsMasked=(password.lengthOfBytes(using: Default.STRING_ENCODING)==0)
                                XCTAssertTrue(passwordIsMasked, "Password is masqued by filter so we should return a Random pass not a Salted one")

        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test403_ReadUsersByIds_Should_Succeed() {

        let expectation = self.expectation(description: "ReadUsersByIds should respond")
        let p=ReadUsersByIdsParameters()
        p.ids=[BasicApiTests._userID]

        ReadUsersByIds.execute(from: TestCase.document.UID, parameters: p,
                               sucessHandler: { (users: [User]) -> () in
                                expectation.fulfill()

                                if let user = users.first {
                                    let uidMatchs=(user.UID==BasicApiTests._createdUser!.UID)
                                    XCTAssertTrue(uidMatchs, "UID  should match")

                                    let passwordIsMasked=(user.password.lengthOfBytes(using: Default.STRING_ENCODING)==0)
                                    XCTAssertTrue(passwordIsMasked, "Password is masqued by filter so we should return a Random pass not a Salted one")

                                } else {
                                    XCTFail("No user found")
                                }
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test404_ReadUserByID_WithUnexistingId_ShouldFail() {

        let expectation = self.expectation(description: "ReadUserById should respond")

        ReadUserById.execute(from:TestCase.document.UID,
                             userId:"Unexisting ID",
                             sucessHandler: { (user: User) -> () in
                                expectation.fulfill()
                                XCTFail("No user should be returned since the ID doesn't exist")
        }) { (context) -> () in
            expectation.fulfill()
            XCTAssertEqual(context.httpStatusCode, 404)
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    // MARK: 5 - Update

    func test501_updateUserEmail() {

        let expectation = self.expectation(description: "UpdateUser should respond")

        let user=BasicApiTests._createdUser!
        XCTAssertNotEqual(BasicApiTests._email, BasicApiTests._newEmail, "Make sure new email is different")
        user.email=BasicApiTests._newEmail

        UpdateUser.execute(user,
                           inDocumentWithUID: TestCase.document.UID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test502_checkUserHasBeenUpdated() {
        let expectation = self.expectation(description: "ReadUserById should respond")

        ReadUserById.execute(from: TestCase.document.UID,
                             userId:BasicApiTests._userID,
                             sucessHandler: { (user: User) -> () in
                                expectation.fulfill()

                                XCTAssertNotNil(user, "User should not be nil")

                                XCTAssertEqual(user.UID, BasicApiTests._userID, "UID  should match")

                                XCTAssertEqual(user.email, BasicApiTests._newEmail, "The email should have been updated")
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test503_updateUserPassword() {

        let expectation = self.expectation(description: "UpdateUser should respond")

        let user=BasicApiTests._createdUser!
        XCTAssertNotEqual(BasicApiTests._password, BasicApiTests._newPassword, "Make sure new password is different")
        user.password=BasicApiTests._newPassword

        UpdateUser.execute(user,
                           inDocumentWithUID: TestCase.document.UID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test504_LogoutUser() {
        let expectation = self.expectation(description: "LogoutUser should respond")
         let user=BasicApiTests._createdUser!
        LogoutUser.execute( user,
                            sucessHandler: { () -> () in
                                expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test505_re_LoginUser() {
        let expectation = self.expectation(description: "LoginUser should respond")
        if let user = BasicApiTests._createdUser { // (!) Maybe we need to update the email there
            user.login(sucessHandler: { () -> () in
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



    // MARK: 6 - User Deletion

    func test601_DeleteUser() {

        let expectation = self.expectation(description: "DeleteUser should respond")

        DeleteUser.execute(BasicApiTests._createdUser!,
                           from:TestCase.document.UID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    func test602_LogoutUser() {
        let expectation = self.expectation(description: "LogoutUser should respond")
        let user=BasicApiTests._createdUser!
        LogoutUser.execute(
            user,
            sucessHandler: { () -> () in
                expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }

        waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
}
