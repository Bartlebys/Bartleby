//
//  AccessControlTests.swift
//  BartlebyKit
//
//  Created by Martin Delille on 21/03/2016.
//
//

import XCTest
import BartlebyKit

class AccessControlTests: TestCase {
    private static let _spaceUID = Bartleby.createUID()
    
    private static let _creatorEmail="Creator@AccessControlTests"
    private static var _creatorUserID: String="UNDEFINED"
    private static var _creatorUser: User?
    
    private static let _otherUserEmail="OtherUser@AccessControlTests"
    private static var _otherUserID: String="UNDEFINED"
    private static var _otherUser: User?
    
    private static let _thirdUserEmail="ThirdUser@AccessControlTests"
    private static let _thirdUserNewEmail="ThirdUserNewEmail@lylo.tv"
    private static var _thirdUserID: String="UNDEFINED"
    private static var _thirdUser: User?
    
    // MARK: 1 - Creator actions
    func test101_createUser_Creator() {
        let expectation = expectationWithDescription("CreateUser should respond")
        
        let user = self.createUser(AccessControlTests._spaceUID,
                                   email: AccessControlTests._creatorEmail,
                                   handlers: Handlers { (create) in
                                    expectation.fulfill()
                                    XCTAssert(create.success, create.message)
            })
        
        // Store the current user
        AccessControlTests._creatorUser = user
        AccessControlTests._creatorUserID = user.UID // We store the UID for future deletion
        
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test102_Login_Creator() {
        let expectation = expectationWithDescription("LoginUser should respond")
        if let creator = AccessControlTests._creatorUser {
            creator.login(withPassword: creator.password,
                          sucessHandler: {
                            expectation.fulfill()
                            if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL) {
                                XCTAssertTrue((cookies.count>0), "We should  have one cookie  #\(cookies.count)")
                            } else {
                                XCTFail("Auth requires a cookie")
                            }
            }) { (context) -> () in
                expectation.fulfill()
                XCTFail("\(context)")
            }
            
            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }
    
    func test103_CreateUser_OtherUser() {
        if let creator = AccessControlTests._creator {
            let expectation = expectationWithDescription("CreateUser should respond")
            
            let user = self.createUser(AccessControlTests._spaceUID,
                                       creator: creator,
                                       email: AccessControlTests._otherUserEmail,
                                       handlers: Handlers { (create) in
                                        expectation.fulfill()
                                        XCTAssert(create.success, create.message)
                })
            
            // Store the current user
            AccessControlTests._otherUserID=user.UID // We store the UID for future deletion
            AccessControlTests._otherUser = user
            
            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Bad creator")
        }
    }
    
    func test104_CreateUser_ThirdUser() {
        if let creator = AccessControlTests._creator {
            let expectation = expectationWithDescription("CreateUser should respond")
            
            let user = self.createUser(AccessControlTests._spaceUID,
                                       creator: creator,
                                       email: AccessControlTests._thirdUserEmail,
                                       handlers: Handlers { (create) in
                                        expectation.fulfill()
                                        XCTAssert(create.success, create.message)
                })
            
            // Store the current user
            AccessControlTests._thirdUser = user
            AccessControlTests._thirdUserID=user.UID // We store the UID for future deletion
            
            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Bad creator")
        }
    }
    
    func test105_ReadUserByID_byCreator_ShouldNotRetrievePassword() {
        
        let expectation = expectationWithDescription("ReadUserById replay")
        
        ReadUserById.execute(fromDataSpace:AccessControlTests._spaceUID,
                             userId:AccessControlTests._otherUserID,
                             sucessHandler: { (user: User) -> () in
                                expectation.fulfill()
                                XCTAssertEqual(user.email, AccessControlTests._otherUserEmail, "Creator can retrieve a user email")
                                XCTAssertEqual(user.password, "", "Creator cannot retrieve a user password")
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { error -> Void in
            if let error = error {
                bprint("Error: \(error.localizedDescription)", file: #file, function: #function, line: #line)
            }
        }
    }
    
    func test106_UpdateUser_ThirdUserEmail_byCreator() {
        
        let expectation = expectationWithDescription("UpdateUser should respond")
        
        if let user=AccessControlTests._thirdUser {
            user.status=User.Status.Suspended
            XCTAssertNotEqual(AccessControlTests._thirdUserEmail, AccessControlTests._thirdUserNewEmail, "Make sure new email is different")
            user.email=AccessControlTests._thirdUserNewEmail
            
            UpdateUser.execute(user,
                               inDataSpace:AccessControlTests._spaceUID,
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
    
    func test107_Check_ThirdUserEmail_HasBeenUpdated() {
        let expectation = expectationWithDescription("ReadUserById should respond")
        
        ReadUserById.execute(fromDataSpace:AccessControlTests._spaceUID,
                             userId: AccessControlTests._thirdUserID,
                             sucessHandler: { (user: User) -> () in
                                expectation.fulfill()
                                
                                XCTAssertNotNil(user, "User should not be nil")
                                
                                XCTAssertEqual(user.UID, AccessControlTests._thirdUserID, "UID  should match")
                                
                                XCTAssertEqual(user.email, AccessControlTests._thirdUserNewEmail, "The email should have been updated")
                                XCTAssertEqual(user.status, User.Status.Suspended, "The status should have been updated")
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { error -> Void in
            if let error = error {
                bprint("Error: \(error.localizedDescription)", file: #file, function: #function, line: #line)
            }
        }
    }
    
    func test108_DeleteUser_UnexistingUser_ShouldFail() {
        
        let expectation = expectationWithDescription("DeleteUser should respond")
        
        DeleteUser.execute("unexisting id",
                           fromDataSpace:  AccessControlTests._spaceUID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
                            XCTFail("The user does not not exists its deletion should fail")
        }) { (context) -> () in
            expectation.fulfill()
            XCTAssertEqual(context.httpStatusCode, 403)
        }
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test199_LogoutUser_Creator() {
        let expectation = expectationWithDescription("LogoutUser should respond")
        LogoutUser.execute(fromDataSpace: AccessControlTests._spaceUID,
                           sucessHandler: { () -> () in
                            expectation.fulfill()
                            if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL) {
                                XCTAssertTrue((cookies.count==0), "We should not have any cookie set found #\(cookies.count)")
                            }
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    // MARK: 2 - Other user action
    func test201_LoginUser_OtherUser() {
        let expectation = expectationWithDescription("LoginUser should respond")
        if let user = AccessControlTests._otherUser {
            user.login(withPassword: user.password,
                       sucessHandler: { () -> () in
                        expectation.fulfill()
                        
                        if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL) {
                            XCTAssertTrue((cookies.count>0), "We should  have one cookie  #\(cookies.count)")
                        } else {
                            XCTFail("Auth requires a cookie")
                        }
                        
            }) { (context) ->() in
                expectation.fulfill()
                XCTFail("\(context)")
            }
            
            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }
    
    func test202_ReadUserByID_Creator_byOtherUser_ShouldNotRetrievePassword() {
        let expectation = expectationWithDescription("ReadUserById should respond")
        
        ReadUserById.execute(fromDataSpace:AccessControlTests._spaceUID,
                             userId:AccessControlTests._creatorUserID,
                             sucessHandler: { (user: User) -> () in
                                expectation.fulfill()
                                
                                XCTAssertEqual(user.email, AccessControlTests._creatorEmail, "Other user can retrieve its creator email")
                                XCTAssertEqual(user.password, "", "Other user cannot retrieve its creator password")
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test203_DeleteUser_Creator_byOtherUser_ShouldFail() {
        let expectation = expectationWithDescription("DeleteUser should respond")
        
        DeleteUser.execute(AccessControlTests._creatorUserID,
                           fromDataSpace: AccessControlTests._spaceUID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
                            XCTFail("Other user cannot delete its creator")
        }) { (context) -> () in
            expectation.fulfill()
            XCTAssertEqual(context.httpStatusCode, 403)
        }
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test204_DeleteUser_ThirdUser_byOtherUser_ShouldFail() {
        let expectation = expectationWithDescription("DeleteUser should respond")
        
        DeleteUser.execute(AccessControlTests._thirdUserID,
                           fromDataSpace: AccessControlTests._spaceUID,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
                            XCTFail("Other user cannot delete third user")
        }) { (context) -> () in
            expectation.fulfill()
            XCTAssertEqual(context.httpStatusCode, 403)
        }
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    func test205_UpdateUser_Creator_byOtherUser_ShouldFail() {
        let expectation = expectationWithDescription("UpdateUser should respond")
        
        if let user = AccessControlTests._creatorUser {
            user.email = "badmail@lylo.tv"
            
            UpdateUser.execute(user, inDataSpace: AccessControlTests._spaceUID,
                               sucessHandler: { (context) -> () in
                                expectation.fulfill()
                                XCTFail("Other user cannot update the document owner")
            }) { (context) -> () in
                expectation.fulfill()
                XCTAssertEqual(context.httpStatusCode, 403)
                // restore email
                user.email = AccessControlTests._creatorEmail
            }
            
            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }
    
    func test206_UpdateUser_ThirdUser_byOtherUser_ShouldFail() {
        let expectation = expectationWithDescription("UpdateUser should respond")
        
        if let user = AccessControlTests._thirdUser {
            user.email = "otherbadmail@lylo.tv"
            
            UpdateUser.execute(user, inDataSpace: AccessControlTests._spaceUID,
                               sucessHandler: { (context) -> () in
                                expectation.fulfill()
                                XCTFail("Other user cannot update third user")
            }) { (context) -> () in
                expectation.fulfill()
                XCTAssertEqual(context.httpStatusCode, 403)
                // restore email
                user.email = AccessControlTests._thirdUserEmail
            }
            
            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }
    
    func test299_LogoutUser_OtherUser() {
        let expectation = expectationWithDescription("LogoutUser should respond")
        LogoutUser.execute(fromDataSpace: AccessControlTests._spaceUID,
                           sucessHandler: { () -> () in
                            expectation.fulfill()
                            
                            if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL) {
                                XCTAssertTrue((cookies.count==0), "We should not have any cookie set found #\(cookies.count)")
                            }
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
    
    // MARK: 3 - Try login with suspended user
    
    func test301_LoginUser_ThirdUser_ShouldFailBecauseOfSuspend() {
        let expectation = expectationWithDescription("LoginUser should respond")
        if let user = AccessControlTests._thirdUser {
            user.login(withPassword: user.password,
                       sucessHandler: { () -> () in
                        expectation.fulfill()
                        XCTFail("LoginUser should fail because user is suspended")
            }) { (context) ->() in
                expectation.fulfill()
                XCTAssertEqual(context.httpStatusCode, 423)
            }
            
            waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } else {
            XCTFail("Invalid user")
        }
    }
    
    
    // MARK: 4 - Cleanup
    
    func test401_Delete_users() {
        let expectation = expectationWithDescription("Users should be deleted")
        self.deleteCreatedUsers(Handlers { (deletion) in
            expectation.fulfill()
            XCTAssert(deletion.success, deletion.message)
            })
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
}
