//
//  CryptedSerializableTransformTests.swift
//  BartlebyKit
//
//  Created by Martin Delille on 21/04/2016.
//
//

import XCTest

//import ObjectMapper

import BartlebyKit


//class UserTestContainer: Mappable {
//    var user: User?
//    var name: String?
//    
//    required init?(_ map: Map) {
//        self.mapping(map)
//    }
//    
//    func mapping(map: Map) {
//        user <- (map["user"], CryptedSerializableTransform<User>())
//        name <- (map["name"], CryptedStringTransform())
//    }
//}

class CryptedSerializableTransformTests: XCTestCase {

    override static func setUp() {
        super.setUp()
        Bartleby.sharedInstance.configureWith(TestsConfiguration)
    }
    
    func test_TransformString() {
        let transform = CryptedStringTransform()
        
        let s1 = "Coucou"
        
        let json = transform.transformToJSON(s1)
        
        print(json)
        
        let s2 = transform.transformFromJSON(json)
        
        XCTAssertEqual(s1, s2)
    }

    func test_transform() {
        let transform = CryptedSerializableTransform<User>()
        
        let user1 = User()
        user1.spaceUID = Bartleby.createUID()
        user1.creatorUID = user1.UID
        
        let json = transform.transformToJSON(user1)
        
        print("json:\(json)")
        
        if let user2 = transform.transformFromJSON(json) {
            XCTAssertEqual(user1.UID, user2.UID)
        } else {
            XCTFail("Error transforming user2")
        }
    }

}
