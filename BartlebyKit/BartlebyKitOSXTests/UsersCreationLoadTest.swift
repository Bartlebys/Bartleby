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
        Bartleby.sharedInstance.configureWith(TestsConfiguration.self)
        // Purge cookie for the domain
        if let cookies=HTTPCookieStorage.shared.cookies(for: TestsConfiguration.API_BASE_URL) {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }



    }


    fileprivate func _create_a_user(_ completionHandler:@escaping (_ createdUser:User,_ completionState:Completion)->(),idMethod:RegistryMetadata.IdentificationMethod){

        // We create one document per User (to permit to variate the identification method without side effect)
        // You can for sure use one document for all the users 
        let document=UsersCreationLoadTest.document
        document.configureSchema()
        Bartleby.sharedInstance.declare(document)
        document.registryMetadata.identificationMethod=idMethod

        let user=document.newUser()
        user.email=Bartleby.randomStringWithLength(6)+"@bartlebys.org"
        user.verificationMethod = .byEmail
        user.creatorUID = user.UID // (!) Auto creation in this context (Check ACL)
        user.password=Bartleby.randomStringWithLength(6)
        user.spaceUID=document.spaceUID

        CreateUser.execute(user,
                           inRegistryWithUID:document.UID,
                           sucessHandler: { (context) -> () in
                            completionHandler(user,Completion.successStateFromJHTTPResponse(context))
        }) { (context) -> () in
            completionHandler(user,Completion.failureStateFromJHTTPResponse(context))
        }

    }


    fileprivate func _run_test_routine_implementation(_ expectation:XCTestExpectation,idMethod:RegistryMetadata.IdentificationMethod){

        UsersCreationLoadTest.expecationHasBeenFullFilled=false
        UsersCreationLoadTest.userCounter=0


        func __create(_ idMethod:RegistryMetadata.IdentificationMethod){
                self._create_a_user ({ (user, completionState) in
                    if completionState.success{
                        __login(user)
                    }else{
                        XCTFail("Failure on creation [\(UsersCreationLoadTest.userCounter)]  \(completionState)")
                        __fullFill()
                    }
                },idMethod: idMethod)
        }


        func __login(_ user:User){
            user.login(sucessHandler: {
                __update(user)
            }) { (context) in
                __fullFill()
                XCTFail("Failure on login [\(UsersCreationLoadTest.userCounter)]  \(context)")
            }
        }

        func __update(_ user:User){
            user.notes=Bartleby.randomStringWithLength(40)
            UpdateUser.execute(user, inRegistryWithUID:UsersCreationLoadTest.document.UID, sucessHandler: { (context) in
                __delete(user)
            }) { (context) in
                __fullFill()
                XCTFail("Failure on Update [\(UsersCreationLoadTest.userCounter)] \(context) ")

            }
        }

        func __delete(_ user:User){
            DeleteUser.execute(user.UID, fromRegistryWithUID: UsersCreationLoadTest.document.UID, sucessHandler: { (context) in
                __isItTheEnd()
                //__logout(user)
            }) { (context) in
                __fullFill()
                XCTFail("Failure on Deletion [\(UsersCreationLoadTest.userCounter)]  \(context)")
            }
        }

        func __logout(_ user:User){
            LogoutUser.execute(user, sucessHandler: {
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
                DispatchQueue.main.async(execute: { 
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
        let expectation = self.expectation(description: "Multi Users creations, login and deletions should succeed \(UsersCreationLoadTest.simultaneousCreations)|\(UsersCreationLoadTest.nbOfIteration)")
        self._run_test_routine_implementation(expectation,idMethod: RegistryMetadata.IdentificationMethod.key)
        waitForExpectations(timeout: TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }

    /**
     We cannot use cookie on large amount of users (there is a limit)
     And random failure may occcur.
     We leave this little test to control that Explicit Cookie Identification works in basic context
     */
    func test_002_1X1_cookie() {
        UsersCreationLoadTest.simultaneousCreations=1
        UsersCreationLoadTest.nbOfIteration=UsersCreationLoadTest.simultaneousCreations*1
        let expectation = self.expectation(description: "Multi Users creations, login and deletions via Cookie Idenditifcation should succeed \(UsersCreationLoadTest.simultaneousCreations)|\(UsersCreationLoadTest.nbOfIteration)")
        self._run_test_routine_implementation(expectation,idMethod: RegistryMetadata.IdentificationMethod.cookie)
        waitForExpectations(timeout: TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }

    /**
        We cannot use cookie on large amount of users (there is a limit)
        And random failure may occcur.
        We leave this little test to control that Explicit Cookie Identification works in basic context
     */
    func test_003_1X5_cookie() {
        UsersCreationLoadTest.simultaneousCreations=1
        UsersCreationLoadTest.nbOfIteration=UsersCreationLoadTest.simultaneousCreations*5
        let expectation = self.expectation(description: "Multi Users creations, login and deletions via Cookie Idenditifcation should succeed \(UsersCreationLoadTest.simultaneousCreations)|\(UsersCreationLoadTest.nbOfIteration)")
        self._run_test_routine_implementation(expectation,idMethod: RegistryMetadata.IdentificationMethod.cookie)
        waitForExpectations(timeout: TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }



    func test_004_2X1_key() {
        UsersCreationLoadTest.simultaneousCreations=2
        UsersCreationLoadTest.nbOfIteration=UsersCreationLoadTest.simultaneousCreations*1
        let expectation = self.expectation(description: "Multi Users creations, login and deletions should succeed \(UsersCreationLoadTest.simultaneousCreations)|\(UsersCreationLoadTest.nbOfIteration)")
        self._run_test_routine_implementation(expectation,idMethod: RegistryMetadata.IdentificationMethod.key)
        waitForExpectations(timeout: TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }


    func test_005A_10X10_key() {
        UsersCreationLoadTest.simultaneousCreations=10
        UsersCreationLoadTest.nbOfIteration=UsersCreationLoadTest.simultaneousCreations*10
        let expectation = self.expectation(description: "Multi Users creations, login and deletions should succeed \(UsersCreationLoadTest.simultaneousCreations)|\(UsersCreationLoadTest.nbOfIteration)")
        self._run_test_routine_implementation(expectation,idMethod: RegistryMetadata.IdentificationMethod.key)
        waitForExpectations(timeout: TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }

    func test_005B_100X1_key() {
        UsersCreationLoadTest.simultaneousCreations=100
        UsersCreationLoadTest.nbOfIteration=UsersCreationLoadTest.simultaneousCreations*1
        let expectation = self.expectation(description: "Multi Users creations, login and deletions should succeed \(UsersCreationLoadTest.simultaneousCreations)|\(UsersCreationLoadTest.nbOfIteration)")
        self._run_test_routine_implementation(expectation,idMethod: RegistryMetadata.IdentificationMethod.key)
        waitForExpectations(timeout: TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }

    func test_005C_1X100_key() {
        UsersCreationLoadTest.simultaneousCreations=1
        UsersCreationLoadTest.nbOfIteration=UsersCreationLoadTest.simultaneousCreations*100
        let expectation = self.expectation(description: "Multi Users creations, login and deletions should succeed \(UsersCreationLoadTest.simultaneousCreations)|\(UsersCreationLoadTest.nbOfIteration)")
        self._run_test_routine_implementation(expectation,idMethod: RegistryMetadata.IdentificationMethod.key)
        waitForExpectations(timeout: TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }


    func test_006_1X1_key() {
        UsersCreationLoadTest.simultaneousCreations=1
        UsersCreationLoadTest.nbOfIteration=UsersCreationLoadTest.simultaneousCreations*1
        let expectation = self.expectation(description: "test_004_1X1Multi Users creations, login and deletions should succeed \(UsersCreationLoadTest.simultaneousCreations)|\(UsersCreationLoadTest.nbOfIteration)")
        self._run_test_routine_implementation(expectation,idMethod: RegistryMetadata.IdentificationMethod.key)
        waitForExpectations(timeout: TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }

    
}
