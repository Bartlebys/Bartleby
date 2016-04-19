//
//  InterSpaceUpdateUserSpaceToAnotherSpaceTests.swift
//  BartlebyKit
//
//  Created by Martin Delille on 04/04/2016.
//
//

import XCTest

import BartlebyKit

class InterSpaceUpdateUserSpaceToAnotherSpaceTests: XCTestCase {
    private static let _spaceA = Bartleby.createUID()
    private static let _spaceB = Bartleby.createUID()
    private static let _emailA="\(Bartleby.randomStringWithLength(5))@lylo.tv"
    private static let _passwordA=Bartleby.randomStringWithLength(6)
    private static var _userIDA:String="UNDEFINED"
    private static var _userA:User?
    
    override static func setUp() {
        super.setUp()
        Bartleby.sharedInstance.configureWith(TestsConfiguration)
    }
    
    // MARK: 0 - Initialization
    
    func test000_purgeTheCookiesForTheDomain(){
        print("Using : \(TestsConfiguration.API_BASE_URL)")
        
        if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL){
            for cookie in cookies{
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
            }
        }
        
        if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL){
            XCTAssertTrue((cookies.count==0), "We should  have 0 cookie  #\(cookies.count)")
        }
    }
    
    // MARK: 1 - User creation
    
    func test101_createUserA(){
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
        
        waitForExpectationsWithTimeout(5.0){ error -> Void in
            if let error = error {
                bprint("Error: \(error.localizedDescription)")
            }
        }
        
    }
    
    // MARK: 2 - Login, update user space and logout
    func test201_LoginUserA_intoSpaceA(){
        
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
            
            waitForExpectationsWithTimeout(5.0){ error -> Void in
                if let error = error {
                    bprint("Error: \(error.localizedDescription)")
                }
            }
        } else {
            XCTFail("Invalid user")
        }
    }
    
    func test202_UpdateUser_SpaceA_toSpaceB_ShouldFail(){
        let expectation = expectationWithDescription("UpdateUser should respond")
        
        if let user = InterSpaceUpdateUserSpaceToAnotherSpaceTests._userA {
            if let clonedUser = JSerializer.volatileDeepCopy(user) {
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
                
                waitForExpectationsWithTimeout(5.0){ error -> Void in
                    if let error = error {
                        bprint("Error: \(error.localizedDescription)")
                    }
                }
            } else {
                XCTFail("Invalid user")
            }
        } else {
            XCTFail("Invalid user")
        }
    }
    
    
    // MARK: 3 - Deletion and log out
    
    func test301_DeleteUserA(){
        let expectation = expectationWithDescription("DeleteUser should respond")
        DeleteUser.execute(InterSpaceUpdateUserSpaceToAnotherSpaceTests._userIDA,
                           fromDataSpace: InterSpaceUpdateUserSpaceToAnotherSpaceTests._spaceA,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("Status code \(context.httpStatusCode)")
        }
        
        waitForExpectationsWithTimeout(5.0){ error -> Void in
            if let error = error {
                bprint("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func test302_LogoutUserA(){
        let expectation = expectationWithDescription("LogoutUser should respond")
        LogoutUser.execute(fromDataSpace: InterSpaceUpdateUserSpaceToAnotherSpaceTests._spaceA,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("Status code \(context.httpStatusCode)")
        }
        
        waitForExpectationsWithTimeout(5.0){ error -> Void in
            if let error = error {
                bprint("Error: \(error.localizedDescription)")
            }
        }
    }
}
