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
    private static let _spaceUID1 = Bartleby.createUID()
    private static let _spaceUID2 = Bartleby.createUID()
    private static let _email1="user@lylo.tv"// Same mail
    private static let _email2="user@lylo.tv"
    private static let _password1=Bartleby.randomStringWithLength(6)// Different password
    private static let _password2=Bartleby.randomStringWithLength(6)
    private static var _userID1:String="UNDEFINED"
    private static var _userID2:String="UNDEFINED"
    private static var _createdUser1:User?
    private static var _createdUser2:User?
    
    override static func setUp() {
        super.setUp()
        Bartleby.sharedInstance.configureWith(TestsConfiguration)
    }
        
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
    
    
    func test001_createUser1(){
        let expectation = expectationWithDescription("CreateUser should respond")
        
        let user=User()
        user.verificationMethod = .ByEmail
        user.email=UserCreationWithTheSameMailInDifferentSpaceTests._email1
        user.creatorUID=user.UID // (!) Auto creation in this context (Check ACL)
        user.password=UserCreationWithTheSameMailInDifferentSpaceTests._password1
        user.spaceUID=UserCreationWithTheSameMailInDifferentSpaceTests._spaceUID1// (!) VERY IMPORTANT A USER MUST BE ASSOCIATED TO A spaceUID
        UserCreationWithTheSameMailInDifferentSpaceTests._userID1=user.UID // We store the UID for future deletion
        UserCreationWithTheSameMailInDifferentSpaceTests._createdUser1=user
        CreateUser.execute(user,
                           inDataSpace:UserCreationWithTheSameMailInDifferentSpaceTests._spaceUID1,
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
    
    
    func test002_deleteUser2_shouldFail(){
        let expectation = expectationWithDescription("DeleteUser should respond")
        DeleteUser.execute(UserCreationWithTheSameMailInDifferentSpaceTests._userID2,
                           fromDataSpace: UserCreationWithTheSameMailInDifferentSpaceTests._spaceUID2,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
                            XCTFail("The user does not not exists its deletion should fail")
        }) { (context) -> () in
            expectation.fulfill()
            
            XCTAssertEqual(context.httpStatusCode, 403, "The ACL should block this deletion")
        }
        
        waitForExpectationsWithTimeout(5.0){ error -> Void in
            if let error = error {
                bprint("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func test003_LoginUser1(){
        
        let expectation = expectationWithDescription("LoginUser should respond")
        if let user = UserCreationWithTheSameMailInDifferentSpaceTests._createdUser1 {
            // Space id is very important
            LoginUser.execute(user,
                              //inDataSpace: UserCreationWithTheSameMailInDifferentSpaceTests._spaceUID1,
                              withPassword: UserCreationWithTheSameMailInDifferentSpaceTests._password1,
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
        }
        else {
            XCTFail("Invalid user")
        }
    }
    
    
    func test005_createUser2(){
        let expectation = expectationWithDescription("CreateUser should respond")
        
        let user=User()
        user.verificationMethod = .ByEmail
        user.email=UserCreationWithTheSameMailInDifferentSpaceTests._email2
        user.creatorUID=user.UID // (!) Auto creation in this context (Check ACL)
        user.password=UserCreationWithTheSameMailInDifferentSpaceTests._password2
        user.spaceUID=UserCreationWithTheSameMailInDifferentSpaceTests._spaceUID2// (!) VERY IMPORTANT A USER MUST BE ASSOCIATED TO A spaceUID
        UserCreationWithTheSameMailInDifferentSpaceTests._userID2=user.UID // We store the UID for future deletion
        UserCreationWithTheSameMailInDifferentSpaceTests._createdUser2=user
        
        CreateUser.execute(user,
                           inDataSpace:UserCreationWithTheSameMailInDifferentSpaceTests._spaceUID2,
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
    
    func test006_deleteUser2_shouldFailAgain(){
        let expectation = expectationWithDescription("DeleteUser should respond")
        DeleteUser.execute(UserCreationWithTheSameMailInDifferentSpaceTests._userID2,
                           fromDataSpace: UserCreationWithTheSameMailInDifferentSpaceTests._spaceUID2,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
                            XCTFail("The ACL should have blocked this deletion we are not authenticated")
        }) { (context) -> () in
            expectation.fulfill()
            XCTAssertEqual(context.httpStatusCode, 403, "The ACL should block this deletion")
        }
        
        waitForExpectationsWithTimeout(5.0){ error -> Void in
            if let error = error {
                bprint("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func test007_LoginUser2(){
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
            
            waitForExpectationsWithTimeout(5.0){ error -> Void in
                if let error = error {
                    bprint("Error: \(error.localizedDescription)")
                }
            }
        } else {
            XCTFail("Invalid user")
        }
    }
    
    func test008_DeleteUser1(){
        let expectation = expectationWithDescription("DeleteUser should respond")
        
        DeleteUser.execute(UserCreationWithTheSameMailInDifferentSpaceTests._userID1,
                           fromDataSpace: UserCreationWithTheSameMailInDifferentSpaceTests._spaceUID1,
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
    
    
    
    
    func test009_DeleteUser2(){
        let expectation = expectationWithDescription("DeleteUser should respond")
        DeleteUser.execute(UserCreationWithTheSameMailInDifferentSpaceTests._userID2,
                           fromDataSpace: UserCreationWithTheSameMailInDifferentSpaceTests._spaceUID2,
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
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    
}
