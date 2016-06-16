//
//  UsersCreationLoadTest.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 13/06/2016.
//
//

import XCTest
import BartlebyKit

class UsersCreationLoadTest: XCTestCase {


    static var users=[User]()
    static var document=BartlebyDocument()

    override static func setUp() {
        super.setUp()
        UsersCreationLoadTest.document=BartlebyDocument()
        UsersCreationLoadTest.document.configureSchema()
        Bartleby.sharedInstance.configureWith(TestsConfiguration.self)
    }

    override static func tearDown() {
        super.tearDown()
    }


    private func _create_a_user(completionHandler:(completionState:Completion)->()){
        let user=User()
        user.email=Bartleby.randomStringWithLength(6)+"@bartlebys.org"
        user.verificationMethod = .ByEmail
        user.creatorUID=user.UID // (!) Auto creation in this context (Check ACL)
        user.password=Bartleby.randomStringWithLength(6)
        user.spaceUID=UsersCreationLoadTest.document.spaceUID// (!) VERY IMPORTANT A USER MUST BE ASSOCIATED TO A spaceUID

        CreateUser.execute(user,
                           inDataSpace:UsersCreationLoadTest.document.spaceUID,
                           sucessHandler: { (context) -> () in
                            UsersCreationLoadTest.users.append(user)
                            completionHandler(completionState:Completion.successStateFromJHTTPResponse(context))
        }) { (context) -> () in
            completionHandler(completionState: Completion.failureStateFromJHTTPResponse(context))
        }
    }


    // MARK : Create multiple Users

    func test_001_create_login_delete_multiple_Users() {

        let expectation = expectationWithDescription("Users creation should succeed")

        func __create(){
            self._create_a_user { (completionState) in
                if UsersCreationLoadTest.users.count<100 && UsersCreationLoadTest.users.count>0{
                    __login(UsersCreationLoadTest.users.last!)
                    __create()
                }else{
                    expectation.fulfill()
                }
            }
        }

        func __login(user:User){
            LoginUser.execute(user, withPassword: user.password, sucessHandler: { 
                __delete(user)
                }) { (context) in
                    XCTFail("Login issue with \(user)")
            }
        }

        func __delete(user:User){
            DeleteUser.execute(user.UID, fromDataSpace: UsersCreationLoadTest.document.spaceUID, sucessHandler: { (context) in
                    //
                }) { (context) in
                     XCTFail("Failure on Deletion of \(user)")
            }
        }
        __create()
        waitForExpectationsWithTimeout(TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }

    
}
