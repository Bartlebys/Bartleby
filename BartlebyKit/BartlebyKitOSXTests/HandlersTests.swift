//
//  HandlersTests.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 03/05/2016.
//
//

import XCTest
import BartlebyKit

class CompletionWithResultTests: XCTestCase {

    func  test001_generic_Result_mapping() {
        let handlers=Handlers(completionHandler: { (completion) in
            if let user: User = completion.getResult() {
                 XCTAssertEqual(user.email, "bpds@me.com")
            } else {
                XCTFail()
            }
        })
        self.completionWitResult(handlers)
    }


    func  test002_generic_Result_mapping_explicit_serializer() {
        let handlers=Handlers(completionHandler: { (completion) in
            if let user: User = completion.getResultFromSerializer(JSerializer.sharedInstance) {
                XCTAssertEqual(user.email, "bpds@me.com")
            } else {
                XCTFail()
            }
        })
        self.completionWitResult(handlers)

    }




    func completionWitResult(handlers: Handlers) {
        let user=User()
        user.email="bpds@me.com"
        user.creatorUID=user.UID
        user.verificationMethod=User.VerificationMethod.ByEmail

        let completion=Completion.successState()
        completion.setResult(user)
        handlers.on(completion)
    }


}
