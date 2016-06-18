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


    private func _create_a_user(completionHandler:(createdUser:User,completionState:Completion)->(),idMethod:RegistryMetadata.IdentificationMethod){

        // We create one document per User (to permit to variate the identification method without side effect)
        // You can for sure use one document for all the users 
        let document=BartlebyDocument()
        document.configureSchema()
        Bartleby.sharedInstance.declare(document)
        document.registryMetadata.identificationMethod=idMethod

        let user=User()
        user.email=Bartleby.randomStringWithLength(6)+"@bartlebys.org"
        user.verificationMethod = .ByEmail
        user.creatorUID = user.UID // (!) Auto creation in this context (Check ACL)
        user.password=Bartleby.randomStringWithLength(6)
        user.spaceUID=document.spaceUID

        CreateUser.execute(user,
                           inDataSpace:user.spaceUID,
                           sucessHandler: { (context) -> () in
                            completionHandler(createdUser:user,completionState:Completion.successStateFromJHTTPResponse(context))
        }) { (context) -> () in
            completionHandler(createdUser:user,completionState: Completion.failureStateFromJHTTPResponse(context))
        }

    }


    private func _run_test_routine_implementation(expectation:XCTestExpectation,idMethod:RegistryMetadata.IdentificationMethod){

        UsersCreationLoadTest.expecationHasBeenFullFilled=false
        UsersCreationLoadTest.userCounter=0


        func __create(idMethod:RegistryMetadata.IdentificationMethod){
                self._create_a_user ({ (user, completionState) in
                    if completionState.success{
                        __login(user)
                    }else{
                        XCTFail("Failure on creation [\(UsersCreationLoadTest.userCounter)]  \(completionState)")
                        __fullFill()
                    }
                },idMethod: idMethod)
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
                    __create(idMethod)
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
         __create(idMethod)

    }

    // MARK : Create multiple Users


    func test_001_1X1_key() {
        UsersCreationLoadTest.simultaneousCreations=1
        UsersCreationLoadTest.nbOfIteration=UsersCreationLoadTest.simultaneousCreations*1
        let expectation = expectationWithDescription("Multi Users creations, login and deletions should succeed \(UsersCreationLoadTest.simultaneousCreations)|\(UsersCreationLoadTest.nbOfIteration)")
        self._run_test_routine_implementation(expectation,idMethod: RegistryMetadata.IdentificationMethod.Key)
        waitForExpectationsWithTimeout(TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }

    /**
     We cannot use cookie on large amount of users (there is a limit)
     And random failure may occcur.
     We leave this little test to control that Explicit Cookie Identification works in basic context
     */
    func test_002_1X1_cookie() {
        UsersCreationLoadTest.simultaneousCreations=1
        UsersCreationLoadTest.nbOfIteration=UsersCreationLoadTest.simultaneousCreations*1
        let expectation = expectationWithDescription("Multi Users creations, login and deletions via Cookie Idenditifcation should succeed \(UsersCreationLoadTest.simultaneousCreations)|\(UsersCreationLoadTest.nbOfIteration)")
        self._run_test_routine_implementation(expectation,idMethod: RegistryMetadata.IdentificationMethod.Cookie)
        waitForExpectationsWithTimeout(TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }

    /**
        We cannot use cookie on large amount of users (there is a limit)
        And random failure may occcur.
        We leave this little test to control that Explicit Cookie Identification works in basic context
     */
    func test_003_1X5_cookie() {
        UsersCreationLoadTest.simultaneousCreations=1
        UsersCreationLoadTest.nbOfIteration=UsersCreationLoadTest.simultaneousCreations*5
        let expectation = expectationWithDescription("Multi Users creations, login and deletions via Cookie Idenditifcation should succeed \(UsersCreationLoadTest.simultaneousCreations)|\(UsersCreationLoadTest.nbOfIteration)")
        self._run_test_routine_implementation(expectation,idMethod: RegistryMetadata.IdentificationMethod.Cookie)
        waitForExpectationsWithTimeout(TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }



    func test_004_2X1_key() {
        UsersCreationLoadTest.simultaneousCreations=2
        UsersCreationLoadTest.nbOfIteration=UsersCreationLoadTest.simultaneousCreations*1
        let expectation = expectationWithDescription("Multi Users creations, login and deletions should succeed \(UsersCreationLoadTest.simultaneousCreations)|\(UsersCreationLoadTest.nbOfIteration)")
        self._run_test_routine_implementation(expectation,idMethod: RegistryMetadata.IdentificationMethod.Key)
        waitForExpectationsWithTimeout(TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }


    func test_005A_10X10_key() {
        UsersCreationLoadTest.simultaneousCreations=10
        UsersCreationLoadTest.nbOfIteration=UsersCreationLoadTest.simultaneousCreations*10
        let expectation = expectationWithDescription("Multi Users creations, login and deletions should succeed \(UsersCreationLoadTest.simultaneousCreations)|\(UsersCreationLoadTest.nbOfIteration)")
        self._run_test_routine_implementation(expectation,idMethod: RegistryMetadata.IdentificationMethod.Key)
        waitForExpectationsWithTimeout(TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }

    func test_005B_100X1_key() {
        UsersCreationLoadTest.simultaneousCreations=100
        UsersCreationLoadTest.nbOfIteration=UsersCreationLoadTest.simultaneousCreations*1
        let expectation = expectationWithDescription("Multi Users creations, login and deletions should succeed \(UsersCreationLoadTest.simultaneousCreations)|\(UsersCreationLoadTest.nbOfIteration)")
        self._run_test_routine_implementation(expectation,idMethod: RegistryMetadata.IdentificationMethod.Key)
        waitForExpectationsWithTimeout(TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }

    func test_005C_1X100_key() {
        UsersCreationLoadTest.simultaneousCreations=1
        UsersCreationLoadTest.nbOfIteration=UsersCreationLoadTest.simultaneousCreations*100
        let expectation = expectationWithDescription("Multi Users creations, login and deletions should succeed \(UsersCreationLoadTest.simultaneousCreations)|\(UsersCreationLoadTest.nbOfIteration)")
        self._run_test_routine_implementation(expectation,idMethod: RegistryMetadata.IdentificationMethod.Key)
        waitForExpectationsWithTimeout(TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }


    func test_006_1X1_key() {
        UsersCreationLoadTest.simultaneousCreations=1
        UsersCreationLoadTest.nbOfIteration=UsersCreationLoadTest.simultaneousCreations*1
        let expectation = expectationWithDescription("test_004_1X1Multi Users creations, login and deletions should succeed \(UsersCreationLoadTest.simultaneousCreations)|\(UsersCreationLoadTest.nbOfIteration)")
        self._run_test_routine_implementation(expectation,idMethod: RegistryMetadata.IdentificationMethod.Key)
        waitForExpectationsWithTimeout(TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }

    
}