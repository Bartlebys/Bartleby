//: [Previous](@previous)

import Alamofire
import ObjectMapper
import BartlebyKit
import XCPlayground


// Prepare Bartleby
Bartleby.sharedInstance.configureWith(PlaygroundsConfiguration.self)

// Set up a BartlebyDocument
let document=BartlebyDocument()
document.configureSchema()
Bartleby.sharedInstance.declare(document)
print(document.UID)


////////////////////////////////////////////////
// We run this demo on the Dockerized Instance.
// yd.local must be setup in hosts.
////////////////////////////////////////////////

HTTPManager.apiIsReachable(document.baseURL, successHandler: {
    print ("\(document.baseURL) is Reachable")
    let user=document.newUser()
    document.metadata.currentUser=user
    user.creatorUID=user.UID

    //////////////////////////////////
    // Create the user on the server
    //////////////////////////////////

    CreateUser.execute(user, inDocumentWithUID: document.UID, sucessHandler: { (success) in
        print("User \(user.UID) created in \(document.UID)")
        user.firstname="Zorro"

        ///////////////
        // Login
        ///////////////
        user.login(sucessHandler: {

            print("Successful login of \(user.UID) in \(document.UID)")
            user.verificationMethod=User.VerificationMethod.byEmail

            UpdateUser.execute(user, inDocumentWithUID: document.UID, sucessHandler: { (r) in
                print("Updated User \(user.UID) created in \(document.UID) \(r.httpStatusCode ?? 0 )")
                }, failureHandler: { (failure) in
                    print("User Update failed \(user.UID) in \(document.UID) \(failure.httpStatusCode ?? 0 )")
            })





            }, failureHandler: { (failure) in
                print("User Login failure \(user.UID)  in \(document.UID) \(failure.httpStatusCode ?? 0 ) \(failure)")
        })


    }) { (failure) in
         print("User Creation failure \(user.UID)  in \(document.UID) \(failure.httpStatusCode ?? 0 ) \(failure)")
    }

    }) { (context) in
        print ("\(context)")
}


// Wait indefintely
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true


//: [Next](@next)
