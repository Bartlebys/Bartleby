//
//  InterSpaceTests.swift
//  BartlebyKit
//
//  Created by Martin Delille on 23/03/2016.
//
//

import XCTest
import BartlebyKit

class InterSpaceTests: XCTestCase {
    private static let _spaceUID1 = Bartleby.createUID()
    private static let _spaceUID2 = Bartleby.createUID()
    private static let _email1="email1@InterSpaceTests"
    private static let _email2="email2@InterSpaceTests"
    private static let _password1=Bartleby.randomStringWithLength(6)
    private static let _password2=Bartleby.randomStringWithLength(6)
    private static var _userID1:String="UNDEFINED"
    private static var _userID2:String="UNDEFINED"
    private static var _user1:User?
    private static var _user2:User?
    
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
    
    // MARK: 1 - Creation of two users but just login just one
    //
    // (!) If two user are logged in, interspace test may be confusing.
    
    func test101_createUser1(){
        let expectation = expectationWithDescription("CreateUser should respond")
        
        let user=User()
        user.email=InterSpaceTests._email1
        user.verificationMethod = .ByEmail
        user.creatorUID=user.UID // (!) Auto creation in this context (Check ACL)
        user.password=InterSpaceTests._password1
        user.spaceUID=InterSpaceTests._spaceUID1// (!) VERY IMPORTANT A USER MUST BE ASSOCIATED TO A spaceUID
        InterSpaceTests._userID1=user.UID // We store the UID for future deletion
        InterSpaceTests._user1=user
        CreateUser.execute(user,
                           inDataSpace:InterSpaceTests._spaceUID1,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("\(context)")
        }
        
        waitForExpectationsWithTimeout(5.0){ error -> Void in
            if let error = error {
                Bartleby.bprint("Error: \(error.localizedDescription)")
            }
        }
        
    }
    
    
    func test102_createUser2(){
        let expectation = expectationWithDescription("CreateUser should respond")
        
        let user=User()
        user.email=InterSpaceTests._email2
        user.verificationMethod = .ByEmail
        user.creatorUID=user.UID // (!) Auto creation in this context (Check ACL)
        user.password=InterSpaceTests._password2
        user.spaceUID=InterSpaceTests._spaceUID2// (!) VERY IMPORTANT A USER MUST BE ASSOCIATED TO A spaceUID
        InterSpaceTests._userID2=user.UID // We store the UID for future deletion
        InterSpaceTests._user2=user
        
        CreateUser.execute(user,
                           inDataSpace:InterSpaceTests._spaceUID2,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("Status code \(context.httpStatusCode)")
        }
        
        waitForExpectationsWithTimeout(5.0){ error -> Void in
            if let error = error {
                Bartleby.bprint("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: 2 - Login
    func test201_LoginUser1(){
        
        let expectation = expectationWithDescription("LoginUser should respond")
        if let user = InterSpaceTests._user1 {
            // Space id is very important
            LoginUser.execute(user,
                              //inDataSpace: InterSpaceTests._spaceUID1,
                withPassword: InterSpaceTests._password1,
                sucessHandler: { () -> () in
                    expectation.fulfill()
            }) { (context) -> () in
                expectation.fulfill()
                XCTFail("Status code \(context.httpStatusCode)")
            }
            
            waitForExpectationsWithTimeout(5.0){ error -> Void in
                if let error = error {
                    Bartleby.bprint("Error: \(error.localizedDescription)")
                }
            }
        } else {
            XCTFail("Invalid user")
        }
    }
    
    
    // MARK: 3 - Reading test
    
    func test301_ReadUserByID_inOtherSpace_ShouldFail(){
        let expectation = expectationWithDescription("ReadUserById should respond")
        
        ReadUserById.execute(fromDataSpace:InterSpaceTests._spaceUID2, // We try reading in the other space
            userId:InterSpaceTests._userID1,
            sucessHandler: { (user:User) -> () in
                expectation.fulfill()
                XCTFail("The user1 is not the the space2")
                
        }) { (context) -> () in
            expectation.fulfill()
            XCTAssertEqual(context.httpStatusCode, 403)
        }
        
        waitForExpectationsWithTimeout(5.0){ error -> Void in
            if let error = error {
                Bartleby.bprint("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func test302_ReadUsersByIDs_inOtherSpace_ShouldFail(){
        let expectation = expectationWithDescription("ReadUsersByIds should respond")
        
        let p=ReadUsersByIdsParameters()
        p.ids=[InterSpaceTests._userID1]
        
        ReadUsersByIds.execute(fromDataSpace:InterSpaceTests._spaceUID2, // We try reading in the other space
            parameters: p,
            sucessHandler: { (users:[User]) -> () in
                expectation.fulfill()
                XCTFail("The user1 is not the the space2")
                
        }) { (context) -> () in
            expectation.fulfill()
            XCTAssertEqual(context.httpStatusCode, 403)
        }
        
        waitForExpectationsWithTimeout(5.0){ error -> Void in
            if let error = error {
                Bartleby.bprint("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: 4 - Update test TODO
    // change space uid and try to logout and login in the new space
    func test401_LogoutUser1(){
        let expectation = expectationWithDescription("LogoutUser should respond")
        LogoutUser.execute(fromDataSpace: InterSpaceTests._spaceUID1,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("Status code \(context.httpStatusCode)")
        }
        
        waitForExpectationsWithTimeout(5.0){ error -> Void in
            if let error = error {
                Bartleby.bprint("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func test402_LoginUser_withModifiedSpaceID_ShoudFail() {
        let expectation = expectationWithDescription("LoginUser should respond")
        if let user = JSerializer.volatileDeepCopy(InterSpaceTests._user1) {
            if let user = user {
                user.spaceUID = InterSpaceTests._spaceUID2
                
                user.login(withPassword: InterSpaceTests._password1,
                           sucessHandler: {
                            expectation.fulfill()
                            XCTFail("It should be impossible to login in another space")
                }) { (context) -> () in
                    expectation.fulfill()
                    XCTAssertEqual(context.httpStatusCode, 404)
                }
                
                waitForExpectationsWithTimeout(5.0){ error -> Void in
                    if let error = error {
                        Bartleby.bprint("Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // MARK: 5 - Delete test TODO
    
    func test501_LoginUser1(){
        
        let expectation = expectationWithDescription("LoginUser should respond")
        if let user = InterSpaceTests._user1 {
            // Space id is very important
            LoginUser.execute(user,
                              //inDataSpace: InterSpaceTests._spaceUID1,
                withPassword: InterSpaceTests._password1,
                sucessHandler: { () -> () in
                    expectation.fulfill()
            }) { (context) -> () in
                expectation.fulfill()
                XCTFail("Status code \(context.httpStatusCode)")
            }
            
            waitForExpectationsWithTimeout(5.0){ error -> Void in
                if let error = error {
                    Bartleby.bprint("Error: \(error.localizedDescription)")
                }
            }
        } else {
            XCTFail("Invalid user")
        }
    }

    func test502_DeleteUser2_FromOtherSpace_ShouldFail(){
        let expectation = expectationWithDescription("DeleteUser should respond")
        DeleteUser.execute(InterSpaceTests._userID2,
                           fromDataSpace: InterSpaceTests._spaceUID2,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
                            XCTFail("It should be impossible delete a user in another space")
        }) { (context) -> () in
            expectation.fulfill()
            XCTAssertEqual(context.httpStatusCode, 403)
        }
        
        waitForExpectationsWithTimeout(5.0){ error -> Void in
            if let error = error {
                Bartleby.bprint("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func test502_DeleteUser2_FromCurrentSpace_ThatIsNotInIt_ShouldFail(){
        let expectation = expectationWithDescription("DeleteUser should respond")
        DeleteUser.execute(InterSpaceTests._userID2,
                           fromDataSpace: InterSpaceTests._spaceUID1,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
                            XCTFail("It should be impossible delete a user in another space from the current space")
        }) { (context) -> () in
            expectation.fulfill()
            XCTAssertEqual(context.httpStatusCode, 403) // Maybe we should receive 404?
        }
        
        waitForExpectationsWithTimeout(5.0){ error -> Void in
            if let error = error {
                Bartleby.bprint("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: 6 - Deletion and log out
    
    func test601_DeleteUser1(){
        let expectation = expectationWithDescription("DeleteUser should respond")
        DeleteUser.execute(InterSpaceTests._userID1,
                           fromDataSpace: InterSpaceTests._spaceUID1,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("Status code \(context.httpStatusCode)")
        }
        
        waitForExpectationsWithTimeout(5.0){ error -> Void in
            if let error = error {
                Bartleby.bprint("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func test602_LogoutUser1(){
        let expectation = expectationWithDescription("LogoutUser should respond")
        LogoutUser.execute(fromDataSpace: InterSpaceTests._spaceUID1,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("Status code \(context.httpStatusCode)")
        }
        
        waitForExpectationsWithTimeout(5.0){ error -> Void in
            if let error = error {
                Bartleby.bprint("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func test603_LoginUser2(){
        let expectation = expectationWithDescription("LoginUser should respond")
        if let user = InterSpaceTests._user2 {
            // Space id is very important
            LoginUser.execute(user,
                              //inDataSpace:InterSpaceTests._spaceUID2,
                withPassword: InterSpaceTests._password2,
                sucessHandler: { () -> () in
                    expectation.fulfill()
            }) { (context) -> () in
                expectation.fulfill()
                XCTFail("Status code \(context.httpStatusCode)")
            }
            
            waitForExpectationsWithTimeout(5.0){ error -> Void in
                if let error = error {
                    Bartleby.bprint("Error: \(error.localizedDescription)")
                }
            }
        } else {
            XCTFail("Invalid user")
        }
    }
    
    func test604_DeleteUser2(){
        let expectation = expectationWithDescription("DeleteUser should respond")
        DeleteUser.execute(InterSpaceTests._userID2,
                           fromDataSpace: InterSpaceTests._spaceUID2,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("Status code \(context.httpStatusCode)")
        }
        
        waitForExpectationsWithTimeout(5.0){ error -> Void in
            if let error = error {
                Bartleby.bprint("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func test605_LogoutUser2(){
        let expectation = expectationWithDescription("LogoutUser should respond")
        LogoutUser.execute(fromDataSpace: InterSpaceTests._spaceUID2,
                           sucessHandler: { (context) -> () in
                            expectation.fulfill()
        }) { (context) -> () in
            expectation.fulfill()
            XCTFail("Status code \(context.httpStatusCode)")
        }
        
        waitForExpectationsWithTimeout(5.0){ error -> Void in
            if let error = error {
                Bartleby.bprint("Error: \(error.localizedDescription)")
            }
        }
    }
}
