//
//  UsersCreationLoadTest.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 13/06/2016.
//
//

import XCTest
import BartlebyKit

/// This test creates, auth, update, deletes, logOut, multiple parallel users.
class UsersCreationLoadTest: TestCase {

    static var userCounter=0
    static var simultaneousCreations:Int=1
    static var nbOfIteration:Int=simultaneousCreations*1
    static var expecationHasBeenFullFilled=false

     static override func setUp() {
        super.setUp()
        Bartleby.sharedInstance.configureWith(TestsConfiguration)
        // Purge cookie for the domain
        if let cookies=NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(TestsConfiguration.API_BASE_URL) {
            for cookie in cookies {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
            }
        }

    }


    private func _create_a_user(completionHandler:(createdUser:User,completionState:Completion)->()){

        // We create one document per User.
        let separateDocument=BartlebyDocument()
        separateDocument.configureSchema()
        Bartleby.sharedInstance.declare(separateDocument)

        let user=User()
        user.email=Bartleby.randomStringWithLength(6)+"@bartlebys.org"
        user.verificationMethod = .ByEmail
        user.creatorUID = user.UID // (!) Auto creation in this context (Check ACL)
        user.password=Bartleby.randomStringWithLength(6)
        user.spaceUID=separateDocument.spaceUID

        CreateUser.execute(user,
                           inDataSpace:user.spaceUID,
                           sucessHandler: { (context) -> () in
                            completionHandler(createdUser:user,completionState:Completion.successStateFromJHTTPResponse(context))
        }) { (context) -> () in
            completionHandler(createdUser:user,completionState: Completion.failureStateFromJHTTPResponse(context))
        }

    }


    private func _run_test_routine_implementation(expectation:XCTestExpectation){

        UsersCreationLoadTest.expecationHasBeenFullFilled=false
        UsersCreationLoadTest.userCounter=0

        /*
        func __create(){
            for _ in 1...UsersCreationLoadTest.simultaneousCreations{
                self._create_a_user { (user, completionState) in
                    if completionState.success{
                        __login(user)
                    }else{
                        XCTFail("Failure on creation \(completionState)")
                        __fullFill()
                    }
                }
            }
        }*/

        func __create(){
                self._create_a_user { (user, completionState) in
                    if completionState.success{
                        __login(user)
                    }else{
                        XCTFail("Failure on creation [\(UsersCreationLoadTest.userCounter)]  \(completionState)")
                        __fullFill()
                    }
                }
            
        }


        func __login(user:User){
            LoginUser.execute(user, withPassword: user.password, sucessHandler: {
                __update(user)
            }) { (context) in
                __fullFill()
                XCTFail("Failure on login [\(UsersCreationLoadTest.userCounter)]  \(context)")
            }
        }

        func __update(user:User){
            user.notes=Bartleby.randomStringWithLength(40)
            UpdateUser.execute(user, inDataSpace:user.spaceUID, sucessHandler: { (context) in
                __delete(user)
            }) { (context) in
                __fullFill()
                XCTFail("Failure on Update [\(UsersCreationLoadTest.userCounter)] \(context) ")

            }
        }

        func __delete(user:User){
            DeleteUser.execute(user.UID, fromDataSpace: user.spaceUID, sucessHandler: { (context) in
                __isItTheEnd()
                //__logout(user)
            }) { (context) in
                __fullFill()
                XCTFail("Failure on Deletion [\(UsersCreationLoadTest.userCounter)]  \(context)")
            }
        }

        func __logout(user:User){
            LogoutUser.execute(fromDataSpace:user.spaceUID, sucessHandler: {
                __isItTheEnd()
            }) { (context) in
                XCTFail("Failure on logout [\(UsersCreationLoadTest.userCounter)]  \(context)")
                __fullFill()
            }
        }

        func __isItTheEnd(){
            UsersCreationLoadTest.userCounter += 1
            if  UsersCreationLoadTest.userCounter == UsersCreationLoadTest.nbOfIteration {
                __fullFill()
            }else{
                dispatch_async(dispatch_get_main_queue(), { 
                    __create()
                })

            }
        }


        func __fullFill(){
            if UsersCreationLoadTest.expecationHasBeenFullFilled == false{
                UsersCreationLoadTest.expecationHasBeenFullFilled = true
                expectation.fulfill()
            }
        }

        // Call the first creation closure
        __create()

    }

    // MARK : Create multiple Users


    func test_001_1X1() {
        UsersCreationLoadTest.simultaneousCreations=1
        UsersCreationLoadTest.nbOfIteration=UsersCreationLoadTest.simultaneousCreations*1
        let expectation = expectationWithDescription("Multi Users creations, login and deletions should succeed \(UsersCreationLoadTest.simultaneousCreations)|\(UsersCreationLoadTest.nbOfIteration)")
        self._run_test_routine_implementation(expectation)
        waitForExpectationsWithTimeout(TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }

    func test_002_2X1() {
        UsersCreationLoadTest.simultaneousCreations=2
        UsersCreationLoadTest.nbOfIteration=UsersCreationLoadTest.simultaneousCreations*1
        let expectation = expectationWithDescription("Multi Users creations, login and deletions should succeed \(UsersCreationLoadTest.simultaneousCreations)|\(UsersCreationLoadTest.nbOfIteration)")
        self._run_test_routine_implementation(expectation)
        waitForExpectationsWithTimeout(TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }


    func test_003_10X10() {
        UsersCreationLoadTest.simultaneousCreations=10
        UsersCreationLoadTest.nbOfIteration=UsersCreationLoadTest.simultaneousCreations*10
        let expectation = expectationWithDescription("Multi Users creations, login and deletions should succeed \(UsersCreationLoadTest.simultaneousCreations)|\(UsersCreationLoadTest.nbOfIteration)")
        self._run_test_routine_implementation(expectation)
        waitForExpectationsWithTimeout(TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }


    func test_004_1X1() {
        UsersCreationLoadTest.simultaneousCreations=1
        UsersCreationLoadTest.nbOfIteration=UsersCreationLoadTest.simultaneousCreations*1
        let expectation = expectationWithDescription("test_004_1X1Multi Users creations, login and deletions should succeed \(UsersCreationLoadTest.simultaneousCreations)|\(UsersCreationLoadTest.nbOfIteration)")
        self._run_test_routine_implementation(expectation)
        waitForExpectationsWithTimeout(TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }

    
}